//
//  UINavigationController+.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 11/2/24.
//

import SwiftUI

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return PopGestureManager.shared.isPopGestureEnabled && viewControllers.count > 1
    }
}

// 스와이프 제스처 막는 뷰 모디파이어
final class PopGestureManager {
    static let shared = PopGestureManager()
    private init() {}
    
    var isPopGestureEnabled = true
}

struct PopGestureViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .task {
                PopGestureManager.shared.isPopGestureEnabled = false
            }
            .onDisappear {
                PopGestureManager.shared.isPopGestureEnabled = true
            }
    }
}

extension View {
    func disablePopGesture() -> some View {
        modifier(PopGestureViewModifier())
    }
}
