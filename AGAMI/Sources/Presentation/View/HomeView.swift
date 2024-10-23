//
//  HomeView.swift
//  AGAMI
//
//  Created by 박현수 on 10/4/24.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State private var viewModel: HomeViewModel = .init()
    @State var archiveCoord: ArchiveCoordinator = .init()
    @State var searchCoordinator: SearchCoordinator = .init()

    var body: some View {
        if #available(iOS 18.0, *) {
            TabView(selection: $viewModel.selectedTab) {
                Tab("Plake", systemImage: "headphones", value: .plake) {
                    NavigationStack(path: $searchCoordinator.path) {
                        searchCoordinator.build(view: .startView)
                            .navigationDestination(for: SearchView.self) { view in
                                searchCoordinator.build(view: view)
                            }
                            .sheet(item: $searchCoordinator.sheet) { sheet in
                                searchCoordinator.buildSheet(sheet: sheet)
                            }
                            .fullScreenCover(item: $searchCoordinator.fullScreenCover) { cover in
                                searchCoordinator.buildFullScreenCover(cover: cover)
                            }
                    }
                    .environment(searchCoordinator)
                }

                Tab("Plakive", systemImage: "archivebox.fill", value: .plakive) {
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

                Tab("Map", systemImage: "map.fill", value: .map) {
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
                            searchCoordinator.buildSheet(sheet: sheet)
                        }
                        .fullScreenCover(item: $searchCoordinator.fullScreenCover) { cover in
                            searchCoordinator.buildFullScreenCover(cover: cover)
                        }
                }
                .environment(searchCoordinator)
                .tabItem {
                    VStack {
                        Text("Plake")
                        Image(systemName: "headphones")
                    }
                }
                .tag(TabSelection.plake)

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
                        Text("Plakive")
                        Image(systemName: "archivebox.fill")
                    }
                }
                .tag(TabSelection.plakive)

                MapView()
                    .tabItem {
                        VStack {
                            Text("Map")
                            Image(systemName: "map.fill")
                        }
                    }
                    .tag(TabSelection.map)
            }
        }
    }
}

#Preview {
    HomeView()
}
