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
        .systemLibrary(
            name: "vodozemacFFI",
            path: "Sources/Vodozemac",
            pkgConfig: nil,
            providers: nil),
        .target(
            name: "Vodozemac",
            dependencies: ["vodozemacFFI"],
            cSettings: [
                .headerSearchPath(".")
            ],
            linkerSettings: [
                .linkedLibrary("vodozemac_bindings_universal", .when(platforms: [.macOS, .iOS])),
                .unsafeFlags(["-L."], .when(platforms: [.macOS]))
            ]
        ),
        .testTarget(
            name: "VodozemacTests",
            dependencies: ["Vodozemac"],
            resources: [
                .copy("../test_vectors.json")
            ]
        ),
    ]
)
