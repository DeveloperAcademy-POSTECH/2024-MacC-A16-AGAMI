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

@Observable
final class SpotifyService {
    static let shared = SpotifyService()
    private let spotifyAPI: SpotifyAPI<AuthorizationCodeFlowManager>
    private let loginCallbackURL: URL
    private let authorizationManagerKey = "authorizationManagerKey"
    private var authorizationState = String.randomURLSafe(length: 128)
    private let keychain = Keychain(service: "com.agami.plake")

    private var isAuthorized = false
    private var isRetrievingTokens = false
    var currentUser: SpotifyUser?

    private var cancellables: Set<AnyCancellable> = []

    private init() {
        guard let clientId = Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as? String,
              let clientSecret = Bundle.main.object(forInfoDictionaryKey: "CLIENT_SECRET") as? String,
              let redirectURL = Bundle.main.object(forInfoDictionaryKey: "REDIRECT_URL") as? String,
              let decodedRedirectURL = redirectURL.removingPercentEncoding,
              let url = URL(string: decodedRedirectURL) else {
            fatalError("Invalid configuration values in Info.plist.")
        }

        self.spotifyAPI = SpotifyAPI(
            authorizationManager: AuthorizationCodeFlowManager(
                clientId: clientId,
                clientSecret: clientSecret
            )
        )
        self.loginCallbackURL = url

        self.spotifyAPI.apiRequestLogger.logLevel = .trace

        self.spotifyAPI.authorizationManagerDidChange
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidChange)
            .store(in: &cancellables)

        self.spotifyAPI.authorizationManagerDidDeauthorize
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidDeauthorize)
            .store(in: &cancellables)

        getAuthorizationManager()
    }

    private func getAuthorizationManager() {
        if let authManagerData = keychain[data: self.authorizationManagerKey] {

            do {
                // Try to decode the data.
                let authorizationManager = try JSONDecoder().decode(
                    AuthorizationCodeFlowManager.self,
                    from: authManagerData
                )
                print("found authorization information in keychain")

                self.spotifyAPI.authorizationManager = authorizationManager

            } catch {
                print("could not decode authorizationManager from data:\n\(error)")
            }
        } else {
            print("did NOT find authorization information in keychain")
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
            print("Failed to create authorization URL.")
            return
        }
        UIApplication.shared.open(url)
    }

    private func authorizationManagerDidChange() {
        self.isAuthorized = self.spotifyAPI.authorizationManager.isAuthorized()

        if self.isAuthorized {
            print("Authorization successful: isAuthorized is true.")
        } else {
            print("Authorization failed: isAuthorized is false.")
        }

        print("Spotify.authorizationManagerDidChange: isAuthorized:", self.isAuthorized)
        self.retrieveCurrentUser()

        do {
            let authManagerData = try JSONEncoder().encode(self.spotifyAPI.authorizationManager)
            print("authManagerData: \(authManagerData)")
            self.keychain[data: self.authorizationManagerKey] = authManagerData
            print("Did save authorization manager to keychain.")
        } catch {
            print("Couldn't encode authorizationManager for storage in keychain:\n\(error)")
        }
    }

    private func authorizationManagerDidDeauthorize() {
        self.isAuthorized = false
        self.currentUser = nil

        do {
            try self.keychain.remove(self.authorizationManagerKey)
            print("did remove authorization manager from keychain")

        } catch {
            print(
                "couldn't remove authorization manager " +
                "from keychain: \(error)"
            )
        }
    }

    private func retrieveCurrentUser(onlyIfNil: Bool = true) {
        if onlyIfNil && self.currentUser != nil {
            return
        }

        self.spotifyAPI.currentUserProfile()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("couldn't retrieve current user: \(error)")
                    }
                },
                receiveValue: { user in
                    self.currentUser = user
                }
            )
            .store(in: &cancellables)
    }

    public func handleURL(_ url: URL) {
        guard url.scheme == self.loginCallbackURL.scheme else {
            print("not handling URL: unexpected scheme: '\(url)'")
            return
        }

        print("received redirect from Spotify: '\(url)'")

        self.isRetrievingTokens = true

        self.spotifyAPI.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            state: self.authorizationState
        )
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            self.isRetrievingTokens = false

            if case .failure(let error) = completion {
                print("couldn't retrieve access and refresh tokens:\n\(error)")
                if let authError = error as? SpotifyAuthorizationError,
                   authError.accessWasDenied {
                }
            }
        })
        .store(in: &cancellables)

        self.authorizationState = String.randomURLSafe(length: 128)
        authorizationManagerDidChange()
    }

    func addPlayList(name: String,
                     musicList: [(String, String?)],
                     description: String?,
                     _ completionHandler: @escaping (String?) -> Void) {
        if currentUser == nil {
            authorize()
        } else {
            performPlaylistCreation(name: name, musicList: musicList, description: description) { playlistUri in
                completionHandler(playlistUri)
            }
        }
    }

    private func performPlaylistCreation(name: String,
                                         musicList: [(String, String?)],
                                         description: String?,
                                         _ completionHandler: @escaping (String?) -> Void) {
        var trackUris: [String] = []
        var playlistUri: String = ""

        func searchTracks() -> AnyPublisher<Void, Error> {

            return Publishers.Sequence(sequence: musicList)
                .flatMap(maxPublishers: .max(1)) { song -> AnyPublisher<String?, Never> in
                    let query = "\(song.1 ?? "") \(song.0)"
                    print("@LOG query: \(query)")
                    let categories: [IDCategory] = [.artist, .track]

                    return self.spotifyAPI.search(query: query, categories: categories, limit: 1)
                        .map { searchResult in
                            print("@LOG searchResult \(searchResult.tracks?.items.first?.name ?? "nil")")
                            return searchResult.tracks?.items.first?.uri
                        }
                        .replaceError(with: nil)
                        .eraseToAnyPublisher()
                }
                .compactMap { $0 }
                .collect()
                .map { nonDuplicateTrackUris in
                    trackUris = nonDuplicateTrackUris
                }
                .eraseToAnyPublisher()
        }

        func createPlaylist(description: String?) -> AnyPublisher<Void, Error> {
            guard let userURI: SpotifyURIConvertible = self.currentUser?.uri else {
                return Fail(error: ErrorType.userNotFound).eraseToAnyPublisher()
            }

            let playlistDetails = PlaylistDetails(name: name,
                                                  isPublic: false,
                                                  isCollaborative: false,
                                                  description: description)

            return self.spotifyAPI.createPlaylist(for: userURI, playlistDetails)
                .map { playlist in
                    print("Playlist created: \(playlist)")
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
                .map { result in
                    print("Items added successfully. Result: \(result)")
                }
                .eraseToAnyPublisher()
        }

        searchTracks()
            .flatMap { _ in createPlaylist(description: description) }
            .flatMap { _ in addTracks() }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Playlist creation completed successfully.")
                    completionHandler(playlistUri)
                case .failure(let error):
                    print("Error: \(error)")
                    completionHandler(nil)
                }
            }, receiveValue: {})
            .store(in: &cancellables)
    }

    private enum ErrorType: Error {
        case trackNotFound
        case userNotFound
        case noTracksFound
    }
}