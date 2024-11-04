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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                if viewModel.selectedTab == .plake {
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
                } else {
                    NavigationStack(path: $plakeCoordinator.path) {
                        plakeCoordinator.build(route: .mapView)
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
                
                if plakeCoordinator.path.isEmpty {
                    HStack(spacing: 0) {
                        Spacer()
                        
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 39, weight: .regular))
                            .foregroundStyle(Color(.pGray3))
                            .onTapGesture {
                                plakeCoordinator.push(route: .accountView)
                            }
                        
                        Capsule()
                            .foregroundStyle(Color(.pGray2))
                            .frame(width: 179, height: 39)
                            .overlay {
                                HStack(spacing: 0) {
                                    Text("Plake")
                                        .font(.pretendard(weight: .semiBold600, size: 13))
                                        .kerning(-0.08)
                                        .foregroundStyle(Color(.pGray1))
                                        .onTapGesture {
                                            withAnimation {
                                                viewModel.selectedTab = .plake
                                            }
                                        }
                                    Spacer()
                                    
                                    Text("Map")
                                        .font(.pretendard(weight: .semiBold600, size: 13))
                                        .kerning(-0.08)
                                        .foregroundStyle(Color(.pGray1))
                                        .onTapGesture {
                                            withAnimation {
                                                viewModel.selectedTab = .map
                                            }
                                        }
                                }
                                .padding(EdgeInsets(top: 0, leading: 29.25, bottom: 0, trailing: 32.25))
                                .overlay(alignment: viewModel.selectedTab == .plake ? .leading : .trailing) {
                                    Capsule()
                                        .foregroundStyle(Color(.pWhite))
                                        .frame(width: 88, height: 35)
                                        .shadow(color: Color(.pBlack).opacity(0.12), radius: 8, x: 0, y: 3)
                                        .overlay {
                                            Text(viewModel.selectedTab.title)
                                                .font(.pretendard(weight: .semiBold600, size: 13))
                                                .kerning(-0.08)
                                                .foregroundStyle(Color(.pPrimary))
                                        }
                                        .padding(.horizontal, 2)
                                }
                            }
                            .padding(.horizontal, 29)
                        
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 39, weight: .regular))
                            .foregroundStyle(Color(.pPrimary))
                            .onTapGesture {
                                plakeCoordinator.push(route: .newPlakeView)
                            }
                        
                        Spacer()
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    HomeView()
}
