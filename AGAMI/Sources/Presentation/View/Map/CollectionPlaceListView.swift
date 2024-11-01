//
//  CollectionPlaceListView.swift
//  AGAMI
//
//  Created by yegang on 10/15/24.
//

import SwiftUI

struct CollectionPlaceListView: View {
    let viewModel: CollectionPlaceViewModel
    
    private let columnWidth: CGFloat = 176
    private let columnSpacing: CGFloat = 9
    private var columns: [GridItem] {
        [
            GridItem(.flexible(minimum: columnWidth), spacing: columnSpacing),
            GridItem(.flexible(minimum: columnWidth))
        ]
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 9) {
                ForEach(viewModel.playlists, id: \.playlistID) { playlist in
                    ZStack {
                        AsyncImage(url: URL(string: playlist.photoURL)) { image in
                            image
                                .image?.resizable()
                                .aspectRatio(1.0, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 13))
                        }
                        
                        VStack(alignment: .center, spacing: 0) {
                            Spacer()
                            
                            Text("\(playlist.streetAddress)")
                                .foregroundStyle(Color(.pGray2))
                                .font(.pretendard(weight: .regular400, size: 14))
                            
                            Text(viewModel.formatDateToString(playlist.generationTime))
                                .foregroundStyle(Color(.pGray2))
                                .font(.pretendard(weight: .regular400, size: 14))
                                .padding(.bottom, 14)
                        }
                    }
                }
            }
        }
    }
}
