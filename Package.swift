// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ChatUI",
    platforms: [.iOS(.v17)],
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
