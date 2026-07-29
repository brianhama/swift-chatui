// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ChatUI",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "ChatUI", targets: ["ChatUI"])
    ],
    targets: [
        .target(
            name: "ChatUI",
            resources: []
        ),
        .testTarget(
            name: "ChatUITests",
            dependencies: ["ChatUI"]
        )
    ]
)
