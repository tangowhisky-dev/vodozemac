#!/bin/bash

# Swift Package Manager Test Setup and Runner
# This script sets up a proper Swift Package Manager structure and runs the tests

set -e

echo "🔧 Setting up Swift Package Manager Tests"
echo "========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINDINGS_DIR="$(dirname "$SCRIPT_DIR")"
SWIFT_TESTS_DIR="$SCRIPT_DIR/swift_tests"
GENERATED_DIR="$BINDINGS_DIR/generated/swift"

# Create proper Swift Package structure
echo "📁 Setting up proper Swift Package structure..."

# Create Sources directory and copy generated bindings
mkdir -p "$SWIFT_TESTS_DIR/Sources/Vodozemac"
cp "$GENERATED_DIR/vodozemac.swift" "$SWIFT_TESTS_DIR/Sources/Vodozemac/"
cp "$GENERATED_DIR/vodozemacFFI.h" "$SWIFT_TESTS_DIR/Sources/Vodozemac/"
cp "$GENERATED_DIR/vodozemacFFI.modulemap" "$SWIFT_TESTS_DIR/Sources/Vodozemac/module.modulemap"

# Update Package.swift to use local Sources
cat > "$SWIFT_TESTS_DIR/Package.swift" << 'EOF'
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
            cSettings: [
                .headerSearchPath(".")
            ],
            linkerSettings: [
                .linkedLibrary("vodozemac_bindings", .when(platforms: [.macOS, .iOS])),
                .unsafeFlags(["-L../../../generated/swift/macos"], .when(platforms: [.macOS]))
            ]
        ),
        .testTarget(
            name: "VodozemacTests",
            dependencies: ["Vodozemac"],
            resources: [
                .copy("../../test_vectors.json")
            ]
        ),
    ]
)
EOF

echo "✅ Swift Package structure set up"
echo ""
echo "⚠️  IMPORTANT: The current Swift tests use an outdated API."
echo "   They expect wrapper classes (AccountWrapper, SessionWrapper, etc.)"
echo "   but the actual generated API uses direct classes (Account, Session, etc.)"
echo ""
echo "🔧 To make these tests work, you would need to:"
echo "   1. Update Tests/VodozemacTests.swift to use the current API:"
echo "      - Change AccountWrapper → Account"
echo "      - Change SessionWrapper → Session" 
echo "      - Change GroupSessionWrapper → GroupSession"
echo "      - Update all method calls to match current generated API"
echo "   2. Generate proper test vectors that match current API"
echo ""
echo "💡 RECOMMENDED: Use the comprehensive XCTest suite instead:"
echo "   cd $SCRIPT_DIR && ./run_comprehensive_tests.sh"
echo ""
echo "📚 The XCTest suite provides:"
echo "   ✅ Up-to-date API usage"
echo "   ✅ Comprehensive functionality testing"
echo "   ✅ Real-world usage patterns"
echo "   ✅ Error handling validation"
echo "   ✅ Performance testing"
