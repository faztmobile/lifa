// swift-tools-version: 6.0
// Lifa design system for SwiftUI (step 2). Tokens, fonts and icons under Sources/LifaDesign/Generated and
// Resources are produced by design/generators/build.mjs; do not edit them by hand.
import PackageDescription

let package = Package(
    name: "LifaDesign",
    defaultLocalization: "en",
    platforms: [.iOS(.v18)], // NFR-DEV-001: current iOS and the two prior major versions (27, 26, 18)
    products: [
        .library(name: "LifaDesign", targets: ["LifaDesign"]),
    ],
    targets: [
        .target(
            name: "LifaDesign",
            resources: [.process("Resources")],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(name: "LifaDesignTests", dependencies: ["LifaDesign"]),
    ]
)
