//
//  SpotifyService.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/24/24.
//

import UIKit
import Combine
import SpotifyWebAPI
import KeychainAccess

final class SpotifyService {
    // 싱글톤 인스턴스
    static let shared = SpotifyService()

    // SDK 프로퍼티
    private let spotifyAPI: SpotifyAPI<AuthorizationCodeFlowManager>
    private let loginCallbackURL: URL
    private let authorizationManagerKey = "authorizationManagerKey"
    private let keychain = Keychain(service: "com.agami.plake")
    private var currentUser: SpotifyUser?

    // 상태 관리 변수
    private var authorizationState = String.randomURLSafe(length: 128)
    private var isAuthorized = false
    private var isRetrievingTokens = false

    // 인증 완료를 기다리는 Continuation
    private var authContinuation: CheckedContinuation<Void, Never>?

    // Combine Store Set (RxSwift DisposeBag과 유사)
    private var cancellables: Set<AnyCancellable> = []

    private init() {
        guard let clientId = Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as? String,
              let clientSecret = Bundle.main.object(forInfoDictionaryKey: "CLIENT_SECRET") as? String,
              let redirectURL = Bundle.main.object(forInfoDictionaryKey: "REDIRECT_URL") as? String,
              let decodedRedirectURL = redirectURL.removingPercentEncoding,
              let url = URL(string: decodedRedirectURL)
        else { fatalError("Invalid configuration values in Info.plist.") }

        // SDK 프로퍼티 set
        self.spotifyAPI = SpotifyAPI(
            authorizationManager: AuthorizationCodeFlowManager(
                clientId: clientId,
                clientSecret: clientSecret
            )
        )
        self.loginCallbackURL = url
        self.spotifyAPI.apiRequestLogger.logLevel = .trace

        // 인증 상태 변경 감지
        self.spotifyAPI.authorizationManagerDidChange
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidChange)
            .store(in: &cancellables)

        // 인증 해제 감지
        self.spotifyAPI.authorizationManagerDidDeauthorize
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidDeauthorize)
            .store(in: &cancellables)

        // authorizationManager 가져오기
        getAuthorizationManager()
        // 토큰 갱신
        refreshIfNeeded()
        // currentUser 복원
        retrieveCurrentUser()
    }
}

// MARK: - 인증 및 Keychain 토큰 저장/갱신 로직
extension SpotifyService {
    private func getAuthorizationManager() {
        guard let authorizationManagerData = keychain[data: self.authorizationManagerKey] else {
            dump("Spotify: 키체인에 인증 정보가 없습니다")
            return
        }
        do {
            self.spotifyAPI.authorizationManager = try JSONDecoder().decode(
                AuthorizationCodeFlowManager.self,
                from: authorizationManagerData
            )
        } catch {
            dump("Spotify: authorizationManager 디코딩 실패:\n\(error)")
        }
    }

    private func authorize() {
        guard let url = self.spotifyAPI.authorizationManager.makeAuthorizationURL(
            redirectURI: self.loginCallbackURL,
            showDialog: true,
            state: self.authorizationState,
            scopes: [
                .playlistModifyPrivate,
                .playlistModifyPublic
            ]
        ) else {
            dump("Spotify: authorization URL 생성 실패")
            return
        }
        Task { @MainActor in UIApplication.shared.open(url) }
    }

    private func authorizationManagerDidChange() {
        self.isAuthorized = self.spotifyAPI.authorizationManager.isAuthorized()

        if self.isAuthorized {
            // 인증 대기중이었던 함수가 있다면 계속 진행
            // authContinuation은 addPlayList()에서 설정
            authContinuation?.resume(returning: ())
            authContinuation = nil
        }

        dump("Spotify: isAuthorized == \(self.isAuthorized)")
        self.retrieveCurrentUser()

        do {
            self.keychain[data: self.authorizationManagerKey] = try JSONEncoder().encode(self.spotifyAPI.authorizationManager)
        } catch {
            dump("Spotify: KeyChain에 저장될 authorizationManager 인코딩 실패\n\(error)")
        }
    }

    private func authorizationManagerDidDeauthorize() {
        self.isAuthorized = false
        self.currentUser = nil

        do {
            try self.keychain.remove(self.authorizationManagerKey)
        } catch {
            dump("Spotify: KeyChain에서 authorizationManager 제거 실패\n\(error)")
        }
    }

    private func refreshIfNeeded() {
        guard !spotifyAPI.authorizationManager.isAuthorized() else { return }
        spotifyAPI.authorizationManager.refreshTokens(onlyIfExpired: true)
            .receive(on: RunLoop.main)
            .sink { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    dump("Spotify: 토큰 갱신 실패\n\(error)")
                }
            }
            .store(in: &cancellables)
    }

    private func retrieveCurrentUser(onlyIfNil: Bool = true) {
        if onlyIfNil && self.currentUser != nil {
            return
        }
        self.spotifyAPI.currentUserProfile()
            .receive(on: RunLoop.main)
            .sink {
                if case .failure(let error) = $0 {
                    dump("Spotify: currentUser 복원 실패\n\(error)")
                }
            } receiveValue: { user in
                self.currentUser = user
            }
            .store(in: &cancellables)
    }
}

