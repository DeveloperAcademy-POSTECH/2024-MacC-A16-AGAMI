//
//  CollectionPlaceView.swift
//  AGAMI
//
//  Created by yegang on 10/14/24.
//

import SwiftUI
// TODO: - 전체적인 뷰 수정예정
struct CollectionPlaceView: View {
    let viewModel: MapViewModel
    let playlist: PlaylistModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                CollectionPlaceListView(viewModel: viewModel, playlist: playlist)
            }
        }
        .navigationTitle("플라키브")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(Color(rgbHex: "#FF2442"))
                            .bold()
                        
                        Text("지도")
                    }
                }
            }
        }
    }
}

// #Preview {
//     CollectionPlaceView()
// }
