//
//  MapView.swift
//  AGAMI
//
//  Created by yegang on 10/12/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var viewModel: MapViewModel = MapViewModel()

    var body: some View 
        NavigationStack {
            MKMapViewWrapper(viewModel: viewModel)
                .ignoresSafeArea(edges: .top)
//                .background(ignoresSafeAreaEdges: .top)
                .onAppear {
                    viewModel.fecthPlaylists()
                }
        }
    }
}
