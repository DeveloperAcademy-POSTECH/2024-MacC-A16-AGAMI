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
                Tab("Music", systemImage: "music.note", value: .music) {
                    MusicKitPlaylistView()
                }

                Tab("Shazam", systemImage: "shazam.logo", value: .shazam) {
                    ShazamHomeView()
                }
            }
        } else {
            TabView {
                MusicKitPlaylistView()
                    .tabItem {
                        VStack {
                            Text("Music")
                            Image(systemName: "music.note")
                        }
                    }
                    .tag(TabSelection.music)

                ShazamHomeView()
                    .tabItem {
                        VStack {
                            Text("Shazam")
                            Image(systemName: "shazam.logo")
                        }
                    }
                    .tag(TabSelection.shazam)
            }
        }
    }
}

extension HomeView {
    enum TabSelection: Hashable {
        case music
        case shazam
    }
}

#Preview {
    HomeView()
}
