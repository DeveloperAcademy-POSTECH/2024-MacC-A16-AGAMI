import SwiftUI

@main
struct AGAMIApp: App {
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false

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
