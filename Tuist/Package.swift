// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:]
    )
#endif

let package = Package(
    name: "AGAMI",
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.22.0"),
        .package(url: "https://github.com/Peter-Schorn/SpotifyAPI.git", from: "3.0.3"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.5.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.22.0"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "8.1.0")
    ],
    targets: [
            .target(
                name: "AGAMI",
                dependencies: [
                    .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                    .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                    .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                    .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                    .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                    .product(name: "SpotifyAPI", package: "SpotifyAPI"),
                    .product(name: "KeychainAccess", package: "KeychainAccess"),
                    .product(name: "Lottie", package: "lottie-ios")
                ],
                path: "AGAMI/Sources"
            ),
            .testTarget(
                name: "AGAMITests",
                dependencies: ["AGAMI"],
                path: "AGAMI/Tests"
            )
        ]
)
