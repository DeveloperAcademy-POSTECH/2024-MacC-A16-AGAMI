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
            } else {
                SignInView()
            }
        }
    }
}
