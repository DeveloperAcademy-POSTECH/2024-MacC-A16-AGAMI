//
//  MapView.swift
//  AGAMI
//
//  Created by yegang on 10/12/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var viewModel = MapViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map() {
                ForEach(viewModel.places) { place in
                    Annotation("", coordinate: place.location) {
                        PlaceMarkerView()
                    }
                }
                
                UserAnnotation()
            }
            .mapStyle(.standard)
            .edgesIgnoringSafeArea(.all)
            
            Button {
                viewModel.addCurrentLocation()
                print(viewModel.places.count)
                
            } label: {
                Text("좌표찍기")
                    .padding()
                    .background(.white)
                    .foregroundStyle(.black)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            viewModel.requestCurrentLocation()
        }
    }
}

#Preview {
    MapView()
}
