//
//  MapView.swift
//  AGAMI
//
//  Created by yegang on 10/12/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var viewModel: MapViewModel
    @State private var mapNavigationPath: NavigationPath = NavigationPath()
    @Environment(PlakeCoordinator.self) private var plakeCoord
    @Environment(\.scenePhase) private var scenePhase

    init(viewModel: MapViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            MKMapViewWrapper(viewModel: viewModel)
                .onAppearAndActiveCheckUserValued(scenePhase)
                .onAppear(perform: viewModel.initializeView)
                .ignoresSafeArea()
                .navigationTitle("기록 지도")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("닫기") {
                            plakeCoord.dismissSheet()
                        }
                        .foregroundStyle(Color(.sButton))
                    }
                }
        }

    }
}
