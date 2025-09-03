# Vodozemac Swift Bindings Tests

This directory contains comprehensive tests for the Vodozemac Swift bindings.

## Test Structure

### Consolidated Test Suite
- **`VodozemacComprehensiveTests.swift`** - Single comprehensive XCTest-based test suite that covers all Vodozemac functionality:
  - Base utilities (base64 encoding, version info)
  - Megolm group messaging (all 9 structs and functionality)
  - ECIES end-to-end encryption
  - Olm one-to-one messaging
  - SAS verification protocol  
  - Ed25519 digital signatures
  - Curve25519 key exchange
  - Error handling and edge cases
  - Performance testing

### Test Vector Validation (Currently Outdated)
- **`swift_tests/`** - Swift Package Manager based test suite intended to validate against official test vectors
  - ⚠️ **Status**: Currently uses outdated API (wrapper classes vs direct generated classes)
  - ⚠️ **Test Vectors**: Reference test vector generator has API compatibility issues
  - 💡 **Recommendation**: Use the comprehensive XCTest suite instead for reliable testing
  - 🔧 **Requires Updates**: Would need API modernization to work with current UniFFI generated bindings

### Reference Tests  
- **`kotlin_tests/`** - Kotlin test reference implementations
- **`rust_reference/`** - Rust reference test implementations (currently outdated)

# Vodozemac Swift Bindings Tests

This directory contains comprehensive tests for the Vodozemac Swift bindings.

## Test Structure

### Consolidated XCTest Suite
- **`VodozemacComprehensiveTests.swift`** - Single comprehensive XCTest-based test suite that covers all Vodozemac functionality:
  - Base utilities (base64 encoding, version info)
  - Megolm group messaging (all 9 structs and functionality)
  - ECIES end-to-end encryption
  - Olm one-to-one messaging
  - SAS verification protocol  
  - Ed25519 digital signatures
  - Curve25519 key exchange
  - Error handling and edge cases
  - Performance testing

### Xcode Project
- **`VodozemacTests.xcodeproj`** - Complete Xcode project for running XCTest-based tests
  - Configured with proper library paths and build settings
  - Includes scheme for easy testing
  - Links to generated Swift bindings and Rust library

### Test Vector Validation
- **`swift_tests/`** - Swift Package Manager based test suite that validates against official test vectors
  - Uses structured test data from JSON files
  - Validates implementation against known good values
  - Separate from runtime functionality tests

### Reference Tests
- **`kotlin_tests/`** - Kotlin test reference implementations
- **`rust_reference/`** - Rust reference test implementations

## Running Tests

### ✅ Recommended: Comprehensive XCTest Suite

The most reliable way to test the Vodozemac Swift bindings:

#### Command Line (Easiest)
```bash
cd /Users/tango16/code/vodozemac/bindings/tests
./run_comprehensive_tests.sh
```

#### Xcode GUI
```bash
cd /Users/tango16/code/vodozemac/bindings/tests
open VodozemacTests.xcodeproj
# In Xcode: Press Cmd+U to run tests
```

### ⚠️ Swift Package Manager Tests (Outdated)

The `swift_tests/` directory contains a Swift Package Manager test suite, but it's currently outdated:

**Issues:**
- Uses old API wrapper classes (`AccountWrapper`, `SessionWrapper`) instead of current generated classes (`Account`, `Session`)
- Test vector generation is broken due to Rust API changes
- Requires significant updates to work with current codebase

**To attempt to run (not recommended):**
```bash
cd /Users/tango16/code/vodozemac/bindings/tests
./setup_swift_package_tests.sh  # Shows what needs to be fixed
```

**Better alternative:** Use the comprehensive XCTest suite which is actively maintained and tests all current functionality.

## Test Coverage
```bash
cd /Users/tango16/code/vodozemac/bindings && ./generate_bindings.sh
```

2. Run tests with xcodebuild:
```bash
cd tests
xcodebuild test \
    -project VodozemacTests.xcodeproj \
    -scheme VodozemacTests \
    -destination "platform=macOS"
```

## Prerequisites

- **Xcode** or **Xcode Command Line Tools** (for XCTest framework)
- **Rust toolchain** (for building the native library)
- **macOS** (tests are configured for macOS target)

To install Xcode Command Line Tools:
```bash
xcode-select --install
```

## Test Coverage

The comprehensive test suite covers:

