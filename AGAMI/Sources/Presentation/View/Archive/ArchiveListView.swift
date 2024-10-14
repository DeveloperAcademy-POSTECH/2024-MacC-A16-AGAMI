//
//  ArchiveListView.swift
//  AGAMI
//
//  Created by 박현수 on 10/14/24.
//

import SwiftUI

struct ArchiveListView: View {
    @State var viewModel: ArchiveListViewModel = .init()
    @Namespace private var animationID

    var body: some View {
        GeometryReader {
            let size = $0.size

            ZStack(alignment: .top) {

                ArchiveList(
                    viewModel: viewModel,
                    size: size,
                    animationID: animationID
                )

                PopupView(
                    viewModel: viewModel,
                    size: size,
                    animationID: animationID
                )

            }
            .animation(.default, value: viewModel.currentId)
        }
        .safeAreaPadding(.horizontal, 40)
        .onChange(of: viewModel.currentId) { _, _ in
            viewModel.setSelectedCard(nil)
        }
    }
}

private struct ArchiveList: View {
    @Bindable var viewModel: ArchiveListViewModel
    let size: CGSize
    let animationID: Namespace.ID

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(0..<10, id: \.self) { index in
                    ArchiveListCell(
                        viewModel: viewModel,
                        index: index,
                        size: size,
                        animationID: animationID
                    )
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .scrollPosition(id: $viewModel.currentId)
        .safeAreaPadding(.top, (size.height - size.width) / 2)
    }
}

private struct ArchiveListCell: View {
    let viewModel: ArchiveListViewModel
    let index: Int
    let size: CGSize
    let animationID: Namespace.ID

    var body: some View {
        AsyncImage(url: viewModel.dummyURL) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
        .frame(width: size.width, height: size.width)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 10)
        .matchedGeometryEffect(id: index, in: animationID)
        .padding(.vertical, viewModel.getCardsPadding(index, size: size))
        .onTapGesture {
            if viewModel.isCurrent(index) {
                withAnimation {
                    viewModel.setSelectedCard(index)
                }
            } else {
                withAnimation {
                    viewModel.setCurrentId(index)
                }

            }
        }
    }

}

private struct PopupView: View {
    let viewModel: ArchiveListViewModel
    let size: CGSize
    let animationID: Namespace.ID

    var body: some View {
        if let selected = viewModel.selectedCard {
            VStack(spacing: 0) {
                AsyncImage(url: viewModel.dummyURL) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: size.width, height: size.width)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .matchedGeometryEffect(id: selected, in: animationID)
                .onTapGesture {
                    viewModel.setSelectedCard(nil)
                }
                .padding(.top, 50)
                Spacer()
            }
        }
    }

}

#Preview {
    ArchiveListView()
}
