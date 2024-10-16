//
//  ArchiveListView.swift
//  AGAMI
//
//  Created by 박현수 on 10/14/24.
//

import SwiftUI

struct ArchiveListView: View {
    @State var viewModel: ArchiveListViewModel = ArchiveListViewModel()

    var body: some View {
        GeometryReader {
            let size = $0.size
            
            ArchiveList(
                viewModel: viewModel,
                size: size
            )
        }
        .safeAreaPadding(.horizontal, 16)
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: ""
        )
    }
}

private struct ArchiveList: View {
    @Bindable var viewModel: ArchiveListViewModel
    let size: CGSize

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(0..<100, id: \.self) { index in
                    ArchiveListCell(
                        viewModel: viewModel,
                        index: index,
                        size: size
                    )
                }
                .scrollTransition(.animated, axis: .vertical) { content, phase in
                    content
                        .scaleEffect(phase.isIdentity ? 1 : 0.8)
                        .opacity(phase.isIdentity ? 1 : 0.5)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .scrollPosition(id: $viewModel.currentId)
        .safeAreaPadding(.vertical, 10)

    }
}

private struct ArchiveListCell: View {
    @Environment(ArchiveCoordinator.self) private var coord

    let viewModel: ArchiveListViewModel
    let index: Int
    let size: CGSize
    var verticalSize: CGFloat { size.width / 2 }

    var body: some View {
        AsyncImage(url: viewModel.dummyURL) { image in
            image
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 16))
        } placeholder: {
            Rectangle()
                .fill(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(width: size.width, height: verticalSize)
        .shadow(radius: 10, x: 2, y: 4)
        .onTapGesture {
            withAnimation {
                if viewModel.isCurrent(index) {
                    coord.push(view: .playlistView)
                } else {
                    viewModel.setCurrentId(index)
                }
            }
        }
    }
}

#Preview {
    ArchiveListView()
        .environment(ArchiveCoordinator())
}
