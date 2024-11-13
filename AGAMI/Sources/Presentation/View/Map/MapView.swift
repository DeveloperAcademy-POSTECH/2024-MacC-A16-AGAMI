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
        ZStack {
            MKMapViewWrapper(viewModel: viewModel)
            
            MapController()
                .padding(EdgeInsets(top: 62, leading: 0, bottom: 0, trailing: 24))
        }
        .onAppearAndActiveCheckUserValued(scenePhase)
        .ignoresSafeArea()
        .onAppear {
            viewModel.fecthPlaylists()
            viewModel.getCurrentLocation()
        }
    }
}
