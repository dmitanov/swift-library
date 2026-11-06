// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HabitTracker",
    products: [
        .library(
            name: "HabitKit",
            targets: ["HabitKit"]
        ),
        .executable(
            name: "HabitTracker",
            targets: ["HabitTracker"]
        ),
    ],
    targets: [
        .target(
            name: "HabitKit",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .executableTarget(
            name: "HabitTracker",
            dependencies: ["HabitKit"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .testTarget(
            name: "HabitKitTests",
            dependencies: ["HabitKit"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
    ]
)
