# Vodozemac Swift Bindings - Xcode Integration Guide

This guide provides comprehensive instructions for integrating the vodozemac Swift bindings into your Xcode project.

## Overview

The vodozemac Swift bindings provide a high-level Swift interface to the vodozemac cryptographic library, which implements the Olm and Megolm cryptographic ratchets used for end-to-end encryption in Matrix.

**Generated Files:**
- `vodozemac.swift`: Main Swift API module
- `vodozemacFFI.h`: C header file with FFI declarations
- `vodozemacFFI.modulemap`: Module map for C interoperability
- `libvodozemac_bindings.dylib`: Dynamic library containing the Rust implementation

## Prerequisites

- Xcode 13.0+
- iOS 13.0+ / macOS 10.15+
- Swift 5.3+

## Integration Steps

### 1. Add Library Files to Xcode Project

1. **Copy the generated files** to your Xcode project:
   ```
   YourProject/
   ├── VodozemacBindings/
   │   ├── vodozemac.swift
   │   ├── vodozemacFFI.h
   │   ├── vodozemacFFI.modulemap
   │   └── libvodozemac_bindings.dylib
   ```

2. **Add files to Xcode**:
   - Right-click your project in the navigator
   - Choose "Add Files to [ProjectName]"
   - Select all the vodozemac binding files
   - Ensure they're added to your target

### 2. Configure Build Settings

#### 2.1 Update Library Search Paths
In your target's Build Settings:
- Search for "Library Search Paths"
- Add the path to where `libvodozemac_bindings.dylib` is located
- Example: `$(PROJECT_DIR)/VodozemacBindings`

#### 2.2 Link Binary with Libraries
In your target's Build Phases:
- Expand "Link Binary With Libraries"
- Add `libvodozemac_bindings.dylib`

#### 2.3 Configure Module Map (if needed)
If Xcode doesn't automatically find the module map:
- In Build Settings, search for "Import Paths"
- Add the path containing `vodozemacFFI.modulemap`

### 3. Create Bridge Configuration (if needed)

If you encounter module import issues, create a custom module map:

**VodozemacModule.modulemap:**
```modulemap
module vodozemacFFI {
    header "vodozemacFFI.h"
    export *
}
```

### 4. Build Scripts for Automation

Create a build script to automate the binding generation process.

#### 4.1 Generate Bindings Build Script

Create a new "Run Script" build phase in your target with the following script:

```bash
#!/bin/bash

# Build script for vodozemac Swift bindings generation
# Place this in Xcode Build Phases -> Run Script

set -e

# Configuration
VODOZEMAC_PATH="${PROJECT_DIR}/../vodozemac"  # Adjust path as needed
BINDINGS_PATH="${PROJECT_DIR}/VodozemacBindings"
UNIFFI_CLI="/Users/tango16/.cargo/bin/uniffi-bindgen"  # Adjust path as needed

# Ensure bindings directory exists
mkdir -p "$BINDINGS_PATH"

echo "Building vodozemac bindings..."

# Build the Rust library
cd "$VODOZEMAC_PATH/bindings"
cargo build --release

echo "Generating Swift bindings..."

# Generate Swift bindings
"$UNIFFI_CLI" generate \
    --library "../target/release/libvodozemac_bindings.dylib" \
    --language swift \
    --out-dir "$BINDINGS_PATH"

# Copy the dynamic library
cp "../target/release/libvodozemac_bindings.dylib" "$BINDINGS_PATH/"

echo "Vodozemac bindings updated successfully!"
```

#### 4.2 Input/Output Files

Set the build script's input and output files:

**Input Files:**
- `$(PROJECT_DIR)/../vodozemac/bindings/src/vodozemac.udl`
- `$(PROJECT_DIR)/../vodozemac/bindings/src/lib.rs`

**Output Files:**
- `$(PROJECT_DIR)/VodozemacBindings/vodozemac.swift`
- `$(PROJECT_DIR)/VodozemacBindings/vodozemacFFI.h`
- `$(PROJECT_DIR)/VodozemacBindings/vodozemacFFI.modulemap`
- `$(PROJECT_DIR)/VodozemacBindings/libvodozemac_bindings.dylib`

### 5. Usage Examples

#### Basic Usage

```swift
import Foundation

class VodozemacExample {
    func demonstrateBasicUsage() {
        // Get library version
        let version = getVersion()
        print("Using vodozemac version: \(version)")
        
        // Base64 encoding
        let data = "Hello, Matrix!".data(using: .utf8)!
        let bytes = Array(data)
        let encoded = base64Encode(input: bytes)
        print("Encoded: \(encoded)")
        
        // Base64 decoding
        let decoded = base64Decode(input: encoded)
        let decodedString = String(bytes: decoded, encoding: .utf8)!
        print("Decoded: \(decodedString)")
    }
}
```

#### Error Handling

```swift
func safeBase64Operations() {
    // The current implementation returns empty array on decode errors
    let invalidBase64 = "invalid!@#$"
    let result = base64Decode(input: invalidBase64)
    
    if result.isEmpty {
        print("Failed to decode invalid base64")
    }
    
    // For production use, consider wrapping in do-catch if needed
}
```

### 6. Testing Integration

#### 6.1 Command Line Verification

Before integrating with Xcode, you can verify the bindings work using the provided command line test:

```bash
# Navigate to the bindings directory
cd path/to/vodozemac/bindings

# Run the Xcode command line test
./xcode-test/run_xcode_test.sh
```

