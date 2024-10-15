//
//  CollectionPlaceView.swift
//  AGAMI
//
//  Created by yegang on 10/14/24.
//

import SwiftUI

struct CollectionPlaceView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = CollectionPlaceViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                CollectionPlaceListView(playList: $viewModel.playList)                
            }
        }
        .navigationTitle("수집 장소")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.backward")
                            .bold()
                        
                        Text("지도")
                    }
                }
            }
        }
    }
}

#Preview {
    CollectionPlaceView()
}
