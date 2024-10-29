import SwiftUI
import Firebase

@main
struct AGAMIApp: App {
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if isSignedIn {
                HomeView()
                    .onOpenURL { url in
                        if let redirectURL = Bundle.main.object(forInfoDictionaryKey: "REDIRECT_URL") as? String,
                           let decodedRedirectURL = redirectURL.removingPercentEncoding {
                            if url.absoluteString.contains(decodedRedirectURL) {
                                SpotifyService.shared.handleURL(url)
                            }
                        }
                    }
            } else {
                SignInView()
            }
        }
    }
}
