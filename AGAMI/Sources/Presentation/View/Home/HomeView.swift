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
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PlakeCoordinator.self) private var coordinator
    @Environment(ListCellPlaceholderModel.self) private var listCellPlaceholder

    var body: some View {
        ZStack(alignment: .bottom) {
            if viewModel.selectedTab == .plake {
                coordinator.build(route: .listView)
            } else {
                coordinator.build(route: .mapView)
            }

            HStack(spacing: 0) {
                Spacer()

                Image(systemName: "person.circle.fill")
                    .font(.system(size: 39, weight: .regular))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color(.pWhite), Color(.pGray3))
                    .onTapGesture {
                        coordinator.push(route: .accountView)
                        viewModel.simpleHaptic()
                    }

                Capsule()
                    .foregroundStyle(Color(.pGray2))
                    .frame(width: 179, height: 39)
                    .overlay(alignment: .leading) {
                        ZStack {
                            Capsule()
                                .foregroundStyle(Color(.pWhite))
                                .frame(width: 88, height: 35)
                                .shadow(color: Color(.pBlack).opacity(0.12), radius: 8, x: 0, y: 3)
                                .offset(x: viewModel.selectedTab == .plake ? -43 : 43)
                                .animation(.easeInOut(duration: 0.3), value: viewModel.selectedTab)

                            HStack(spacing: 0) {
                                Text("Plake")
                                    .font(.pretendard(weight: .semiBold600, size: 13))
                                    .kerning(-0.08)
                                    .foregroundStyle(viewModel.selectedTab == .plake ? Color(.pPrimary) : Color(.pGray1))
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.selectedTab = .plake
                                        }
                                        viewModel.simpleHaptic()
                                    }
                                Spacer()

                                Text("Map")
                                    .font(.pretendard(weight: .semiBold600, size: 13))
                                    .kerning(-0.08)
                                    .foregroundStyle(viewModel.selectedTab == .map ? Color(.pPrimary) : Color(.pGray1))
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.selectedTab = .map
                                        }
                                        viewModel.simpleHaptic()
                                    }
                            }
                            .padding(EdgeInsets(top: 0, leading: 29.25, bottom: 0, trailing: 32.25))
                        }
                    }
                    .padding(.horizontal, 29)

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 39, weight: .regular))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color(.pWhite), Color(.pPrimary))
                    .onTapGesture {
                        coordinator.push(route: .newPlakeView)
                        viewModel.simpleHaptic()
                    }

                Spacer()
            }
            .background(Color(.clear))
            .padding(.bottom, 50)

        }
        .onAppearAndActiveCheckUserValued(scenePhase)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    HomeView()
}
