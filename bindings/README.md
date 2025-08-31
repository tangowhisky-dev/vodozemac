# Vodozemac UniFFI Bindings

This directory contains UniFFI bindings for the vodozemac cryptographic library, providing Swift language bindings for iOS and macOS development.

## Current Implementation

**Version:** 0.9.0 (matches vodozemac library version)

**Available Functions:**
- `base64Decode(input: String) -> [UInt8]` - Decode base64 string to bytes
- `base64Encode(input: [UInt8]) -> String` - Encode bytes to base64 string
- `getVersion() -> String` - Get the vodozemac library version

## Directory Structure

```
bindings/
├── src/
│   ├── vodozemac.udl          # UniFFI interface definition
│   └── lib.rs                 # Rust bindings implementation
├── generated/                 # Generated Swift bindings
│   ├── vodozemac.swift        # Swift API
│   ├── vodozemacFFI.h         # C header
│   └── vodozemacFFI.modulemap # Module map
├── tests/
│   └── VodozemacBindingsTests.swift  # Swift test suite
├── docs/
│   └── XcodeIntegrationGuide.md      # Comprehensive integration guide
├── Cargo.toml                 # Rust project configuration
└── build.rs                   # Build script

```

## Quick Start

### 1. Build the Bindings

```bash
# From the bindings directory
cargo build
```

### 2. Generate Swift Bindings

```bash
# Generate Swift bindings using UniFFI CLI
/Users/tango16/.cargo/bin/uniffi-bindgen generate \
  --library ../target/debug/libvodozemac_bindings.dylib \
  --language swift \
  --out-dir ./generated
```

### 3. Use in Swift

```swift
// Get library version
let version = getVersion()
print("Vodozemac version: \(version)")

// Base64 operations
let data = Array("Hello, World!".utf8)
let encoded = base64Encode(input: data)
let decoded = base64Decode(input: encoded)
let result = String(bytes: decoded, encoding: .utf8)!
```

## Integration with Xcode

See the comprehensive [Xcode Integration Guide](docs/XcodeIntegrationGuide.md) for detailed instructions on:

- Adding bindings to your Xcode project
- Configuring build settings and dependencies
- Creating automated build scripts
- Dependency management with CocoaPods/SPM
- Troubleshooting common issues
- Performance and security considerations

## Testing

The bindings include multiple testing approaches to ensure reliability and compatibility:

### Rust Tests

Run the Rust unit tests to verify the binding layer:

```bash
# Build and test the Rust bindings
cargo test
```

### Swift Integration Tests

For comprehensive Swift testing, use the provided test files:

```bash
# Run the Swift integration tests (requires Swift compiler)
swift test_bindings.swift
```

### Xcode Command Line Tests

A comprehensive command line test is provided to verify compatibility with Xcode tools:

```bash
# Run the Xcode command line test
./xcode-test/run_xcode_test.sh
```

This test:
- ✅ Compiles Swift bindings using `swiftc`
- ✅ Links against the vodozemac library
- ✅ Tests all three binding functions (`getVersion`, `base64Encode`, `base64Decode`)
- ✅ Includes edge case testing (empty data handling)
- ✅ Verifies proper Xcode tool integration
- ✅ Uses a temporary directory for isolation
- ✅ Cleans up automatically

**Expected Output:**
```
🔨 Xcode Command Line Test for Vodozemac Swift Bindings
=======================================================
� Checking prerequisites...
   ✅ Swift compiler found: Apple Swift version 6.1.2
   ✅ Generated Swift bindings found
   ✅ Dynamic library found
�📁 Using temporary directory: /var/folders/.../tmp.XXXXXXXX
� Copying files for compilation...
�🔨 Compiling Swift test program...
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

🧹 Cleaning up temporary files...

🎉 XCODE COMMAND LINE TEST PASSED!
==================================
✅ The vodozemac Swift bindings work correctly with Xcode tools
✅ All functions are accessible and working as expected
🚀 Your bindings are ready for integration into Xcode projects!
```

### Manual Testing

For manual verification, you can also test the bindings directly:

## Extending the Bindings

To add more vodozemac functionality to the bindings:

1. **Update the UDL file** (`src/vodozemac.udl`) with new function signatures
2. **Implement the functions** in `src/lib.rs`
3. **Rebuild the library**: `cargo build`
4. **Regenerate bindings**: Use the uniffi-bindgen command
5. **Update tests** to cover new functionality

### Example: Adding a New Function

**UDL (src/vodozemac.udl):**
```idl
namespace vodozemac {
    // Existing functions...
    
    // New function
    string hash_message(string message);
};
```

**Rust (src/lib.rs):**
```rust
fn hash_message(message: String) -> String {
    // Implementation here
}
```

## Development Guidelines

- **Version Sync**: Keep bindings version in sync with vodozemac library version
- **Error Handling**: Handle Rust `Result` types appropriately in the binding layer  
- **Testing**: Add tests for all new functionality
- **Documentation**: Update the integration guide for new features
- **Security**: Be careful with memory management and input validation

## UniFFI Compatibility

- **UniFFI CLI Version**: 0.29.4
- **Contract Version**: 30
- **Supported Languages**: Swift (other languages can be generated)

## Build Requirements

- Rust 1.85+
- UniFFI 0.29.4
- Xcode 13.0+ (for Swift integration)
- iOS 13.0+ / macOS 10.15+ (deployment targets)

## Future Roadmap

Planned additions to the bindings:

- [ ] Olm Account creation and management  
- [ ] Olm Session establishment and messaging
- [ ] Megolm group encryption functionality
- [ ] SAS (Short Authentication String) verification
- [ ] Key backup and restore functionality
- [ ] Error types and proper error handling
- [ ] Async/await support for long-running operations

## Contributing

When contributing to the bindings:

1. Follow the existing code style and patterns
2. Add comprehensive tests for new functionality
3. Update documentation and integration guides
4. Ensure version compatibility with the main vodozemac library
5. Test integration with actual Xcode projects

## Support

For issues related to:
- **Bindings functionality**: Check the vodozemac library documentation
- **UniFFI usage**: See the [UniFFI Book](https://mozilla.github.io/uniffi-rs/)
- **Xcode integration**: Refer to the integration guide in this repository
- **Swift-specific issues**: Check the generated Swift code and FFI headers
