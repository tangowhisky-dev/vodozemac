#!/bin/bash

# Comprehensecho "🏗 Building and running XCTest suite..."

# Run the tests using xcodebuild with improved result handling
xcodebuild test \
    -project VodozemacTests.xcodeproj \
    -scheme VodozemacTests \
    -destination "platform=macOS" \
    -quiet \
    -resultBundlePath /tmp/vodozemac_test_results.xcresult \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGN_IDENTITY="" \
    2>/dev/null Runner for Vodozemac Swift Bindings
# This script runs the consolidated XCTest-based test suite using Xcode

echo "🧪 Running Vodozemac Comprehensive XCTests..."
echo "=============================================="

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ xcodebuild not found. Please install Xcode Command Line Tools."
    exit 1
fi

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

echo "� Building and running XCTest suite..."

# Run the tests using xcodebuild
xcodebuild test \
    -project VodozemacTests.xcodeproj \
    -scheme VodozemacTests \
    -destination "platform=macOS" \
    -quiet

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 All XCTests passed successfully!"
else
    echo ""
    echo "❌ Some tests failed. Check the output above for details."
    exit 1
fi

echo "✨ XCTest run completed"
