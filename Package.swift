// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SeelWidget",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "SeelWidget",
            targets: ["SeelWidget"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.6.0")
    ],
    targets: [
        .target(
            name: "SeelWidget",
            dependencies: ["SnapKit"],
            path: "SeelWidget",
            resources: [
                .process("Assets"),
                .copy("PrivacyInfo.xcprivacy")
            ]
        ),
    ]
)
