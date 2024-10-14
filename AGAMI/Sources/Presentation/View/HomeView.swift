//
//  HomeView.swift
//  AGAMI
//
//  Created by 박현수 on 10/4/24.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab: TabSelection = .music
    @State var archiveCoord: ArchiveCoordinator = .init()
    var body: some View {
        if #available(iOS 18.0, *) {
            TabView(selection: $selectedTab) {
                Tab("Search", systemImage: "headphones", value: .music) {
                    MusicKitPlaylistView()
                }

                Tab("Archive", systemImage: "archivebox.fill", value: .shazam) {
                    NavigationStack(path: $archiveCoord.path) {
                        archiveCoord.build(view: .listView)
                            .navigationDestination(for: ArchiveView.self) { view in
                                archiveCoord.build(view: view)
                            }
                            .sheet(item: $archiveCoord.sheet) { sheet in
                                archiveCoord.buildSheet(sheet: sheet)
                            }
                            .fullScreenCover(item: $archiveCoord.fullScreenCover) { cover in
                                archiveCoord.buildFullScreenCover(cover: cover)
                            }
                    }
                    .environment(archiveCoord)
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
