#!/bin/bash

# Simple test runner for ECIES tests only
# This script compiles and runs just the ECIES test functions

set -e

echo "🔨 ECIES-Only Test for Vodozemac Swift Bindings"
echo "==============================================="

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINDINGS_DIR="$(dirname "$SCRIPT_DIR")"
GENERATED_DIR="$BINDINGS_DIR/generated"
TARGET_DIR="$BINDINGS_DIR/../target/debug"

# Create temporary directory for compilation
TEMP_DIR=$(mktemp -d)
echo "📁 Using temporary directory: $TEMP_DIR"

# Copy necessary files
echo "📋 Copying files for compilation..."
cp "$GENERATED_DIR/vodozemac.swift" "$TEMP_DIR/"
cp "$GENERATED_DIR/vodozemacFFI.h" "$TEMP_DIR/"
cp "$GENERATED_DIR/vodozemacFFI.modulemap" "$TEMP_DIR/"
cp "$SCRIPT_DIR/ecies_tests.swift" "$TEMP_DIR/"
cp "$TARGET_DIR/libvodozemac_bindings.dylib" "$TEMP_DIR/"

# Create a simple main.swift that just runs ECIES tests
cat > "$TEMP_DIR/simple_main.swift" << 'EOF'
import Foundation

// Run ECIES tests
runEciesTests()

print("\n🎉 ECIES tests completed!")
EOF

echo "🔨 Compiling Swift test program..."
cd "$TEMP_DIR"

# Compile the Swift program with the vodozemac library
swiftc -o ecies_test \
    -I . \
    -L . \
    -lvodozemac_bindings \
    -import-objc-header vodozemacFFI.h \
    vodozemac.swift ecies_tests.swift simple_main.swift

echo "✅ Compilation successful!"

# Run the test
echo ""
echo "🚀 Running the ECIES test program..."
echo "======================================"

# Set the library path so the executable can find the dynamic library
export DYLD_LIBRARY_PATH=".:${DYLD_LIBRARY_PATH:-}"

# Run the test
set +e
./ecies_test
TEST_EXIT_CODE=$?
set -e

# Clean up
echo ""
echo "🧹 Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

# Report results
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo ""
    echo "🎉 ECIES TESTS PASSED!"
    echo "====================="
    echo ""
    echo "✅ The ECIES Swift bindings work correctly"
    echo "✅ All ECIES functions are accessible and working as expected"
else
    echo ""
    echo "❌ ECIES TESTS FAILED!"
    echo "====================="
    echo ""
    echo "The ECIES test program failed with exit code $TEST_EXIT_CODE"
    echo "Please check the output above for error details."
    exit $TEST_EXIT_CODE
fi
