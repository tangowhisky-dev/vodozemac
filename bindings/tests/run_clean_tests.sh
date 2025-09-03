#!/bin/bash

# Clean Test Runner for Vodozemac Swift Bindings
# This script runs tests with minimal logging to avoid result bundle issues

echo "🧪 Running Vodozemac XCTests (Clean Mode)..."
echo "============================================"

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ xcodebuild not found. Please install Xcode Command Line Tools."
    exit 1
fi

# Clean any existing build artifacts
echo "🧹 Cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/VodozemacTests-* 2>/dev/null || true

# Build the Swift bindings first if needed
if [ ! -f "../generated/swift/vodozemac.swift" ]; then
    echo "⚠️  Swift bindings not found. Building first..."
    cd .. && ./generate_bindings.sh
    if [ $? -ne 0 ]; then
        echo "❌ Failed to generate bindings"
        exit 1
    fi
    cd tests
fi

echo "🏗 Building and running XCTest suite (clean mode)..."

# Run the tests with minimal result bundle generation
xcodebuild clean test \
    -project VodozemacTests.xcodeproj \
    -scheme VodozemacTests \
    -destination "platform=macOS" \
    -quiet \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGN_IDENTITY="" \
    ENABLE_TESTABILITY=YES \
    GCC_GENERATE_DEBUGGING_SYMBOLS=NO \
    DEBUG_INFORMATION_FORMAT=none \
    STRIP_INSTALLED_PRODUCT=YES \
    COPY_PHASE_STRIP=YES \
    > /tmp/xcodebuild_clean.log 2>&1

test_result=$?

# Check results and provide clean output
if [ $test_result -eq 0 ]; then
    echo ""
    echo "🎉 All XCTests passed successfully!"
    echo "📊 Test Summary:"
    grep -E "(Test Suite|executed|passed|failed)" /tmp/xcodebuild_clean.log | tail -5
else
    echo ""
    echo "❌ Some tests failed. Error details:"
    grep -E "(error:|failed|FAILED)" /tmp/xcodebuild_clean.log | tail -10
    exit 1
fi

echo "✨ Clean XCTest run completed"
