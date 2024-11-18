//
//  AppContentView.swift
//  AGAMI
//
//  Created by 박현수 on 11/17/24.
//

import SwiftUI

struct AppContentView: View {
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    @State private var plakeCoordinator: PlakeCoordinator = .init()
    @State private var listCellPlaceholder: ListCellPlaceholderModel = ListCellPlaceholderModel()
    
    var body: some View {
        if isSignedIn {
            NavigationStack(path: $plakeCoordinator.path) {
                plakeCoordinator.build(route: .homeView)
                    .onOpenURL { url in
                        handleURL(url)
                    }
                    .navigationDestination(for: PlakeRoute.self) { view in
                        plakeCoordinator.build(route: view)
                    }
                    .sheet(item: $plakeCoordinator.sheet) { sheet in
                        plakeCoordinator.buildSheet(sheet: sheet)
                    }
                    .fullScreenCover(item: $plakeCoordinator.fullScreenCover) { cover in
                        plakeCoordinator.buildFullScreenCover(cover: cover)
                    }
            }
            .environment(listCellPlaceholder)
            .environment(plakeCoordinator)
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
