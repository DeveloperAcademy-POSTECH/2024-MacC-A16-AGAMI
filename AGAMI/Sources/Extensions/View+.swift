//
//  View+.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    @ViewBuilder
    func toolbarVisibilityForVersion(_ visibility: Visibility, for bar: ToolbarPlacement) -> some View {
        if #available(iOS 18.0, *) {
            self.toolbarVisibility(visibility, for: bar)
        } else {
            self.toolbar(visibility, for: bar)
        }
    }

    func getAlwaysByOneIfAvailableElseAlways() -> ViewAlignedScrollTargetBehavior.LimitBehavior {
        if #available(iOS 18.0, *) {
            return .alwaysByOne
        } else {
            return .always
        }
    }

    @ViewBuilder
    func conditionalModifier(_ condition: Bool, builder: (Self) -> some View) -> some View {
        if condition {
            builder(self)
        } else {
            self
        }
    }
    
    func onAppearAndActiveCheckUserValued(_ scenePhase: ScenePhase) -> some View {
            self
                .onAppear {
                    Task {
                        do {
                            try await FirebaseAuthService.checkUserValued()
                            dump("User valued status is checked successfully on appear.")
                        } catch {
                            dump("Error checking user valued status on appear: \(error.localizedDescription)")
                        }
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        Task {
                            do {
                                try await FirebaseAuthService.checkUserValued()
                                dump("User valued status is checked successfully in active state.")
                            } catch {
                                dump("Error checking user valued status in active state: \(error.localizedDescription)")
                            }
                        }
                    }
                }
        }
}
