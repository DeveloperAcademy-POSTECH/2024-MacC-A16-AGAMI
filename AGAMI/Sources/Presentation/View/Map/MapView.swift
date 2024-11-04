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

    var body: some View {
        MKMapViewWrapper(viewModel: viewModel)
            .ignoresSafeArea()
            .onAppear {
                viewModel.fecthPlaylists()
            }
    }
}
