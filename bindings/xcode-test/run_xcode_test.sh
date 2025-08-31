#!/bin/bash

# Xcode Command Line Test for Vodozemac Swift Bindings
# This script compiles and runs a Swift test program using Xcode's tools

set -e

echo "🔨 Xcode Command Line Test for Vodozemac Swift Bindings"
echo "======================================================="

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINDINGS_DIR="$(dirname "$SCRIPT_DIR")"
GENERATED_DIR="$BINDINGS_DIR/generated"
TARGET_DIR="$BINDINGS_DIR/../target/release"

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check if Xcode command line tools are installed
if ! command -v swiftc &> /dev/null; then
    echo "❌ Swift compiler (swiftc) not found. Please install Xcode command line tools:"
    echo "   xcode-select --install"
    exit 1
fi

echo "   ✅ Swift compiler found: $(swiftc --version | head -n 1)"

# Check if bindings are generated
if [ ! -f "$GENERATED_DIR/vodozemac.swift" ]; then
    echo "❌ Generated bindings not found. Please run 'make generate' first."
    exit 1
fi

echo "   ✅ Generated Swift bindings found"

# Check if the dynamic library exists
if [ ! -f "$TARGET_DIR/libvodozemac_bindings.dylib" ]; then
    echo "❌ Dynamic library not found. Please run 'cargo build' first."
    exit 1
fi

echo "   ✅ Dynamic library found"

# Create temporary directory for compilation
TEMP_DIR=$(mktemp -d)
echo "📁 Using temporary directory: $TEMP_DIR"

# Copy necessary files
echo "📋 Copying files for compilation..."
cp "$GENERATED_DIR/vodozemac.swift" "$TEMP_DIR/"
cp "$GENERATED_DIR/vodozemacFFI.h" "$TEMP_DIR/"
cp "$GENERATED_DIR/vodozemacFFI.modulemap" "$TEMP_DIR/"
cp "$SCRIPT_DIR/main.swift" "$TEMP_DIR/"
cp "$TARGET_DIR/libvodozemac_bindings.dylib" "$TEMP_DIR/"

echo "🔨 Compiling Swift test program..."
cd "$TEMP_DIR"

# Compile the Swift program with the vodozemac library
# Use the generated FFI header directly without creating a bridging header
swiftc -o vodozemac_test \
    -I . \
    -L . \
    -lvodozemac_bindings \
    -import-objc-header vodozemacFFI.h \
    vodozemac.swift main.swift

echo "✅ Compilation successful!"

# Run the test
echo ""
echo "🚀 Running the test program..."
echo "==============================="

# Set the library path so the executable can find the dynamic library
export DYLD_LIBRARY_PATH=".:${DYLD_LIBRARY_PATH:-}"

# Run the test
set +e
./vodozemac_test
TEST_EXIT_CODE=$?
set -e
# Clean up
echo ""
echo "🧹 Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

# Report results
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo ""
    echo "🎉 XCODE COMMAND LINE TEST PASSED!"
    echo "=================================="
    echo ""
    echo "✅ The vodozemac Swift bindings work correctly with Xcode tools"
    echo "✅ All functions are accessible and working as expected"
    echo "✅ Dynamic library linking is working properly"
    echo "✅ FFI interface is functioning correctly"
    echo ""
    echo "🚀 Your bindings are ready for integration into Xcode projects!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. See docs/XcodeIntegrationGuide.md for full integration instructions"
    echo "   2. Copy the generated/ files to your Xcode project"
    echo "   3. Configure build settings as described in the guide"
else
    echo ""
    echo "❌ XCODE COMMAND LINE TEST FAILED!"
    echo "================================="
    echo ""
    echo "The test program failed with exit code $TEST_EXIT_CODE"
    echo "Please check the output above for error details."
    echo ""
    exit $TEST_EXIT_CODE
fi
