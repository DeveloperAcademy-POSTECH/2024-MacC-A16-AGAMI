//
//  SearchView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/15/24.
//

import SwiftUI

struct SearchView: View {
    @State private var isFind: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Button(action: {
                    isFind.toggle()
                }, label: {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.gray.opacity(0.3))
                        .overlay {
                            Text(isFind ? "서치 중" : "서치 시작")
                        }
                        .frame(width: 260, height: 100)
                })
            }
            .sheet(isPresented: $isFind, content: {
                SearchPlaylistModalView(navigationTitle: "플레이리스트")
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing, content: {
                    NavigationLink(destination: {
                        SearchWritingView()
                    }, label: {
                        Text("다음")
                    })
                })
            }
            .navigationTitle("Search")
        }
    }
}

#Preview {
    SearchView()
}
