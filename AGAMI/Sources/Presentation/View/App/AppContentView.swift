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
    
    var body: some View {
        if isSignedIn {
            NavigationStack(path: $sologCoordinator.path) {
                sologCoordinator.build(route: .listView)
                    .onOpenURL { url in
                        handleURL(url)
                    }
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
        if let redirectURL = Bundle.main.object(forInfoDictionaryKey: "REDIRECT_URL") as? String,
           let decodedRedirectURL = redirectURL.removingPercentEncoding {
            if url.absoluteString.contains(decodedRedirectURL) {
                SpotifyService.shared.handleURL(url)
            }
        }
    }
}

#Preview {
    AppContentView()
}
