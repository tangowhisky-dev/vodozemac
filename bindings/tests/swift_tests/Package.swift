// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "VodozemacTests",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "VodozemacTests",
            targets: ["VodozemacTests"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Vodozemac",
            path: "../../swift",
            sources: ["vodozemac.swift"],
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".")
            ],
            linkerSettings: [
                .linkedLibrary("vodozemac_uniffi", .when(platforms: [.macOS, .iOS]))
            ]
        ),
        .testTarget(
            name: "VodozemacTests",
            dependencies: ["Vodozemac"],
            path: "Tests",
            resources: [
                .copy("../test_vectors.json")
            ]
        ),
    ]
)
