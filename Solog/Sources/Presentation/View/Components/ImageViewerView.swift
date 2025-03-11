//
//  ImageViewerView.swift
//  AGAMI
//
//  Created by 박현수 on 11/21/24.
//

import SwiftUI
import PhotosUI

struct ImageViewerView: View {
    @Environment(SologCoordinator.self) private var coordinator
    @State private var image: UIImage?
    @State private var isDownloading = false
    let urlString: String

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer()
                    if let image = image {
                        PinchableImageView(image: image)
                    } else {
                        ProgressView("다운로드 중...")
                    }
                    Spacer()
                }
                if isDownloading { ProgressView("다운로드 중...") }
            }
            .onAppear(perform: loadImage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.sBlack))
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        coordinator.dismissFullScreenCover()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color(.sMain))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await savePhotoToAlbum() }
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundStyle(Color(.sMain))
                    }
                }
            }
        }
    }

    private func loadImage() {
        Task {
            guard let url = URL(string: urlString),
                  let (data, _) = try? await URLSession.shared.data(from: url),
                  let image = UIImage(data: data)
            else { return }
            await MainActor.run { self.image = image }
        }
    }

    private func savePhotoToAlbum() async {
        isDownloading = true
        defer { isDownloading = false }

        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard let image = image,
              status == .authorized || status == .limited
        else { return }

        await MainActor.run {
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
}

private struct PinchableImageView: UIViewRepresentable {
    let image: UIImage

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        configureUIScrollView(scrollView)

        let imageView = makeUIImageView()
        imageView.frame = scrollView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        scrollView.addSubview(imageView)
        context.coordinator.imageView = imageView
        context.coordinator.scrollView = scrollView

        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.imageView?.image = image
        centerContent(uiView, context.coordinator.imageView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func configureUIScrollView(_ scrollView: UIScrollView) {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
    }

    private func makeUIImageView() -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true

        return imageView
    }

    private func centerContent(_ scrollView: UIScrollView, _ imageView: UIImageView?) {
        guard let imageView = imageView else { return }
        let imageSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size

        let verticalInset = max(0, (scrollViewSize.height - imageSize.height) / 2)
        let horizontalInset = max(0, (scrollViewSize.width - imageSize.width) / 2)

        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        var imageView: UIImageView?
        weak var scrollView: UIScrollView?

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard let imageView = imageView else { return }

            let verticalInset = max(0, (scrollView.bounds.size.height - imageView.frame.height) / 2)
            let horizontalInset = max(0, (scrollView.bounds.size.width - imageView.frame.width) / 2)

            scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
        }

        @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
            guard let scrollView = scrollView, let imageView = imageView else { return }

            if scrollView.zoomScale == scrollView.minimumZoomScale {
                let tapLocation = sender.location(in: imageView)
                let zoomRect = calculateZoomRect(scale: scrollView.maximumZoomScale, center: tapLocation, scrollView: scrollView)
                scrollView.zoom(to: zoomRect, animated: true)
            } else {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            }
        }

        private func calculateZoomRect(scale: CGFloat, center: CGPoint, scrollView: UIScrollView) -> CGRect {
            let width = scrollView.bounds.width / scale
            let height = scrollView.bounds.height / scale
            let originX = center.x - width / 2
            let originY = center.y - height / 2
            return CGRect(x: originX, y: originY, width: width, height: height)
        }
    }
}
