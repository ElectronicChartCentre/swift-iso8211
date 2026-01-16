// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-iso8211",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftISO8211",
            targets: ["SwiftISO8211"]
        ),
    ],
    dependencies: [
        // zip only needed for testing
        .package(url: "https://github.com/adam-fowler/swift-zip-archive", from: "0.6.4")
    ],
    targets: [
        .target(
            name: "SwiftISO8211"
        ),
        .testTarget(
            name: "SwiftISO8211Tests",
            dependencies: [
                .target(name: "SwiftISO8211"),
                .product(name: "ZipArchive", package: "swift-zip-archive")
            ],
            resources: [.copy("TestResources")]
        ),
    ]
)
