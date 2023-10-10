// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDeps",
    platforms: [.macOS(.v13), .iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftDeps",
            targets: ["SwiftDeps"]),
    ], 
    dependencies: [
        .package(url: "https://github.com/uber/ios-snapshot-test-case", from: "8.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftDeps",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .testTarget(
            name: "SwiftDepsTests",
            dependencies: [
                "SwiftDeps",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "iOSSnapshotTestCase", package: "ios-snapshot-test-case"),
            ]
        ),
    ]
)
