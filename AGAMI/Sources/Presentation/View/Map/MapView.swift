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
    @State private var mapCoord: MapCoordinator = MapCoordinator()
    @Environment(SologCoordinator.self) private var sologCoord
    @Environment(\.scenePhase) private var scenePhase

    init(viewModel: MapViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $mapCoord.path) {
            MKMapViewWrapper(viewModel: viewModel)
                .onAppearAndActiveCheckUserValued(scenePhase)
                .task { await viewModel.requestCurrentLocation() }
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("기록 지도")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            sologCoord.dismissSheet()
                        } label: {
                            Text("닫기")
                                .font(.notoSansKR(weight: .regular400, size: 17))
                                .foregroundStyle(Color(.sButton))
                        }
                    }
                }
                .navigationDestination(for: MapRoute.self) { route in
                    mapCoord.build(route: route)
                }
        }
        .environment(mapCoord)

    }
}
