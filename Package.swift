// swift-tools-version:6.3
import PackageDescription

// LOCAL-ONLY SWITCH: this literal must be `false` in every commit and release.
// Set it to `true` only in an uncommitted local working tree when SwiftStream
// child packages should be resolved from relative sibling paths.
let isLocalDevelopment = false

var package = Package(
    name: "UIKitUltra",
    platforms: [
        .macOS(.v10_15), .iOS(.v12), .tvOS(.v13),
    ],
    products: [
        // 🏰 Declarative native UI framework inspired by UIKit's mental model.
        .library(name: "Ultra", targets: ["Ultra"]),
        // Structural direct-backend overlays. Product existence is not backend support certification.
        .library(name: "UltraQt", targets: ["UltraQt"]),
        .library(name: "UltraWin", targets: ["UltraWin"]),
    ],
    traits: [
        .trait(name: "UltraGTK"),
        .trait(name: "UltraQt"),
    ],
    dependencies: [],
    targets: [
        .target(name: "UltraCore", dependencies: [], path: "Sources/Core"),
        .target(
            name: "UltraQtRuntime",
            dependencies: ["UltraCore"],
            path: "Sources/QtRuntime"
        ),
        .target(
            name: "UltraWinRuntime",
            dependencies: ["UltraCore"],
            path: "Sources/WinRuntime"
        ),
        .target(
            name: "Ultra",
            dependencies: [
                "UltraCore",
                .target(
                    name: "UltraQtRuntime",
                    condition: .when(platforms: [.linux], traits: ["UltraQt"])
                ),
                .target(
                    name: "UltraWinRuntime",
                    condition: .when(platforms: [.windows])
                ),
            ],
            path: "Sources/Kit",
            swiftSettings: [
                .define("ULTRA_GTK_BACKEND", .when(traits: ["UltraGTK"])),
                .define("ULTRA_QT_BACKEND", .when(traits: ["UltraQt"])),
            ]
        ),
        .target(
            name: "UltraQt",
            dependencies: ["Ultra", "UltraQtRuntime"],
            path: "Sources/Qt"
        ),
        .target(
            name: "UltraWin",
            dependencies: ["Ultra", "UltraWinRuntime"],
            path: "Sources/Win"
        ),
        .testTarget(
            name: "UltraTests",
            dependencies: ["Ultra"],
            path: "Tests/UltraTests",
            swiftSettings: [
                .define(
                    "ULTRA_GTK_TESTS",
                    .when(platforms: [.linux], traits: ["UltraGTK"])
                ),
            ]
        ),
    ]
)

#if os(Linux)
if isLocalDevelopment {
    package.dependencies.append(
        .package(name: "UltraGTK", path: "../UltraGTK")
    )
} else {
    package.dependencies.append(
        .package(
            url: "https://github.com/swiftstream/UltraGTK.git",
            exact: "3.0.0-alpha.5"
        )
    )
}

if let ultra = package.targets.first(where: { $0.name == "Ultra" }) {
    ultra.dependencies.append(
        .product(
            name: "UltraGTK",
            package: "UltraGTK",
            condition: .when(platforms: [.linux], traits: ["UltraGTK"])
        )
    )
}

if let ultraTests = package.targets.first(where: { $0.name == "UltraTests" }) {
    ultraTests.dependencies.append(
        .product(
            name: "UltraGTK",
            package: "UltraGTK",
            condition: .when(platforms: [.linux], traits: ["UltraGTK"])
        )
    )
}
#endif