This test script:
- Uses `swiftc` (Xcode's Swift compiler) to compile the bindings
- Links against the vodozemac library
- Tests all available functions (`getVersion`, `base64Encode`, `base64Decode`)
- Includes edge case testing (empty data handling)
- Verifies compatibility with Xcode toolchain
- Provides immediate feedback on any integration issues

**Expected Output:**
```
🔨 Xcode Command Line Test for Vodozemac Swift Bindings
=======================================================
🔍 Checking prerequisites...
   ✅ Swift compiler found: Apple Swift version 6.1.2
   ✅ Generated Swift bindings found
   ✅ Dynamic library found
📋 Copying files for compilation...
🔨 Compiling Swift test program...
✅ Compilation successful!

🚀 Running the test program...
===============================
🧪 Vodozemac Swift Bindings Test
===============================

1. Testing getVersion()...
   Version: 0.9.0
   ✅ PASSED

2. Testing base64 functions...
   Encoded: SGVsbG8sIFdvcmxkIQ
   Decoded: Hello, World!
   ✅ PASSED

3. Testing edge cases...
   Empty data handling: ✅ PASSED

🎉 All tests passed!
✅ Vodozemac Swift bindings are working correctly!
```

#### 6.2 Unit Tests

Create unit tests to verify the bindings work correctly:

```swift
import XCTest

class VodozemacBindingsTests: XCTestCase {
    
    func testVersionAvailability() {
        let version = getVersion()
        XCTAssertEqual(version, "0.9.0")
        XCTAssertFalse(version.isEmpty)
    }
    
    func testBase64RoundTrip() {
        let original = "Test message for vodozemac"
        let data = Array(original.utf8)
        
        let encoded = base64Encode(input: data)
        XCTAssertFalse(encoded.isEmpty)
        
        let decoded = base64Decode(input: encoded)
        let result = String(bytes: decoded, encoding: .utf8)
        
        XCTAssertEqual(result, original)
    }
}
```

#### 6.2 Running Tests

To run the tests:
1. Add the test file to your test target
2. Ensure the vodozemac bindings are available to the test target
3. Run tests via Xcode or `xcodebuild test`

### 7. Dependency Management

#### 7.1 CocoaPods Integration

If using CocoaPods, create a podspec:

**VodozemacBindings.podspec:**
```ruby
Pod::Spec.new do |spec|
  spec.name         = "VodozemacBindings"
  spec.version      = "0.9.0"
  spec.summary      = "Swift bindings for vodozemac cryptographic library"
  spec.homepage     = "https://github.com/matrix-org/vodozemac"
  spec.license      = { :type => "Apache-2.0" }
  spec.author       = { "Matrix.org" => "support@matrix.org" }
  
  spec.ios.deployment_target = "13.0"
  spec.osx.deployment_target = "10.15"
  
  spec.source_files = "VodozemacBindings/*.swift"
  spec.public_header_files = "VodozemacBindings/*.h"
  spec.vendored_libraries = "VodozemacBindings/*.dylib"
  
  spec.module_map = "VodozemacBindings/vodozemacFFI.modulemap"
end
```

#### 7.2 Swift Package Manager

Create a Package.swift:

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "VodozemacBindings",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "VodozemacBindings",
            targets: ["VodozemacBindings"]),
    ],
    targets: [
        .systemLibrary(
            name: "VodozemacFFI",
            path: "Sources/VodozemacFFI",
            pkgConfig: "vodozemac"),
        .target(
            name: "VodozemacBindings",
            dependencies: ["VodozemacFFI"],
            path: "Sources/VodozemacBindings"),
        .testTarget(
            name: "VodozemacBindingsTests",
            dependencies: ["VodozemacBindings"]),
    ]
)
```

### 8. Troubleshooting

#### 8.1 Common Issues

**Module not found errors:**
- Verify `vodozemacFFI.modulemap` is in the correct location
- Check Import Paths in Build Settings
- Ensure the module map syntax is correct

**Library not loaded:**
- Verify `libvodozemac_bindings.dylib` is in Library Search Paths
- Check that the library is added to "Link Binary With Libraries"
- For iOS, ensure the library is copied to the app bundle

**Rust library build fails:**
- Ensure Rust toolchain is installed and up to date
- Check that all dependencies in Cargo.toml are available
- Verify the target architecture matches your Xcode project

#### 8.2 Debug Commands

Use these commands to debug issues:

```bash
# Check library dependencies
otool -L libvodozemac_bindings.dylib

# Verify library symbols
nm -D libvodozemac_bindings.dylib | grep vodozemac

# Check module map syntax
swift -frontend -parse-module-map vodozemacFFI.modulemap
```

### 9. Performance Considerations

- The dynamic library should be relatively small (~1-2 MB)
- Function calls have minimal overhead due to UniFFI's efficient FFI
- Consider caching results for expensive operations
- Profile your app to identify any performance bottlenecks

### 10. Security Notes

- Always validate input data before passing to vodozemac functions
- Be aware that base64 functions may handle invalid input by returning empty results
- Keep the vodozemac library updated to get security fixes
- Consider the implications of storing the dynamic library in your app bundle

## Next Steps

This integration covers the basic base64 utility functions and version access. As the bindings are expanded to include more vodozemac functionality (Olm accounts, sessions, Megolm encryption, etc.), you'll need to update your integration accordingly.

The bindings are designed to be easily extensible - additional functions can be added to the UDL file and regenerated using the same process outlined in this guide.
