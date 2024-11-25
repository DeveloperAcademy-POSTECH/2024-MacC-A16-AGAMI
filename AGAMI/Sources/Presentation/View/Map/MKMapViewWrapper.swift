//
//  PlaceMarkerView.swift
//  AGAMI
//
//  Created by yegang on 10/14/24.
//

import SwiftUI
import MapKit
import Kingfisher

// MARK: - MKMapView 래퍼
struct MKMapViewWrapper: UIViewRepresentable {
    @Environment(MapCoordinator.self) var coordinator
    var viewModel: MapViewModel

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()

        mapView.delegate = context.coordinator

        mapView.register(BubbleAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(BubbleAnnotationView.self))
        mapView.register(ClusterBubbleAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(ClusterBubbleAnnotationView.self))

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)

        let annotations = viewModel.playlists.map { playlist -> PlaylistAnnotation in
            let annotation = PlaylistAnnotation(playlist: playlist)
            return annotation
        }
        
        if let currentLocation = viewModel.currentLocationCoordinate2D {
            let region = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 500, longitudinalMeters: 500)
            uiView.setRegion(region, animated: false)
        }

        uiView.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MKMapViewWrapper

        init(_ parent: MKMapViewWrapper) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKClusterAnnotation {
                let identifier = NSStringFromClass(ClusterBubbleAnnotationView.self)
                var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? ClusterBubbleAnnotationView

                if clusterView == nil {
                    clusterView = ClusterBubbleAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                } else {
                    clusterView?.annotation = annotation
                }

                clusterView?.clusteringIdentifier = "playlist"

                return clusterView
            }

            // PlaylistAnnotation 처리
            if annotation is PlaylistAnnotation {
                let identifier = NSStringFromClass(BubbleAnnotationView.self)
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? BubbleAnnotationView

                if annotationView == nil {
                    annotationView = BubbleAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                } else {
                    annotationView?.annotation = annotation
                }

                annotationView?.clusteringIdentifier = "playlist"

                return annotationView
            }

            return nil
        }

        // 어노테이션 선택 시
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let clusterAnnotation = view.annotation as? MKClusterAnnotation,
               let clusterView = view as? ClusterBubbleAnnotationView {

                let playlistAnnotations = clusterAnnotation.memberAnnotations.compactMap { $0 as? PlaylistAnnotation }
                let playlists = playlistAnnotations.map { $0.playlist }.sorted { $0.generationTime < $1.generationTime }

                Task { @MainActor in
                    HapticService.shared.playSimpleHaptic()
                    clusterView.setSelected(true, animated: true)
                    let collectionPlaceViewModel = CollectionPlaceViewModel(playlists: playlists)
                    self.parent.coordinator.push(route: .collectionPlaceView(viewModel: collectionPlaceViewModel))
                }

            } else if let playlistAnnotation = view.annotation as? PlaylistAnnotation,
                      let bubbleView = view as? BubbleAnnotationView {

                let playlist = playlistAnnotation.playlist

                Task { @MainActor in
                    HapticService.shared.playSimpleHaptic()
                    bubbleView.setSelected(true, animated: true)
                    let collectionPlaceViewModel = CollectionPlaceViewModel(playlists: [playlist])
                    self.parent.coordinator.push(route: .collectionPlaceView(viewModel: collectionPlaceViewModel))
                }

            }
        }
    }
}

// MARK: - MKAnnotation
final class PlaylistAnnotation: MKPointAnnotation {
    let playlist: PlaylistModel

    init(playlist: PlaylistModel) {
        self.playlist = playlist
        super.init()
        self.coordinate = CLLocationCoordinate2D(latitude: playlist.latitude, longitude: playlist.longitude)
        self.title = playlist.playlistName
    }
}

// MARK: - Clustering되지 않은 Annotation 래퍼
final class BubbleAnnotationView: MKAnnotationView {
    private var hostingController: UIHostingController<BubbleView>?

    override var annotation: MKAnnotation? { didSet { configure() } }

