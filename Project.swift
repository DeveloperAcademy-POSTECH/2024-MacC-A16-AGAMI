import ProjectDescription

let fonts = [
    "SCDream1.otf",
    "SCDream2.otf",
    "SCDream3.otf",
    "SCDream4.otf",
    "SCDream5.otf",
    "SCDream6.otf",
    "SCDream7.otf",
    "SCDream8.otf",
    "SCDream9.otf",
    "NotoSansKR-Thin.ttf",
    "NotoSansKR-ExtraLight.ttf",
    "NotoSansKR-Light.ttf",
    "NotoSansKR-Regular.ttf",
    "NotoSansKR-Medium.ttf",
    "NotoSansKR-SemiBold.ttf",
    "NotoSansKR-Bold.ttf",
    "NotoSansKR-ExtraBold.ttf",
    "NotoSansKR-Black.ttf"
]

let project = Project(
    name: "AGAMI",
    options: .options(
        defaultKnownRegions: ["en", "ko"],
        developmentRegion: "ko"
    ),
    settings: .settings(
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
                            "NSPhotoLibraryUsageDescription": "플레이리스트 사진 추가 및 사진 저장을 위해 사진 라이브러리에 접근합니다.",
                            "NSCameraUsageDescription": "플레이리스트 사진 추가를 위해 카메라에 접근합니다.",
                            "NSLocationUsageDescription": "플레이리스트 위치 저장을 위해 사용자의 위치 정보에 접근합니다.",
                            "NSLocationWhenInUseUsageDescription": "플레이리스트 위치 저장을 위해 사용자의 위치 정보에 접근합니다.",
                            "UISupportedInterfaceOrientations": [
                                "UIInterfaceOrientationPortrait",
                                "UIInterfaceOrientationPortraitUpsideDown"
                            ],
                            "UIAppFonts": .array( fonts .map { .string( $0 ) }),
                            "LSApplicationQueriesSchemes": .array([
                                "spotify",
                                "instagram-stories"
                            ]),
                            "CFBundleURLTypes": .array([
                                .dictionary([
                                    "CFBundleURLSchemes" : .array(["plake-agami"]),
                                    "CFBundleURLName" : .string("com.agami.plake")
                                ])
                            ]),
                            "UIUserInterfaceStyle": "Light",
                            "CLIENT_ID": .string("$(CLIENT_ID)"),
                            "CLIENT_SECRET": .string("$(CLIENT_SECRET)"),
                            "REDIRECT_URL": .string("$(REDIRECT_URL)"),
                            "INSTA_APP_ID": .string("$(INSTA_APP_ID)"),
                            "CFBundleDisplayName": "소록",
                            "CFBundleShortVersionString": "2.0",
                            "CFBundleVersion": "3"
                        ]
                    ),
            sources: ["AGAMI/Sources/**"],
            resources: ["AGAMI/Resources/**"],
            entitlements: "Entitlements/AGAMI.entitlements",
            scripts: [.swiftLintShell],
            dependencies: [
                .external(name: "FirebaseAuth"),
                .external(name: "FirebaseFirestore"),
                .external(name: "FirebaseStorage"),
                .external(name: "SpotifyAPI"),
                .external(name: "KeychainAccess"),
                .external(name: "Lottie"),
                .external(name: "Kingfisher")
            ]
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
