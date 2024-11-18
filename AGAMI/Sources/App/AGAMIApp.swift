import SwiftUI
import Firebase

@main
struct AGAMIApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AppContentView()
        }
    }
}
