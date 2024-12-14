//
//  PlaylistMapView.swift
//  AGAMI
//
//  Created by 박현수 on 11/25/24.
//

import SwiftUI
import MapKit

struct PlaylistMapView: View {
    @Environment(SologCoordinator.self) private var coordinator
    let coordinate: CLLocationCoordinate2D
    let playlist: PlaylistModel

    init(playlist: PlaylistModel) {
        self.playlist = playlist
        self.coordinate = .init(latitude: playlist.latitude, longitude: playlist.longitude)
    }

    var body: some View {
        NavigationStack {
            Map {
                Annotation("", coordinate: coordinate) {
                    BubbleView(playlist: playlist, isSelected: true)
                }
            }
            .navigationTitle("기록 지도")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        coordinator.dismissSheet()
                    } label: {
                        Text("닫기")
                            .foregroundStyle(Color(.sButton))
                    }
                }
            }
        }
    }
}
