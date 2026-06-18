// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "UIKitPlus",
    platforms: [
        .macOS(.v10_15), .iOS(.v12), .tvOS(.v13),
    ],
    products: [
        // 🏰 Declarative UIKit wrapper inspired by SwiftUI
        .library(name: "UIKitPlus", targets: ["UIKitPlus"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "UIKitPlus", dependencies: [], path: "Classes"),
        .testTarget(name: "UIKitPlusTests", dependencies: ["UIKitPlus"]),
        ]
)
