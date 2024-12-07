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
    @Environment(PlakeCoordinator.self) private var plakeCoord
    @Environment(\.scenePhase) private var scenePhase

    init(viewModel: MapViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $mapCoord.path) {
            MKMapViewWrapper(viewModel: viewModel)
                .ignoresSafeArea(edges: .bottom)
                .onAppearAndActiveCheckUserValued(scenePhase)
                .onAppear(perform: viewModel.requestCurrentLocation)
                .navigationTitle("기록 지도")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            plakeCoord.dismissSheet()
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
