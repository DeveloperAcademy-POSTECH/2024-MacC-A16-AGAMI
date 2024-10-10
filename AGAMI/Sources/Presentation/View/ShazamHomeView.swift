//
//  ShazamHomeView.swift
//  AGAMI
//
//  Created by 박현수 on 10/10/24.
//

import SwiftUI
import ShazamKit
import AVKit

struct ShazamHomeView: View {
    @State private var viewModel = ShazamViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                Spacer()
                AsyncImage(url: viewModel.currentItem?.artworkURL) { image in
                    image.image?.resizable().scaledToFit()
                }
                .frame(width: 200, height: 200, alignment: .center)

                Text(viewModel.currentItem?.title ?? "Press the Button below to Shazam")
                    .font(.title3.bold())

                Text(viewModel.currentItem?.artist ?? "")
                    .font(.body)
                Spacer()
                if viewModel.shazaming == true {
                    Button("Stop Shazaming") {
                        viewModel.stopRecognition()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                } else {
                    Button("Start Shazaming") {
                        viewModel.startRecognition()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle("Shazam")
        }
    }
}
