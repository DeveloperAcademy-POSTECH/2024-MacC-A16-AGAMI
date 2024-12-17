//
//  AppContentView.swift
//  AGAMI
//
//  Created by 박현수 on 11/17/24.
//

import SwiftUI

struct AppContentView: View {
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    @State private var sologCoordinator: SologCoordinator = .init()
    @State private var listCellPlaceholder: ListCellPlaceholderModel = ListCellPlaceholderModel()

    init() { initializeSpotifyService() }

    var body: some View {
        if isSignedIn {
            NavigationStack(path: $sologCoordinator.path) {
                sologCoordinator.build(route: .listView)
                    .onOpenURL { handleURL($0) }
                    .navigationDestination(for: SologRoute.self) { view in
                        sologCoordinator.build(route: view)
                    }
                    .sheet(item: $sologCoordinator.sheet) { sheet in
                        sologCoordinator.buildSheet(sheet: sheet)
                    }
                    .fullScreenCover(item: $sologCoordinator.fullScreenCover) { cover in
                        sologCoordinator.buildFullScreenCover(cover: cover)
                    }
            }
            .environment(listCellPlaceholder)
            .environment(sologCoordinator)

        } else {
            SignInView()
        }
    }

    private func handleURL(_ url: URL) {
        guard let redirectURL = Bundle.main.object(forInfoDictionaryKey: "REDIRECT_URL") as? String,
              let decodedRedirectURL = redirectURL.removingPercentEncoding,
              url.absoluteString.contains(decodedRedirectURL)
        else { return }
        
        SpotifyService.shared.handleURL(url)
    }

    private func initializeSpotifyService() {
        _ = SpotifyService.shared
    }
}

#Preview {
    AppContentView()
}
