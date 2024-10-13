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
        // Add your own dependencies here:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.11.0")
    ],
    targets: [
            .target(
                name: "AGAMI",
                dependencies: [
                    .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                    .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                    .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                    .product(name: "FirebaseCore", package: "firebase-ios-sdk")
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
