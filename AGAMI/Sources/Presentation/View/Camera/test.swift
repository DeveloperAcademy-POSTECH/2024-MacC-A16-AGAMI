//
//  test.swift
//  AGAMI
//
//  Created by taehun on 10/29/24.
//
import SwiftUI

struct TestView: View {
    var body: some View {
        Button {
//            viewModel.capturePhoto()
        } label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 85, height: 85, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 3)
                        .frame(width: 72.5, height: 72.5, alignment: .center)
                )
        }
    }
}

#Preview {
    TestView()
}
