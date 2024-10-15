//
//  CollectionPlaceView.swift
//  AGAMI
//
//  Created by yegang on 10/14/24.
//

import SwiftUI

struct PlayList: Identifiable, Hashable {
    var id = UUID()
    var address: String
    var date: String
    var time: String
}

struct CollectionPlaceView: View {
    @State private var playList: [PlayList] = [
        PlayList(address: "포항시", date: "2024-03-02", time: "17:00"),
        PlayList(address: "천안시", date: "2023-03-01", time: "13:00"),
        PlayList(address: "서울시", date: "2020-05-05", time: "10:00")
    ]
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = MapViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                CollectionPlaceListView(playList: $playList)
                
                CollectionPlaceListView(playList: $playList)
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
