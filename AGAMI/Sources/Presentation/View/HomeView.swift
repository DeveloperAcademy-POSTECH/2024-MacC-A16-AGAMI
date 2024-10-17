//
//  HomeView.swift
//  AGAMI
//
//  Created by 박현수 on 10/4/24.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab: TabSelection = .search
    @State var archiveCoord: ArchiveCoordinator = .init()
    @State var searchCoordinator: SearchCoordinator = .init()
    
    var body: some View {
        if #available(iOS 18.0, *) {
            TabView(selection: $selectedTab) {
                Tab("Search", systemImage: "headphones", value: .search) {
                    NavigationStack(path: $searchCoordinator.path) {
                        searchCoordinator.build(view: .startView)
                            .navigationDestination(for: SearchView.self) { view in
                                searchCoordinator.build(view: view)
                            }
                            .sheet(item: $searchCoordinator.sheet) { sheet in
                                searchCoordinator.buildSheet(sheet: sheet, diggingList: [])
                            }
                            .fullScreenCover(item: $searchCoordinator.fullScreenCover) { cover in
                                searchCoordinator.buildFullScreenCover(cover: cover)
                            }
                    }
                    .environment(searchCoordinator)
                }

                Tab("Archive", systemImage: "archivebox.fill", value: .archive) {
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
                NavigationStack(path: $searchCoordinator.path) {
                    searchCoordinator.build(view: .startView)
                        .navigationDestination(for: SearchView.self) { view in
                            searchCoordinator.build(view: view)
                        }
                        .sheet(item: $searchCoordinator.sheet) { sheet in
                            searchCoordinator.buildSheet(sheet: sheet, diggingList: [])
                        }
                        .fullScreenCover(item: $searchCoordinator.fullScreenCover) { cover in
                            searchCoordinator.buildFullScreenCover(cover: cover)
                        }
                }
                .environment(searchCoordinator)
                .tabItem {
                    VStack {
                        Text("Search")
                        Image(systemName: "headphones")
                    }
                }
                .tag(TabSelection.search)
                
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
                .tabItem {
                    VStack {
                        Text("Archive")
                        Image(systemName: "archivebox.fill")
                    }
                }
                .tag(TabSelection.archive)

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
        case search
        case archive
        case map
    }
}

#Preview {
    HomeView()
}
