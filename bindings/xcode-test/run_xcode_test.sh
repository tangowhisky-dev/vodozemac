#!/bin/bash

# Xcode Command Line Test for Vodozemac Swift Bindings
# This script compiles and runs a Swift test program using Xcode's tools

set -e

echo "🔨 Xcode Command Line Test for Vodozemac Swift Bindings"
echo "======================================================="

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINDINGS_DIR="$(dirname "$SCRIPT_DIR")"
GENERATED_DIR="$BINDINGS_DIR/generated/swift"
MACOS_LIB_DIR="$GENERATED_DIR/macos"

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

# Create temporary directory for compilation
TEMP_DIR=$(mktemp -d)
echo "📁 Using temporary directory: $TEMP_DIR"

# Copy necessary files
echo "📋 Copying files for compilation..."
cp "$GENERATED_DIR/vodozemac.swift" "$TEMP_DIR/"
cp "$GENERATED_DIR/vodozemacFFI.h" "$TEMP_DIR/"
cp "$GENERATED_DIR/vodozemacFFI.modulemap" "$TEMP_DIR/"
cp "$SCRIPT_DIR/main.swift" "$TEMP_DIR/"
cp "$SCRIPT_DIR/ecies_tests.swift" "$TEMP_DIR/"
cp "$SCRIPT_DIR/sas_tests.swift" "$TEMP_DIR/"
cp "$SCRIPT_DIR/olm_tests.swift" "$TEMP_DIR/"
cp "$SCRIPT_DIR/megolm_tests.swift" "$TEMP_DIR/"
cp "$MACOS_LIB_DIR/libvodozemac_bindings_universal.dylib" "$TEMP_DIR/libvodozemac_bindings.dylib"

echo "🔨 Compiling Swift test program..."
cd "$TEMP_DIR"

# Compile the Swift program with the vodozemac library
# Use the generated FFI header directly without creating a bridging header
swiftc -o vodozemac_test \
    -I . \
    -L . \
    -lvodozemac_bindings \
    -import-objc-header vodozemacFFI.h \
    vodozemac.swift main.swift ecies_tests.swift sas_tests.swift olm_tests.swift megolm_tests.swift

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
    echo "✅ Universal macOS library linking is working properly"
    echo "✅ FFI interface is functioning correctly"
    echo ""
    echo "🚀 Your bindings are ready for integration into iOS/macOS Xcode projects!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. See bindings/tests/README.md for iOS integration instructions"
    echo "   2. Use libraries from generated/swift/ folder:"
    echo "      - macos/ for macOS applications"
    echo "      - ios-device/ for iPhone/iPad"
    echo "      - ios-simulator/ for iOS Simulator"  
    echo "   3. Copy the generated/swift/ files to your Xcode project"
    echo "   4. Configure build settings as described in the documentation"
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
