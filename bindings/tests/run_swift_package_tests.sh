#!/bin/bash

# Modern Swift Package Manager Test Runner for Vodozemac Swift Bindings
# This script runs the modernized Swift Package Manager-based tests

set -e

echo "🧪 Modern Swift Package Manager Tests for Vodozemac Bindings"
echo "============================================================"

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINDINGS_DIR="$(dirname "$SCRIPT_DIR")"
SWIFT_TESTS_DIR="$SCRIPT_DIR/swift_tests"
GENERATED_DIR="$BINDINGS_DIR/generated/swift"
MACOS_LIB_DIR="$GENERATED_DIR/macos"

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo "❌ Swift not found. Please install Xcode or Swift toolchain."
    exit 1
fi

echo "   ✅ Swift found: $(swift --version | head -n 1)"

# Check if bindings are generated
if [ ! -f "$GENERATED_DIR/vodozemac.swift" ]; then
    echo "❌ Generated bindings not found. Running generate_bindings.sh to create them..."
    cd "$BINDINGS_DIR"
    ./generate_bindings.sh
    cd "$SCRIPT_DIR"
    
    if [ ! -f "$GENERATED_DIR/vodozemac.swift" ]; then
        echo "❌ Failed to generate Swift bindings."
        exit 1
    fi
fi

echo "   ✅ Generated Swift bindings found"

# Check if the dynamic library exists
if [ ! -f "$MACOS_LIB_DIR/libvodozemac_bindings_universal.dylib" ]; then
    echo "❌ macOS universal library not found. Running generate_bindings.sh to build libraries..."
    cd "$BINDINGS_DIR"
    ./generate_bindings.sh
    cd "$SCRIPT_DIR"
    
    if [ ! -f "$MACOS_LIB_DIR/libvodozemac_bindings_universal.dylib" ]; then
        echo "❌ Failed to generate macOS universal library."
        exit 1
    fi
fi

echo "   ✅ macOS universal library found"

# Check if test vectors exist
if [ ! -f "$SCRIPT_DIR/test_vectors.json" ]; then
    echo "❌ Test vectors not found. Generating them..."
    cd "$SCRIPT_DIR/rust_reference"
    cargo run
    cd "$SCRIPT_DIR"
    
    if [ ! -f "$SCRIPT_DIR/test_vectors.json" ]; then
        echo "❌ Failed to generate test vectors."
        exit 1
    fi
fi

echo "   ✅ Test vectors found"

# Set up proper Swift Package structure
echo "🔧 Setting up Swift Package structure..."

# Create Sources directory and copy generated bindings
mkdir -p "$SWIFT_TESTS_DIR/Sources/Vodozemac"
cp "$GENERATED_DIR/vodozemac.swift" "$SWIFT_TESTS_DIR/Sources/Vodozemac/"
cp "$GENERATED_DIR/vodozemacFFI.h" "$SWIFT_TESTS_DIR/Sources/Vodozemac/"
cp "$GENERATED_DIR/vodozemacFFI.modulemap" "$SWIFT_TESTS_DIR/Sources/Vodozemac/module.modulemap"

echo "   ✅ Swift Package structure ready"

# Change to swift_tests directory
cd "$SWIFT_TESTS_DIR"

# Set library path so Swift can find the dylib
export DYLD_LIBRARY_PATH="$MACOS_LIB_DIR:${DYLD_LIBRARY_PATH:-}"
export LIBRARY_PATH="$MACOS_LIB_DIR:${LIBRARY_PATH:-}"
export LD_LIBRARY_PATH="$MACOS_LIB_DIR:${LD_LIBRARY_PATH:-}"

echo ""
echo "🏗️  Building Swift Package..."
swift build -v 2>&1 | tail -15

echo ""
echo "🧪 Running modernized Swift Package Manager tests..."
echo "===================================================="

# Run the tests
set +e
swift test -v 2>&1
TEST_EXIT_CODE=$?
set -e

# Report results
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo ""
    echo "🎉 MODERNIZED SWIFT PACKAGE MANAGER TESTS PASSED!"
    echo "================================================="
    echo ""
    echo "✅ All modernized Swift Package Manager tests completed successfully"
    echo "✅ Test vector validation working with current API"
    echo "✅ Functional tests running with up-to-date Swift bindings"
    echo "✅ Error handling validation successful"
    echo ""
    echo "� Test Coverage:"
    echo "   • Base utility functions (base64, version)"
    echo "   • Basic cryptographic operations (Curve25519, Ed25519)" 
    echo "   • Megolm group messaging basics"
    echo "   • Error handling scenarios"
    echo "   • Test vector validation (where available)"
    echo ""
    echo "🔄 Complementary Testing:"
    echo "   • Use ./run_comprehensive_tests.sh for complete functional testing"
    echo "   • This test suite focuses on test vector validation"
else
    echo ""
    echo "❌ MODERNIZED SWIFT PACKAGE MANAGER TESTS FAILED!"
    echo "================================================="
    echo ""
    echo "The tests failed with exit code $TEST_EXIT_CODE"
    echo "This might be due to:"
    echo "   1. API compatibility issues with generated bindings"
    echo "   2. Library linking problems"
    echo "   3. Test vector format mismatches"
    echo ""
    echo "💡 Troubleshooting:"
    echo "   1. Check library linking: ldd Sources/Vodozemac/libvodozemac_bindings_universal.dylib"
    echo "   2. Verify test vectors: cat ../test_vectors.json | jq '.utility_tests'"
    echo "   3. Use comprehensive tests: ./run_comprehensive_tests.sh"
    echo ""
    exit $TEST_EXIT_CODE
fi
