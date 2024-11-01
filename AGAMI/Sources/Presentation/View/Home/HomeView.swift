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
    @State var plakeCoord: PlakeCoordinator = .init()
    @State var searchCoordinator: SearchCoordinator = .init()

    var body: some View {
        if #available(iOS 18.0, *) {
            TabView(selection: $viewModel.selectedTab) {
                Tab("Plake", systemImage: "rectangle.stack.fill", value: .plake) {
                    NavigationStack(path: $plakeCoord.path) {
                        plakeCoord.build(view: .listView)
                            .navigationDestination(for: PlakeView.self) { view in
                                plakeCoord.build(view: view)
                            }
                            .sheet(item: $plakeCoord.sheet) { sheet in
                                plakeCoord.buildSheet(sheet: sheet)
                            }
                            .fullScreenCover(item: $plakeCoord.fullScreenCover) { cover in
                                plakeCoord.buildFullScreenCover(cover: cover)
                            }
                    }
                    .environment(plakeCoord)
                }

                Tab("Map", systemImage: "map.fill", value: .map) {
                    MapView()
                }

                Tab("Archive", systemImage: "person.fill", value: .account) {
                    EmptyView()
                }
            }
        } else {
            TabView {
                NavigationStack(path: $plakeCoord.path) {
                    plakeCoord.build(view: .listView)
                        .navigationDestination(for: PlakeView.self) { view in
                            plakeCoord.build(view: view)
                        }
                        .sheet(item: $plakeCoord.sheet) { sheet in
                            plakeCoord.buildSheet(sheet: sheet)
                        }
                        .fullScreenCover(item: $plakeCoord.fullScreenCover) { cover in
                            plakeCoord.buildFullScreenCover(cover: cover)
                        }
                }
                .environment(plakeCoord)
                .tabItem {
                    VStack {
                        Text("Plakive")
                        Image(systemName: "rectangle.stack.fill")
                    }
                }
                .tag(TabSelection.plake)

                MapView()
                    .tabItem {
                        VStack {
                            Text("Map")
                            Image(systemName: "map.fill")
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
