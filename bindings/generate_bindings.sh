#!/bin/bash
set -e

echo "🧹 Cleaning cargo build..."
cargo clean

echo "🔧 Installing required iOS targets..."
# Add iOS targets if not already installed
rustup target add aarch64-apple-ios        # iOS devices (iPhone/iPad)
rustup target add x86_64-apple-ios         # iOS Simulator (Intel)
rustup target add aarch64-apple-ios-sim    # iOS Simulator (Apple Silicon)

echo "🏗️ Building libraries for multiple targets..."
echo ""

# Build for macOS (existing functionality)
echo "📱 Building for macOS (x86_64 + arm64)..."
cargo build --target x86_64-apple-darwin
cargo build --target aarch64-apple-darwin

# Build for iOS Device
echo "📱 Building for iOS Device (arm64)..."
cargo build --target aarch64-apple-ios

# Build for iOS Simulator
echo "📱 Building for iOS Simulator (x86_64 + arm64)..."
cargo build --target x86_64-apple-ios
cargo build --target aarch64-apple-ios-sim

echo ""
echo "🧽 Cleaning generated directory..."
rm -rf generated/swift
mkdir -p generated/swift

# Create directories for different targets
mkdir -p generated/swift/macos
mkdir -p generated/swift/ios-device
mkdir -p generated/swift/ios-simulator

echo "🔄 Generating Swift bindings..."
# Use macOS library for generating bindings (they're all the same Swift API)
uniffi-bindgen generate --library ../target/aarch64-apple-darwin/debug/libvodozemac_bindings.dylib --language swift --out-dir generated/swift

echo "🔧 Updating contract version from 30 to 29..."
sed -i '' 's/let bindings_contract_version = 30/let bindings_contract_version = 29/g' generated/swift/vodozemac.swift

echo ""
echo "📦 Organizing libraries by platform..."

# Copy macOS libraries
echo "  Copying macOS libraries..."
cp ../target/x86_64-apple-darwin/debug/libvodozemac_bindings.dylib generated/swift/macos/libvodozemac_bindings_x86_64.dylib 2>/dev/null || echo "    ⚠️ x86_64-apple-darwin build not available"
cp ../target/aarch64-apple-darwin/debug/libvodozemac_bindings.dylib generated/swift/macos/libvodozemac_bindings_arm64.dylib 2>/dev/null || echo "    ⚠️ aarch64-apple-darwin build not available"

# Copy iOS device library  
echo "  Copying iOS device library..."
cp ../target/aarch64-apple-ios/debug/libvodozemac_bindings.dylib generated/swift/ios-device/libvodozemac_bindings.dylib 2>/dev/null || echo "    ⚠️ aarch64-apple-ios build not available"

# Copy iOS simulator libraries
echo "  Copying iOS simulator libraries..."
cp ../target/x86_64-apple-ios/debug/libvodozemac_bindings.dylib generated/swift/ios-simulator/libvodozemac_bindings_x86_64.dylib 2>/dev/null || echo "    ⚠️ x86_64-apple-ios build not available"
cp ../target/aarch64-apple-ios-sim/debug/libvodozemac_bindings.dylib generated/swift/ios-simulator/libvodozemac_bindings_arm64.dylib 2>/dev/null || echo "    ⚠️ aarch64-apple-ios-sim build not available"

echo ""
echo "🔗 Creating universal binaries..."

# Create universal macOS binary if both architectures are available
if [ -f "generated/swift/macos/libvodozemac_bindings_x86_64.dylib" ] && [ -f "generated/swift/macos/libvodozemac_bindings_arm64.dylib" ]; then
    echo "  Creating universal macOS library..."
    lipo -create \
        generated/swift/macos/libvodozemac_bindings_x86_64.dylib \
        generated/swift/macos/libvodozemac_bindings_arm64.dylib \
        -output generated/swift/macos/libvodozemac_bindings_universal.dylib
    echo "    ✅ Universal macOS library created"
else
    echo "    ⚠️ Skipping universal macOS library (missing architectures)"
fi

# Create universal iOS simulator binary if both architectures are available  
if [ -f "generated/swift/ios-simulator/libvodozemac_bindings_x86_64.dylib" ] && [ -f "generated/swift/ios-simulator/libvodozemac_bindings_arm64.dylib" ]; then
    echo "  Creating universal iOS simulator library..."
    lipo -create \
        generated/swift/ios-simulator/libvodozemac_bindings_x86_64.dylib \
        generated/swift/ios-simulator/libvodozemac_bindings_arm64.dylib \
        -output generated/swift/ios-simulator/libvodozemac_bindings_universal.dylib
    echo "    ✅ Universal iOS simulator library created"
else
    echo "    ⚠️ Skipping universal iOS simulator library (missing architectures)"
fi

echo ""
echo "📋 Library Summary:"
echo "===================="
echo "📁 macOS libraries:"
ls -la generated/swift/macos/ 2>/dev/null | grep -E '\.dylib$' | awk '{print "   " $9 " (" $5 " bytes)"}' || echo "   No macOS libraries found"

echo "📁 iOS device libraries:"
ls -la generated/swift/ios-device/ 2>/dev/null | grep -E '\.dylib$' | awk '{print "   " $9 " (" $5 " bytes)"}' || echo "   No iOS device libraries found"

echo "📁 iOS simulator libraries:"
ls -la generated/swift/ios-simulator/ 2>/dev/null | grep -E '\.dylib$' | awk '{print "   " $9 " (" $5 " bytes)"}' || echo "   No iOS simulator libraries found"

echo ""
echo "🎉 Multi-platform bindings generated successfully!"
echo "📍 Swift bindings: generated/swift/"
echo "📍 Platform libraries:"
echo "   • macOS: generated/swift/macos/"
echo "   • iOS Device: generated/swift/ios-device/" 
echo "   • iOS Simulator: generated/swift/ios-simulator/"
echo ""
echo "💡 Usage Notes:"
echo "   • For macOS: Use libvodozemac_bindings_universal.dylib (or architecture-specific)"
echo "   • For iOS Device: Use ios-device/libvodozemac_bindings.dylib" 
echo "   • For iOS Simulator: Use libvodozemac_bindings_universal.dylib (or architecture-specific)"
echo "   • For Xcode projects: Add appropriate library based on your target platform"
