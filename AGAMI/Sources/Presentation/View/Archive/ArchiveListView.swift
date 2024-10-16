//
//  ArchiveListView.swift
//  AGAMI
//
//  Created by 박현수 on 10/14/24.
//

import SwiftUI

struct ArchiveListView: View {
    @State var viewModel: ArchiveListViewModel = ArchiveListViewModel()
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
        .safeAreaPadding(.horizontal, 16)
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: ""
        )
    }
}

//private struct ArchiveList: View {
//    @Bindable var viewModel: ArchiveListViewModel
//    let size: CGSize
//    let animationID: Namespace.ID
//
//    var body: some View {
//        ScrollView(showsIndicators: false) {
//            LazyVStack(spacing: -size.width / 2) {
//                ForEach(0..<100, id: \.self) { index in
//                    ArchiveListCell(
//                        viewModel: viewModel,
//                        index: index,
//                        size: size,
//                        animationID: animationID
//                    )
//                }
//            }
//            .scrollTargetLayout()
//        }
//        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
//        .scrollPosition(id: $viewModel.currentId)
//        .safeAreaPadding(.vertical, (size.height - size.width) / 2)
//        .blur(radius: viewModel.selectedCard != nil ? 2 : 0)
//    }
//}

private struct ArchiveList: View {
    @Bindable var viewModel: ArchiveListViewModel
    let size: CGSize
    let animationID: Namespace.ID
    var verticalSpacing: CGFloat { size.width / 3 }

    var body: some View {

        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: verticalSpacing) {
                ForEach(0..<100, id: \.self) { index in
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
        .safeAreaPadding(.vertical, (size.height - size.width) / 2)
        .blur(radius: viewModel.selectedCard != nil ? 2 : 0)
    }
}

private struct ArchiveListCell: View {
    let viewModel: ArchiveListViewModel
    let index: Int
    let size: CGSize
    let animationID: Namespace.ID
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
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 10)
        .matchedGeometryEffect(id: index, in: animationID)
        .onTapGesture {
//            if viewModel.isCurrent(index) {
                withAnimation {
                    viewModel.setSelectedCard(index)
                }
//            }
        }
    }
}

private struct PopupView: View {
    @Environment(ArchiveCoordinator.self) var coord

    let viewModel: ArchiveListViewModel
    let size: CGSize
    let animationID: Namespace.ID

    var body: some View {
        if let selected = viewModel.selectedCard {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.selectedCard = nil
                    }

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
                        coord.push(view: .playlistView)
                    }
                    .padding(.top, 50)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ArchiveListView()
        .environment(ArchiveCoordinator())
}
