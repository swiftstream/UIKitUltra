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
    traits: [
        .trait(name: "UIKitPlusGTK"),
        .trait(name: "UIKitPlusQt"),
    ],
    dependencies: [],
    targets: [
        .target(name: "UIKitPlusCore", dependencies: [], path: "Sources/Core"),
        .target(
            name: "UIKitPlusGTK",
            dependencies: ["UIKitPlusCore"],
            path: "Sources/GTK"
        ),
        .target(
            name: "UIKitPlusQt",
            dependencies: ["UIKitPlusCore"],
            path: "Sources/Qt"
        ),
        .target(
            name: "UIKitPlusWinUI",
            dependencies: ["UIKitPlusCore"],
            path: "Sources/WinUI"
        ),
        .target(
            name: "UIKitPlus",
            dependencies: [
                "UIKitPlusCore",
                .target(
                    name: "UIKitPlusGTK",
                    condition: .when(platforms: [.linux], traits: ["UIKitPlusGTK"])
                ),
                .target(
                    name: "UIKitPlusQt",
                    condition: .when(platforms: [.linux], traits: ["UIKitPlusQt"])
                ),
                .target(
                    name: "UIKitPlusWinUI",
                    condition: .when(platforms: [.windows])
                ),
            ],
            path: "Sources/Kit",
            swiftSettings: [
                .define("UIKITPLUS_GTK_BACKEND", .when(traits: ["UIKitPlusGTK"])),
                .define("UIKITPLUS_QT_BACKEND", .when(traits: ["UIKitPlusQt"])),
            ]
        ),
        .testTarget(name: "UIKitPlusTests", dependencies: ["UIKitPlus"]),
        ]
)
