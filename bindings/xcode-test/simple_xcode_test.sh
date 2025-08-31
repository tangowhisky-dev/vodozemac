#!/bin/bash

# Simple Xcode Command Line Test for Vodozemac Swift Bindings
# This creates a minimal Swift program to test the bindings

set -e

echo "🧪 Minimal Xcode Test - Vodozemac Swift Bindings"
echo "================================================"

# Get the directory of this script  
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINDINGS_DIR="/Users/tango16/code/vodozemac/bindings"
GENERATED_DIR="$BINDINGS_DIR/generated"
TARGET_DIR="/Users/tango16/code/vodozemac/target/release"

# Check prerequisites
if [ ! -f "$GENERATED_DIR/vodozemac.swift" ]; then
    echo "❌ Generated bindings not found. Please run 'make generate' first."
    exit 1
fi

if [ ! -f "$TARGET_DIR/libvodozemac_bindings.dylib" ]; then
    echo "❌ Dynamic library not found. Please run 'cargo build' first."
    exit 1
fi

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
echo "📁 Using temporary directory: $TEMP_DIR"

# Copy files
cp "$GENERATED_DIR/vodozemac.swift" "$TEMP_DIR/"
cp "$GENERATED_DIR/vodozemacFFI.h" "$TEMP_DIR/"
cp "$TARGET_DIR/libvodozemac_bindings.dylib" "$TEMP_DIR/"

# Copy the simple test file
cp "$SCRIPT_DIR/simple_test.swift" "$TEMP_DIR/"

# Create bridging header
echo '#import "vodozemacFFI.h"' > "$TEMP_DIR/bridging-header.h"

cd "$TEMP_DIR"

echo "🔨 Compiling..."
swiftc -o simple_test \
    -I . \
    -L . \
    -lvodozemac_bindings \
    -import-objc-header bridging-header.h \
    vodozemac.swift simple_test.swift

echo "✅ Compilation successful!"

echo ""
echo "🚀 Running test..."
echo "=================="
DYLD_LIBRARY_PATH="." ./simple_test

echo ""
echo "🧹 Cleaning up..."
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 XCODE COMMAND LINE TEST SUCCESSFUL!"
echo "======================================"
echo "✅ Swift bindings work with Xcode tools"
echo "✅ All functions are accessible and working"
echo "🚀 Ready for Xcode project integration!"