### ✅ Megolm Group Messaging
- `MegolmSessionConfig` (v1 & v2)
- `GroupSession` creation and management
- `InboundGroupSession` handling
- `SessionKey` serialization
- `ExportedSessionKey` import/export
- `MegolmMessage` encryption/decryption
- `DecryptedMessage` processing
- `GroupSessionPickle` & `InboundGroupSessionPickle` persistence
- Session comparison and ordering

### ✅ ECIES End-to-End Encryption
- Channel establishment (outbound/inbound)
- Bidirectional encryption/decryption
- Check code verification
- Key exchange protocols

### ✅ Olm One-to-One Messaging
- Account creation and key management
- Session establishment (pre-key messages)
- Regular message encryption/decryption
- Account and session pickling
- One-time key generation

### ✅ SAS Verification
- Public key exchange
- Shared secret generation
- Emoji, decimal, and byte representations
- Cross-verification consistency

### ✅ Cryptographic Primitives
- Ed25519 digital signatures
- Curve25519 key exchange
- Key serialization (base64, bytes)
- Signature verification

### ✅ Error Handling & Edge Cases
- Invalid input handling
- Malformed data processing
- Incorrect parameter validation
- Exception propagation

### ✅ Performance Testing
- Built-in XCTest performance measurement
- Megolm message encryption benchmarking

## Test Philosophy

This consolidated XCTest approach provides:
1. **Professional Testing Framework** - Uses Apple's standard XCTest framework
2. **IDE Integration** - Full Xcode integration with test navigation and debugging
3. **Comprehensive Coverage** - All functionality tested in one unified suite
4. **Maintainability** - Single source of truth for API validation
5. **Performance Metrics** - Built-in performance measurement capabilities
6. **Latest API** - Based on up-to-date xcode-test implementations
7. **CI/CD Ready** - Can be integrated into automated testing pipelines

## Project Structure

```
tests/
├── VodozemacComprehensiveTests.swift     # Main test suite
├── VodozemacTests.xcodeproj/            # Xcode project
│   ├── project.pbxproj                  # Project configuration
│   └── xcshareddata/xcschemes/          # Shared schemes
├── run_comprehensive_tests.sh           # Command-line test runner
├── swift_tests/                         # SPM test vectors
├── kotlin_tests/                        # Kotlin reference
├── rust_reference/                      # Rust reference
└── README.md                           # This file
```

## Cleanup Completed

The following duplicate test files were removed during consolidation:
- `VodozemacBindingsTests.swift` (basic tests - functionality moved to comprehensive suite)
- `test_megolm_bindings.swift` (megolm-specific tests - integrated into comprehensive suite)

The Swift Package Manager test structure (`swift_tests/`) was preserved as it serves a different purpose (test vector validation vs runtime testing).

## Integration with CI/CD

The XCTest suite can be integrated into continuous integration pipelines:

```bash
# Generate bindings
cd vodozemac/bindings && ./generate_bindings.sh

# Run tests
cd tests
xcodebuild test \
    -project VodozemacTests.xcodeproj \
    -scheme VodozemacTests \
    -destination "platform=macOS" \
    -resultBundlePath TestResults.xcresult
```

This will generate detailed test reports in Xcode's result bundle format for further analysis.

## Test Coverage

The comprehensive test suite covers:

### ✅ Megolm Group Messaging
- `MegolmSessionConfig` (v1 & v2)
- `GroupSession` creation and management
- `InboundGroupSession` handling
- `SessionKey` serialization
- `ExportedSessionKey` import/export
- `MegolmMessage` encryption/decryption
- `DecryptedMessage` processing
- `GroupSessionPickle` & `InboundGroupSessionPickle` persistence
- Session comparison and ordering

### ✅ ECIES End-to-End Encryption
- Channel establishment (outbound/inbound)
- Bidirectional encryption/decryption
- Check code verification
- Key exchange protocols

### ✅ Olm One-to-One Messaging
- Account creation and key management
- Session establishment (pre-key messages)
- Regular message encryption/decryption
- Account and session pickling
- One-time key generation

### ✅ SAS Verification
- Public key exchange
- Shared secret generation
- Emoji, decimal, and byte representations
- Cross-verification consistency

### ✅ Cryptographic Primitives
- Ed25519 digital signatures
- Curve25519 key exchange
- Key serialization (base64, bytes)
- Signature verification

### ✅ Error Handling & Edge Cases
- Invalid input handling
- Malformed data processing
- Incorrect parameter validation
- Exception propagation

