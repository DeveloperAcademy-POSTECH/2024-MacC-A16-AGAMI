import SwiftUI
import Firebase

@main
struct AGAMIApp: App {
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false
    @State private var plakeCoordinator: PlakeCoordinator = .init()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if isSignedIn {
                NavigationStack(path: $plakeCoordinator.path) {
                    HomeView()
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
                .environment(plakeCoordinator)
            } else {
                SignInView()
            }
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
