//
//  MapController.swift
//  AGAMI
//
//  Created by yegang on 11/13/24.
//

import SwiftUI

struct MapController: View {
    @State var isShowingOtherPlake: Bool = false
    @State var isReturningToCurrentLocation: Bool = false
    @State var isFetchingVisibleRegionData: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Spacer()
            
            VStack(alignment: .trailing, spacing: 12) {
                Button {
                    isShowingOtherPlake.toggle()
                } label: {
                    Circle()
                        .frame(maxWidth: 44, maxHeight: 44)
                        .foregroundStyle(isShowingOtherPlake ? Color(.pPrimary) : Color(.pWhite))
                        .overlay(
                            Text("My")
                                .font(.pretendard(weight: .medium500, size: 16))
                                .foregroundStyle(isShowingOtherPlake ? Color(.pWhite) : Color(.pPrimary))
                        )
                }
                
                Button {
                    isReturningToCurrentLocation.toggle()
                } label: {
                    Circle()
                        .frame(maxWidth: 44, maxHeight: 44)
                        .foregroundStyle(Color(.pWhite))
                        .overlay(
                            Image(systemName: "scope")
                                .resizable()
                                .frame(maxWidth: 28, maxHeight: 28)
                                .foregroundStyle(isReturningToCurrentLocation ? Color(.pPrimary) : Color(.pPrimary).opacity(0.3))
                        )
                }
                
                Button {
                    isFetchingVisibleRegionData.toggle()
                } label: {
                    Circle()
                        .frame(maxWidth: 44, maxHeight: 44)
                        .foregroundStyle(Color(.pWhite))
                        .overlay(
                            Image(systemName: "arrow.counterclockwise")
                                .resizable()
                                .frame(maxWidth: 21, maxHeight: 24)
                                .foregroundStyle(isFetchingVisibleRegionData ? Color(.pPrimary) : Color(.pPrimary).opacity(0.3))
                        )
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    MapController()
}