## Test Philosophy

This consolidated approach provides:
1. **Comprehensive Coverage** - All functionality tested in one place
2. **Maintainability** - Single source of truth for API validation
3. **Performance** - Included performance benchmarking
4. **Real-world Usage** - Tests mirror actual application patterns
5. **Latest API** - Based on up-to-date xcode-test implementations

## Cleanup Completed

The following duplicate test files were removed during consolidation:
- `VodozemacBindingsTests.swift` (basic tests - functionality moved to comprehensive suite)
- `test_megolm_bindings.swift` (megolm-specific tests - integrated into comprehensive suite)

The Swift Package Manager test structure (`swift_tests/`) was preserved as it serves a different purpose (test vector validation vs runtime testing).

## iOS Support

### Multi-Platform Library Generation

The `generate_bindings.sh` script now builds libraries for all iOS and macOS targets:

```bash
cd ../bindings
./generate_bindings.sh
```

This generates libraries for:

#### 📱 **iOS Device (Physical iPhone/iPad)**
- **Target**: `aarch64-apple-ios` 
- **Library**: `generated/swift/ios-device/libvodozemac_bindings.dylib`
- **Architecture**: ARM64 only
- **Usage**: Link this library for iOS device builds

#### 🖥️ **iOS Simulator**  
- **Targets**: `x86_64-apple-ios`, `aarch64-apple-ios-sim`
- **Libraries**: 
  - Individual: `libvodozemac_bindings_x86_64.dylib`, `libvodozemac_bindings_arm64.dylib`
  - **Universal**: `libvodozemac_bindings_universal.dylib` (recommended)
- **Architectures**: x86_64 (Intel Mac) + ARM64 (Apple Silicon Mac)
- **Usage**: Link the universal library for iOS simulator builds

#### 🖥️ **macOS**
- **Targets**: `x86_64-apple-darwin`, `aarch64-apple-darwin` 
- **Libraries**:
  - Individual: `libvodozemac_bindings_x86_64.dylib`, `libvodozemac_bindings_arm64.dylib`
  - **Universal**: `libvodozemac_bindings_universal.dylib` (recommended)
- **Architectures**: x86_64 (Intel Mac) + ARM64 (Apple Silicon Mac)
- **Usage**: Link the universal library for macOS builds

### Integration Guide

#### For Xcode iOS Projects

1. **Generate Libraries**:
   ```bash
   cd path/to/vodozemac/bindings
   ./generate_bindings.sh
   ```

2. **Add Swift Files**:
   - Copy `generated/swift/vodozemac.swift` to your Xcode project
   - Copy `generated/swift/vodozemacFFI.h` to your Xcode project  
   - Copy `generated/swift/vodozemacFFI.modulemap` to your Xcode project

3. **Configure Build Settings**:
   ```
   SWIFT_INCLUDE_PATHS = path/to/generated/swift
   OTHER_SWIFT_FLAGS = -Xcc -fmodule-map-file=path/to/generated/swift/vodozemacFFI.modulemap
   LIBRARY_SEARCH_PATHS = path/to/generated/swift/[ios-device|ios-simulator|macos]
   OTHER_LDFLAGS = -lvodozemac_bindings
   ```

4. **Add Libraries to Build Phases**:
   - For iOS Device: Add `ios-device/libvodozemac_bindings.dylib`
   - For iOS Simulator: Add `ios-simulator/libvodozemac_bindings_universal.dylib`
   - For macOS: Add `macos/libvodozemac_bindings_universal.dylib`

#### Swift Import
```swift
import Foundation
import vodozemacFFI  // Module defined by modulemap

// Use Vodozemac APIs
let account = Account()
let version = getVersion()
```

### Library Specifications

| Platform | Architecture | File Size | Format |
|----------|-------------|-----------|---------|
| iOS Device | arm64 | ~6.6MB | .dylib |
| iOS Simulator | x86_64 + arm64 | ~14MB | .dylib (universal) |
| macOS | x86_64 + arm64 | ~13MB | .dylib (universal) |

### Compatibility

- ✅ **iOS 13.0+** (minimum deployment target)
- ✅ **macOS 11.0+** (minimum deployment target)  
- ✅ **Xcode 12.0+** (for building)
- ✅ **Swift 5.3+** (language version)

The `.dylib` format works for both iOS and macOS when properly configured in Xcode build settings.
