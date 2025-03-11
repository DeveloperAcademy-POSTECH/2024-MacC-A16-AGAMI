//
//  CircleAnimationView.swift
//  AGAMI
//
//  Created by taehun on 11/4/24.
//

import SwiftUI

struct CircleAnimationView: View {
    @State private var moveUp = false

    var body: some View {
        HStack(spacing: 5) {
            createAnimatedCircle(delay: 0.0)
            createAnimatedCircle(delay: 0.2)
            createAnimatedCircle(delay: 0.4)
        }
        .onAppear {
            moveUp = true
        }
    }
    
    private func createAnimatedCircle(delay: Double) -> some View {
        Circle()
            .fill(Color(.sMain))
            .frame(width: 6.14, height: 6.14)
            .offset(y: moveUp ? -2 : 2)
            .animation(
                .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: moveUp
            )
    }
}

#Preview {
    CircleAnimationView()
}

