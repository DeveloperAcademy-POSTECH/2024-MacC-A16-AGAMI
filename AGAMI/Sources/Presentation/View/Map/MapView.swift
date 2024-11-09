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
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        MKMapViewWrapper(viewModel: viewModel)
            .onAppearAndActiveCheckUserValued(scenePhase)
            .ignoresSafeArea()
            .onAppear {
                viewModel.fecthPlaylists()
                viewModel.getCurrentLocation()
            }
    }
}
