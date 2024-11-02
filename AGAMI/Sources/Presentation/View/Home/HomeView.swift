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
    @State private var plakeCoordinator: PlakeCoordinator = .init()
    @State private var searchCoordinator: SearchCoordinator = .init()
    @State private var mapCoordinator: MapCoordinator = .init()
    
    var body: some View {
        if #available(iOS 18.0, *) {
            TabView(selection: $viewModel.selectedTab) {
                Tab("Plake", systemImage: "rectangle.stack.fill", value: .plake) {
                    NavigationStack(path: $plakeCoordinator.path) {
                        plakeCoordinator.build(route: .listView)
                            .navigationDestination(for: PlakeRoute.self) { view in
                                plakeCoordinator.build(route: view)
                            }
                            .sheet(item: $plakeCoordinator.sheet) { sheet in
                                plakeCoordinator.buildSheet(sheet: sheet)
                            }
                            .fullScreenCover(item: $plakeCoordinator.fullScreenCover) { cover in
                                plakeCoordinator.buildFullScreenCover(cover: cover)
                            }
                    }
                    .environment(plakeCoordinator)
                }
                
                Tab("Map", systemImage: "bubble.middle.bottom.fill", value: .map) {
                    NavigationStack(path: $mapCoordinator.path) {
                        mapCoordinator.build(route: .mapView)
                            .navigationDestination(for: MapRoute.self) { view in
                                mapCoordinator.build(route: view)
                            }
                            .sheet(item: $mapCoordinator.sheet) { sheet in
                                mapCoordinator.buildSheet(sheet: sheet)
                            }
                            .fullScreenCover(item: $mapCoordinator.fullScreenCover) { cover in
                                mapCoordinator.buildFullScreenCover(cover: cover)
                            }
                    }
                    .environment(mapCoordinator)
                }
                
                Tab("Account", systemImage: "person.fill", value: .account) {
                    EmptyView()
                }
            }
        } else {
            TabView {
                NavigationStack(path: $plakeCoordinator.path) {
                    plakeCoordinator.build(route: .listView)
                        .navigationDestination(for: PlakeRoute.self) { view in
                            plakeCoordinator.build(route: view)
                        }
                        .sheet(item: $plakeCoordinator.sheet) { sheet in
                            plakeCoordinator.buildSheet(sheet: sheet)
                        }
                        .fullScreenCover(item: $plakeCoordinator.fullScreenCover) { cover in
                            plakeCoordinator.buildFullScreenCover(cover: cover)
                        }
                }
                .environment(plakeCoordinator)
                .tabItem {
                    VStack {
                        Text("Plakive")
                        Image(systemName: "rectangle.stack.fill")
                    }
                }
                .tag(TabSelection.plake)
                
                NavigationStack(path: $mapCoordinator.path) {
                    mapCoordinator.build(route: .mapView)
                        .navigationDestination(for: MapRoute.self) { view in
                            mapCoordinator.build(route: view)
                        }
                        .sheet(item: $mapCoordinator.sheet) { sheet in
                            mapCoordinator.buildSheet(sheet: sheet)
                        }
                        .fullScreenCover(item: $mapCoordinator.fullScreenCover) { cover in
                            mapCoordinator.buildFullScreenCover(cover: cover)
                        }
                }
                .environment(mapCoordinator)
                .tabItem {
                    VStack {
                        Text("Map")
                        Image(systemName: "bubble.middle.bottom.fill")
                    }
                }
                .tag(TabSelection.map)
                
                EmptyView()
                    .tabItem {
                        VStack {
                            Text("Account")
                            Image(systemName: "person.fill")
                        }
                    }
                    .tag(TabSelection.account)
            }
        }
    }
}

#Preview {
    HomeView()
}
