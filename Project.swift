import ProjectDescription

let fonts = [
    "Pretendard-Thin.otf",
    "Pretendard-ExtraLight.otf",
    "Pretendard-Light.otf",
    "Pretendard-Regular.otf",
    "Pretendard-Medium.otf",
    "Pretendard-SemiBold.otf",
    "Pretendard-Bold.otf",
    "Pretendard-ExtraBold.otf",
    "Pretendard-Black.otf"
]

let project = Project(
    name: "AGAMI",
    settings:
        .settings(
            base: [
                "OTHER_LDFLAGS": ["-all_load -Objc"],
                "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor"
            ],
            configurations: [
                .debug(name: "Debug", xcconfig: "Configurations/Debug.xcconfig"),
                .release(name: "Release", xcconfig: "Configurations/Release.xcconfig")
            ]
        ),
    targets: [
        .target(
            name: "AGAMI",
            destinations: [.iPhone],
            product: .app,
            bundleId: "io.tuist.AGAMI",
            deploymentTargets: .iOS("17.0"),
            infoPlist:
                    .extendingDefault(
                        with: [
                            "UILaunchScreen": [
                                "UIColorName": "",
                                "UIImageName": ""
                            ],
                            "NSAppleMusicUsageDescription": "플레이리스트 추가를 위해 Apple Music 라이브러리에 접근합니다.",
                            "NSMicrophoneUsageDescription": "Shazam 음악 인식을 위해 마이크에 접근합니다.",
                            "NSPhotoLibraryUsageDescription": "플레이리스트 사진 추가를 위해 사진 라이브러리에 접근합니다.",
                            "NSCameraUsageDescription": "플레이리스트 사진 추가를 위해 카메라에 접근합니다.",
                            "NSLocationUsageDescription": "근처 장소 탐색을 위해 사용자의 위치 정보에 접근합니다.",
                            "NSLocationWhenInUseUsageDescription": "근처 장소 탐색을 위해 사용자의 위치 정보에 접근합니다.",
                            "UISupportedInterfaceOrientations": [
                                "UIInterfaceOrientationPortrait",
                                "UIInterfaceOrientationPortraitUpsideDown"
                            ],
                            "UIAppFonts": .array( fonts .map { .string( $0 ) }),
                            "LSApplicationQueriesSchemes": .array( ["spotify"] ),
                            "CFBundleURLTypes": .array([
                                .dictionary([
                                    "CFBundleURLSchemes" : .array(["plake-agami"]),
                                    "CFBundleURLName" : .string("com.agami.plake")
                                ])
                            ]),
                            "UIUserInterfaceStyle": "Light",
                            "CLIENT_ID": .string("$(CLIENT_ID)"),
                            "CLIENT_SECRET": .string("$(CLIENT_SECRET)"),
                            "REDIRECT_URL": .string("$(REDIRECT_URL)")
                        ]
                    ),
            sources: ["AGAMI/Sources/**"],
            resources: ["AGAMI/Resources/**"],
            entitlements: "Entitlements/AGAMI.entitlements",
            scripts: [.swiftLintShell],
            dependencies: [
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebaseAuth"),
                .external(name: "FirebaseFirestore"),
                .external(name: "FirebaseStorage"),
                .external(name: "SpotifyAPI"),
                .external(name: "KeychainAccess"),
                .external(name: "Lottie"),
                .external(name: "Kingfisher")
            ]
        ),
        .target(
            name: "AGAMITests",
            destinations: [.iPhone],
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
