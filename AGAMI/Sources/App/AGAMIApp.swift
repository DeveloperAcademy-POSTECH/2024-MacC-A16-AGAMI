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
                        SpotifyService.shared.handleURL(url)
                    }
            } else {
                SignInView()
            }
        }
    }
}
