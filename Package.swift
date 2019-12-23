// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RestorableBackgroundTimer",
    platforms: [
        .iOS(SupportedPlatform.IOSVersion.v10),
        .macOS(SupportedPlatform.MacOSVersion.v10_14),
        .tvOS(SupportedPlatform.TVOSVersion.v9),
//        .watchOS(SupportedPlatform.WatchOSVersion.v3) not possible because of UIKit constraint
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "RestorableBackgroundTimer",
            targets: ["RestorableBackgroundTimer"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "RestorableBackgroundTimer",
            dependencies: []),
        .testTarget(
            name: "RestorableBackgroundTimerTests",
            dependencies: ["RestorableBackgroundTimer"]),
    ]
)
