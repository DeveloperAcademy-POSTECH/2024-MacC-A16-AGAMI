//
//  MapView.swift
//  AGAMI
//
//  Created by yegang on 10/12/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var viewModel = MapViewModel.mapServie
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map {
                UserAnnotation()
                
                ForEach(viewModel.places) { place in
                    Marker("찍은 위치 \n\(place.location.latitude), \(place.location.longitude)", coordinate: place.location)
                }
            }
            .mapStyle(.standard)
            
            HStack {
                Button {
                    viewModel.getCurrentLocation()
                } label: {
                    Text("현재 좌표 보기")
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .cornerRadius(10)
                }
                
                Button {
                    viewModel.addCurrentLocation()
                } label: {
                    Text("현재 좌표에 핀 추가")
                }
                .padding()
                .background(.white)
                .foregroundStyle(.black)
                .cornerRadius(10)
            }
            
        }
    }
}

#Preview {
    MapView()
}
