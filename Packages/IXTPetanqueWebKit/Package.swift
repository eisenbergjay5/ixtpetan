// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "IXTPetanqueWebKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "IXTPetanqueWebKit",
            targets: ["IXTPetanqueWebKit"]
        )
    ],
    targets: [
        .target(name: "IXTPetanqueWebKit")
    ]
)
