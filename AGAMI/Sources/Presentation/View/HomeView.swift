//
//  HomeView.swift
//  AGAMI
//
//  Created by 박현수 on 10/4/24.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab: TabSelection = .music
    var body: some View {
        if #available(iOS 18.0, *) {
            TabView(selection: $selectedTab) {
                Tab("Search", systemImage: "headphones", value: .music) {
                    MusicKitPlaylistView()
                }

                Tab("Archive", systemImage: "archivebox.fill", value: .shazam) {
                    ShazamHomeView()
                }
                
                Tab("Map View", systemImage: "map.fill", value: .map) {
                    MapView()
                }
            }
        } else {
            TabView {
                MusicKitPlaylistView()
                    .tabItem {
                        VStack {
                            Text("Search")
                            Image(systemName: "headphones")
                        }
                    }
                    .tag(TabSelection.music)

                ShazamHomeView()
                    .tabItem {
                        VStack {
                            Text("Archive")
                            Image(systemName: "archivebox.fill")
                        }
                    }
                    .tag(TabSelection.shazam)
                
                MapView()
                    .tabItem {
                        VStack {
                            Text("Map View")
                            Image(systemName: "map.fill")
                        }
                    }
                    .tag(TabSelection.map)
            }
        }
    }
}

extension HomeView {
    enum TabSelection: Hashable {
        case music
        case shazam
        case map
    }
}

#Preview {
    HomeView()
}
