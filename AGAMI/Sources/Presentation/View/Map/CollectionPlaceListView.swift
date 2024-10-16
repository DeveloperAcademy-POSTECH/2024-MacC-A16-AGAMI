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
    private let columnSpacing: CGFloat = 12
    private var columns: [GridItem] {
        [
            GridItem(.flexible(minimum: columnWidth), spacing: columnSpacing),
            GridItem(.flexible(minimum: columnWidth))
        ]
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("울산 울주군 상북면 명촌길천로 23")
                    .font(.system(size: 16, weight: .regular))
                
                Spacer()
            }
            .padding(.leading, 12)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.playList, id: \.self) { place in
                    ZStack {
                        Image(.bear)
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 4)
                        
                        VStack(alignment: .center, spacing: 5) {
                            Spacer()
                            
                            Text(place.address)
                            Text("\(place.date) \(place.time)")
                        }
                        .foregroundStyle(.white)
                        .font(.system(size: 14))
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
    }
}

//#Preview {
//    CollectionPlaceListView()
//}
