import ProjectDescription

let project = Project(
    name: "AGAMI",
    targets: [
        .target(
            name: "AGAMI",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "io.tuist.AGAMI",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["AGAMI/Sources/**"],
            resources: ["AGAMI/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "AGAMITests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "io.tuist.AGAMITests",
            infoPlist: .default,
            sources: ["AGAMI/Tests/**"],
            resources: [],
            dependencies: [.target(name: "AGAMI")]
        ),
    ]
)
