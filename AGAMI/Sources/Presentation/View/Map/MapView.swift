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
//    let playlist: PlaylistModel
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map {
                    ForEach(viewModel.playlists, id: \.playlistID) { playlist in
                        let location = CLLocationCoordinate2D(latitude: playlist.latitude, longitude: playlist.longitude)
                        
                        Annotation("", coordinate: location) {
                            NavigationLink(destination: CollectionPlaceView(viewModel: viewModel, playlist: playlist)) {
                                PlaceMarkerView(
                                    viewModel: viewModel,
                                    playlist: playlist
                                )
                            }
                        }
                    }
                    
                    UserAnnotation()
                }
                .mapStyle(.standard)
            }
            .onAppear {
                viewModel.fecthPlaylists()
            }
        }
    }
}

//#Preview {
//    MapView()
//}