    private func configure() {
        guard let playlistAnnotation = annotation as? PlaylistAnnotation else { return }

        let bubbleView = BubbleView(playlist: playlistAnnotation.playlist, isSelected: isSelected)

        if let hostingController = hostingController {
            hostingController.rootView = bubbleView
        } else {
            let hostingController = UIHostingController(rootView: bubbleView)
            hostingController.view.backgroundColor = .clear

            addSubview(hostingController.view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                hostingController.view.centerXAnchor.constraint(equalTo: centerXAnchor),
                hostingController.view.centerYAnchor.constraint(equalTo: centerYAnchor),
                hostingController.view.widthAnchor.constraint(equalToConstant: 65),
                hostingController.view.heightAnchor.constraint(equalToConstant: 75)
            ])

            self.hostingController = hostingController
        }

        self.bounds = CGRect(x: 0, y: 0, width: 65, height: 75)
        self.centerOffset = CGPoint(x: 0, y: -37.5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        configure()
    }
}

// MARK: - Clusteringe된 Annotation 래퍼
final class ClusterBubbleAnnotationView: MKAnnotationView {
    private var hostingController: UIHostingController<ClusterBubbleView>?

    override var annotation: MKAnnotation? { didSet { configure() } }

    private func configure() {
        guard let clusterAnnotation = annotation as? MKClusterAnnotation else { return }

        let playlistAnnotations = clusterAnnotation.memberAnnotations.compactMap { $0 as? PlaylistAnnotation }
        let playlists = playlistAnnotations.map { $0.playlist }

        let count = playlists.count
        let clusterBubbleView = ClusterBubbleView(playlists: playlists, count: count, isSelected: isSelected)

        if let hostingController = hostingController {
            hostingController.rootView = clusterBubbleView
        } else {
            let hostingController = UIHostingController(rootView: clusterBubbleView)
            hostingController.view.backgroundColor = .clear

            addSubview(hostingController.view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                hostingController.view.centerXAnchor.constraint(equalTo: centerXAnchor),
                hostingController.view.centerYAnchor.constraint(equalTo: centerYAnchor),
                hostingController.view.widthAnchor.constraint(equalToConstant: 65),
                hostingController.view.heightAnchor.constraint(equalToConstant: 75)
            ])

            self.hostingController = hostingController
        }

        self.bounds = CGRect(x: 0, y: 0, width: 65, height: 75)
        self.centerOffset = CGPoint(x: 0, y: -37.5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        configure()
    }
}

// MARK: - 클러스터링 되지 않은 SwiftUI 어노테이션 뷰
struct BubbleView: View {
    let playlist: PlaylistModel
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 65, height: 65)
                    .foregroundStyle(Color(isSelected ? .sTitleText : .sWhite))

                KFImage(URL(string: playlist.photoURL))
                    .resizable()
                    .cancelOnDisappear(true)
                    .placeholder {
                        Rectangle()
                            .fill(Color(.sMain).shadow(.inner(color: Color(.sBlack).opacity(0.2), radius: 2)))
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            Triangle()
                .frame(width: 10, height: 10)
                .foregroundStyle(Color(isSelected ? .sTitleText : .sWhite))
        }
    }
}

// MARK: - 클러스터링된 SwiftUI 어노테이션 뷰
struct ClusterBubbleView: View {
    let playlists: [PlaylistModel]
    let count: Int
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 65, height: 65)
                    .foregroundStyle(Color(isSelected ? .sTitleText : .sWhite))

                KFImage(URL(string: playlists.first?.photoURL ?? ""))
                    .resizable()
                    .cancelOnDisappear(true)
                    .placeholder {
                        Rectangle()
                            .fill(Color(.sMain).shadow(.inner(color: Color(.sBlack).opacity(0.2), radius: 2)))
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                VStack(alignment: .trailing) {
                    HStack {
                        Spacer()
                        Text("\(count)")
                            .font(.pretendard(weight: .semiBold600, size: 16))
                            .foregroundStyle(Color(.sWhite))
                            .padding(8)
                            .background(Color(.sTitleText))
                            .clipShape(Circle())
                            .offset(x: 10, y: -10)
                    }
                    Spacer()
                }
            }
            Triangle()
                .frame(width: 10, height: 10)
                .foregroundStyle(Color(isSelected ? .sTitleText : .sWhite))
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let topLeftPoint = CGPoint(x: rect.minX, y: rect.minY)
        let topRightPoint = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomCenterPoint = CGPoint(x: rect.midX, y: rect.maxY)

        path.move(to: topLeftPoint)
        path.addLine(to: topRightPoint)
        path.addLine(to: bottomCenterPoint)
        path.addLine(to: topLeftPoint)

        return path
    }
}
