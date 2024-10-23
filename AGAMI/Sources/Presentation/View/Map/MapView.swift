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
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map {
                    ForEach(viewModel.places) { place in
                        Annotation("", coordinate: place.location) {
                            NavigationLink(destination: CollectionPlaceView()) {
                                PlaceMarkerView()
                            }
                        }
                    }
                    
                    UserAnnotation()
                }
                .mapStyle(.standard)
            }
            .onAppear {
                viewModel.requestCurrentLocation()
            }
        }
    }
}

#Preview {
    MapView()
}