// MARK: - URL Scheme 핸들링
extension SpotifyService {
    func handleURL(_ url: URL) {
        guard url.scheme == self.loginCallbackURL.scheme else {
            dump("Spotify: 잘못된 콜백 URL scheme '\(url)'")
            return
        }
        self.isRetrievingTokens = true

        // 토큰 요청
        self.spotifyAPI.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            state: self.authorizationState
        )
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { [weak self] completion in
            guard let self = self else { return }
            self.isRetrievingTokens = false

            switch completion {
            case .finished:
                self.authorizationState = String.randomURLSafe(length: 128)
            case .failure(let error):
                dump("Spotify: 토큰 갱신 실패\n\(error)")
                return
            }
        })
        .store(in: &cancellables)
    }
}

// MARK: - 플레이리스트 생성
extension SpotifyService {
    /// 플레이리스트 생성:
    /// - 아직 인증이 안 된 경우 → 인증 플로우 시작 → 인증 완료까지 대기 → 이후 생성
    /// - 이미 인증된 경우 → 바로 생성
    /// - 결과값: 생성된 playlist URI (String) 또는 실패 시 nil
    func addPlayList(name: String,
                     musicList: [(String, String?)],
                     description: String?) async -> String? {

        // currentUser가 확보된 상태라면 바로 진행
        if currentUser != nil {
            return await performPlaylistCreation(
                name: name,
                musicList: musicList,
                description: description
            )
        }

        authorize()

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            // 인증 완료되면 authorizationManagerDidChange에서 continuation.resume
            self.authContinuation = continuation
        }

        return await performPlaylistCreation(
            name: name,
            musicList: musicList,
            description: description
        )
    }

    private func performPlaylistCreation(name: String,
                                         musicList: [(String, String?)],
                                         description: String?) async -> String? {
        var trackUris: [String] = []
        var playlistUri: String = ""

        func searchTracks() -> AnyPublisher<Void, Error> {
            return Publishers.Sequence(sequence: musicList)
                .flatMap(maxPublishers: .max(1)) { song -> AnyPublisher<String?, Never> in
                    let query = "\(song.1 ?? "") \(song.0)"
                    let categories: [IDCategory] = [.artist, .track]

                    return self.spotifyAPI.search(query: query, categories: categories, limit: 1)
                        .map { $0.tracks?.items.first?.uri }
                        .replaceError(with: nil)
                        .eraseToAnyPublisher()
                }
                .compactMap { $0 }
                .collect()
                .map { trackUris = $0 }
                .eraseToAnyPublisher()
        }

        func createPlaylist(description: String?) -> AnyPublisher<Void, Error> {
            guard let userURI: SpotifyURIConvertible = self.currentUser?.uri else {
                return Fail(error: ErrorType.userNotFound).eraseToAnyPublisher()
            }

            let playlistDetails = PlaylistDetails(
                name: name,
                isPublic: false,
                isCollaborative: false,
                description: description
            )

            return self.spotifyAPI.createPlaylist(for: userURI, playlistDetails)
                .map { playlist in
                    dump("Spotify: 플레이리스트 생성됨 \(playlist)")
                    playlistUri = playlist.uri
                }
                .eraseToAnyPublisher()
        }

        func addTracks() -> AnyPublisher<Void, Error> {
            guard !trackUris.isEmpty else {
                return Fail(error: ErrorType.noTracksFound).eraseToAnyPublisher()
            }
            let uris: [SpotifyURIConvertible] = trackUris

            return self.spotifyAPI.addToPlaylist(playlistUri, uris: uris)
                .map { dump("Spotify: 트랙 추가됨 \($0)") }
                .eraseToAnyPublisher()
        }

        // 플레이리스트 추가 파이프라인 연결
        let pipeline = searchTracks()
            .flatMap { _ in createPlaylist(description: description) }
            .flatMap { _ in addTracks() }
            .map { playlistUri } // 성공 시 playlistUri 전달
            .catch { error -> Just<String?> in
                dump("Spotify: 플레이리스트 생성 오류\n\(error)")
                return Just(nil)
            }
            .eraseToAnyPublisher()

        // Combine → async/await 브릿지
        do {
            let result = try await pipeline.asyncSingleOutput()
            return result
        } catch {
            dump("Spotify: Combine 파이프라인 오류 \(error)")
            return nil
        }
    }
}

// MARK: - Spotify 에러 타입
extension SpotifyService {
    private enum ErrorType: Error {
        case trackNotFound
        case userNotFound
        case noTracksFound
    }
}
