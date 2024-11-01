//
//  CollectionPlaceView.swift
//  AGAMI
//
//  Created by yegang on 10/14/24.
//

import SwiftUI

struct CollectionPlaceView: View {
    @State var viewModel: CollectionPlaceViewModel
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: CollectionPlaceViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color(Color(.pLightGray))
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Text("\(viewModel.playlists.count) 플레이크")
                        .font(.pretendard(weight: .bold700, size: 32))
                        .foregroundStyle(Color(.pBlack))
                    
                    Spacer()
                    
                    Button {
                        dismiss() // 코디네이터 pop으로 수정해야 됨
                        
                    } label: {
                        ZStack(alignment: .center) {
                            Circle()
                                .frame(width: 34, height: 34)
                                .foregroundStyle(Color(.pGray2))
                                .shadow(color: Color(rgbHex: "000000").opacity(0.2), radius: 2, x: 0, y: 1)
                            
                            Image(systemName: "xmark")
                                .foregroundStyle(Color(.pPrimary))
                                .bold()
                        }
                    }
                }
                .padding(EdgeInsets(top: 50, leading: 0, bottom: 33, trailing: 8))

                CollectionPlaceListView(viewModel: viewModel)
                
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .navigationBarBackButtonHidden(true)
        }
    }
}
