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
                        "UIImageName": ""
                    ],
                    "NSAppleMusicUsageDescription": "플레이리스트 추가를 위해 Apple Music 라이브러리에 접근합니다.",
                    "NSMicrophoneUsageDescription": "Shazam 음악 인식을 위해 마이크에 접근합니다.",
                    "NSPhotoLibraryUsageDescription": "플레이리스트 사진 추가를 위해 사진 라이브러리에 접근합니다.",
                    "NSCameraUsageDescription": "플레이리스트 사진 추가를 위해 카메라에 접근합니다.",
                    "Privacy - Location When In Use Usage Description": "위치 권한 받아오기.",
                    "NSLocationUsageDescription": "근처 장소 탐색을 위해 사용자의 위치 정보에 접근합니다.",
                    "NSLocationWhenInUseUsageDescription": "근처 장소 탐색을 위해 사용자의 위치 정보에 접근합니다.",
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait",
                        "UIInterfaceOrientationPortraitUpsideDown"
                    ],
                    "UISupportedInterfaceOrientations~ipad": [
                        "UIInterfaceOrientationPortrait",
                        "UIInterfaceOrientationPortraitUpsideDown"
                    ],
                    "UIRequiresFullScreen": true
                ]
            ),
            sources: ["AGAMI/Sources/**"],
            resources: ["AGAMI/Resources/**"],
            entitlements: "Entitlements/AGAMI.entitlements",
            scripts: [
                .swiftLintShell
            ],
            dependencies: [
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebaseAuth"),
                .external(name: "FirebaseFirestore"),
                .external(name: "FirebaseStorage")
            ]
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
        )
    ]
)

extension TargetScript {
    static let swiftLintShell = TargetScript.pre(
        path: .relativeToRoot("Scripts/SwiftLintRunScript.sh"),
        name: "swiftLintShell",
        basedOnDependencyAnalysis: false
    )
}
