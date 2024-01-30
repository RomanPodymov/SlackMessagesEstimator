// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlackMessagesEstimator",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "SlackMessagesEstimator", targets: ["SlackMessagesEstimator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mxcl/PromiseKit.git", from: "8.1.1"),
        .package(url: "https://github.com/RomanPodymov/SlackKit", branch: "master"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6")
    ],
    targets: [
        .target(
            name: "SlackMessagesEstimator",
            dependencies: ["PromiseKit", "SlackKit", "Yams"]),
        .testTarget(
            name: "SlackMessagesEstimatorTests",
            dependencies: ["SlackMessagesEstimator"]),
    ]
)
