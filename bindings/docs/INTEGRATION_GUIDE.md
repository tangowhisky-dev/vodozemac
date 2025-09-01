# Vodozemac UniFFI Integration Guide

## Overview

Vodozemac is a Rust implementation of the Olm and Megolm cryptographic protocols used by the Matrix protocol for end-to-end encryption. This integration guide covers how to use the UniFFI-generated language bindings to access vodozemac functionality from Swift (iOS) and Kotlin (Android) applications.

### What Vodozemac Provides

- **Olm Protocol**: Double Ratchet implementation for 1:1 encrypted messaging
- **Megolm Protocol**: Group messaging encryption with efficient key rotation
- **SAS Verification**: Short Authentication String verification for cross-signing
- **ECIES**: Integrated encryption scheme for secure channels
- **Cryptographic Primitives**: Curve25519, Ed25519 key operations
- **LibOlm Compatibility**: Import/export compatibility with existing Matrix clients

### Supported Platforms

- **iOS**: 13.0+ (arm64, x86_64 simulator)
- **Android**: API 21+ (arm64-v8a, armeabi-v7a, x86_64)

### Requirements

- **UniFFI**: Version 0.29
- **Rust**: 1.85+ with target platform support
- **iOS**: Xcode 14+, Swift 5.7+
- **Android**: NDK 25+, Kotlin 1.9+

## iOS Integration

### Xcode Project Setup

1. **Add the Generated Swift Bindings**
   ```bash
   # Copy the generated files to your project
   cp bindings/swift/vodozemac.swift your-project/Sources/
   cp bindings/swift/vodozemacFFI.h your-project/Sources/
   ```

2. **Link the Static Library**
   - Add `libvodozemac_uniffi.a` to your project
   - In Xcode → Build Settings → Other Linker Flags: Add `-lvodozemac_uniffi`
   - In Build Settings → Library Search Paths: Add path to the static library

3. **Configure Build Settings**
   ```
   HEADER_SEARCH_PATHS = path/to/headers
   LIBRARY_SEARCH_PATHS = path/to/libraries
   OTHER_LINKER_FLAGS = -lvodozemac_uniffi -framework Security
   ```

### Swift Package Manager Configuration

Create a `Package.swift` file:

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "VodozemacIntegration",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(name: "Vodozemac", targets: ["Vodozemac"]),
    ],
    targets: [
        .target(
            name: "Vodozemac",
            path: "Sources/Vodozemac",
            sources: ["vodozemac.swift"],
            publicHeadersPath: ".",
            linkerSettings: [
                .linkedLibrary("vodozemac_uniffi"),
                .linkedFramework("Security")
            ]
        ),
    ]
)
```

### Cross-Compilation Build Script

Create `build_ios.sh`:

```bash
#!/bin/bash
set -e

# Install Rust targets
rustup target add aarch64-apple-ios
rustup target add x86_64-apple-ios

# Build for device (arm64)
cargo build --target aarch64-apple-ios --release

# Build for simulator (x86_64)  
cargo build --target x86_64-apple-ios --release

# Create universal binary
lipo -create \
    target/aarch64-apple-ios/release/libvodozemac_uniffi.a \
    target/x86_64-apple-ios/release/libvodozemac_uniffi.a \
    -output libvodozemac_uniffi_universal.a

echo "iOS universal library created: libvodozemac_uniffi_universal.a"
```

### Example Usage in Swift

```swift
import Foundation
import Vodozemac

class MatrixEncryption {
    private let account: AccountWrapper
    private var sessions: [String: SessionWrapper] = [:]
    
    init() {
        account = AccountWrapper()
        account.generateOneTimeKeys(count: 10)
        account.generateFallbackKey()
    }
    
    func getIdentityKeys() -> IdentityKeysWrapper {
        return account.identityKeys()
    }
    
    func createOutboundSession(identityKey: Data, oneTimeKey: Data) throws -> String {
        let identityKeyWrapper = Curve25519PublicKeyWrapper(key: Array(identityKey))
        let oneTimeKeyWrapper = Curve25519PublicKeyWrapper(key: Array(oneTimeKey))
        
        let session = try account.createOutboundSession(
            identityKey: identityKeyWrapper,
            oneTimeKey: oneTimeKeyWrapper
        )
        
        let sessionId = session.sessionId()
        sessions[sessionId] = session
        return sessionId
    }
    
    func encrypt(sessionId: String, plaintext: String) throws -> String {
        guard let session = sessions[sessionId] else {
            throw MatrixError.sessionNotFound
        }
        return session.encrypt(plaintext: plaintext)
    }
    
    func decrypt(sessionId: String, message: String) throws -> String {
        guard let session = sessions[sessionId] else {
            throw MatrixError.sessionNotFound
        }
        return try session.decrypt(message: message)
    }
}

enum MatrixError: Error {
    case sessionNotFound
}
```

## Android Integration

### Gradle Configuration

Add to your `build.gradle.kts`:

```kotlin
android {
    compileSdk 34
    
    defaultConfig {
        minSdk 21
        ndk {
            abiFilters += setOf("arm64-v8a", "armeabi-v7a", "x86_64")
        }
    }
    
    packagingOptions {
        pickFirst "**/libvodozemac_uniffi.so"
    }
}

dependencies {
    implementation(files("libs/vodozemac.jar"))
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}
```

### JNI Library Setup

1. **Copy Native Libraries**
   ```bash
   # Copy shared libraries to appropriate directories
   mkdir -p app/src/main/jniLibs/arm64-v8a
   mkdir -p app/src/main/jniLibs/armeabi-v7a
   mkdir -p app/src/main/jniLibs/x86_64
   
   cp target/aarch64-linux-android/release/libvodozemac_uniffi.so app/src/main/jniLibs/arm64-v8a/
   cp target/armv7-linux-androideabi/release/libvodozemac_uniffi.so app/src/main/jniLibs/armeabi-v7a/
   cp target/x86_64-linux-android/release/libvodozemac_uniffi.so app/src/main/jniLibs/x86_64/
   ```

2. **Add Generated JAR**
   ```bash
   cp bindings/kotlin/vodozemac.jar app/libs/
   ```

### Cross-Compilation Build Script

Create `build_android.sh`:

```bash
#!/bin/bash
set -e

# Set up Android NDK environment
export NDK_HOME=$ANDROID_NDK_HOME
export CC_aarch64_linux_android=$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android21-clang
export CC_armv7_linux_androideabi=$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/armv7a-linux-androideabi21-clang
export CC_x86_64_linux_android=$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/x86_64-linux-android21-clang

# Install Rust targets
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android

# Build for each Android architecture
cargo build --target aarch64-linux-android --release
cargo build --target armv7-linux-androideabi --release
cargo build --target x86_64-linux-android --release

echo "Android libraries built successfully"
```

### Example Usage in Kotlin

```kotlin
package com.matrix.encryption

import vodozemac.*
import kotlinx.coroutines.*

class MatrixEncryption {
    private val account = AccountWrapper()
    private val sessions = mutableMapOf<String, SessionWrapper>()
    
    init {
        account.generateOneTimeKeys(10u)
        account.generateFallbackKey()
    }
    
    fun getIdentityKeys(): IdentityKeysWrapper {
        return account.identityKeys()
    }
    
    suspend fun createOutboundSession(identityKey: ByteArray, oneTimeKey: ByteArray): String = withContext(Dispatchers.IO) {
        val identityKeyWrapper = Curve25519PublicKeyWrapper(identityKey.toList())
        val oneTimeKeyWrapper = Curve25519PublicKeyWrapper(oneTimeKey.toList())
        
        val session = account.createOutboundSession(identityKeyWrapper, oneTimeKeyWrapper)
        val sessionId = session.sessionId()
        sessions[sessionId] = session
        sessionId
    }
    
    suspend fun encrypt(sessionId: String, plaintext: String): String = withContext(Dispatchers.IO) {
        val session = sessions[sessionId] ?: throw IllegalArgumentException("Session not found")
        session.encrypt(plaintext)
    }
    
    suspend fun decrypt(sessionId: String, message: String): String = withContext(Dispatchers.IO) {
        val session = sessions[sessionId] ?: throw IllegalArgumentException("Session not found")
        session.decrypt(message)
    }
}
```

## API Documentation

### High-Level API Overview

The vodozemac API is organized into several main components:

- **Account Management**: `AccountWrapper` for device identity and key management
- **Session Management**: `SessionWrapper` for 1:1 encrypted conversations
- **Group Sessions**: `GroupSessionWrapper`/`InboundGroupSessionWrapper` for group messaging
- **Verification**: `SasWrapper`/`EstablishedSasWrapper` for device verification
- **Secure Channels**: `EciesWrapper`/`EstablishedEciesWrapper` for secure communication

### Common Usage Patterns

1. **Initialize Device Identity**
   ```swift
   let account = AccountWrapper()
   account.generateOneTimeKeys(count: 50)
   account.generateFallbackKey()
   let identityKeys = account.identityKeys()
   ```

2. **Establish Encrypted Session**
   ```swift
   let session = try account.createOutboundSession(
       identityKey: remoteIdentityKey,
       oneTimeKey: remoteOneTimeKey
   )
   ```

3. **Send Encrypted Message**
   ```swift
   let ciphertext = session.encrypt(plaintext: "Hello, secure world!")
   ```

4. **Receive Encrypted Message**
   ```swift
   let plaintext = try session.decrypt(message: receivedCiphertext)
   ```

### Error Handling Best Practices

All cryptographic operations can fail, so proper error handling is essential:

```swift
do {
    let session = try account.createOutboundSession(identityKey: key, oneTimeKey: otk)
    let encrypted = session.encrypt(plaintext: message)
} catch VodozemacError.invalidKey {
    // Handle invalid key format
} catch VodozemacError.sessionCreationError(let msg) {
    // Handle session creation failure
} catch {
    // Handle other errors
}
```

### Thread Safety Considerations

- **Account objects**: Not thread-safe, use synchronization
- **Session objects**: Not thread-safe, protect with locks/queues
- **Read-only operations**: Generally safe to call concurrently
- **State-modifying operations**: Require exclusive access

### Memory Management Notes

- All wrapper objects are automatically memory-managed by the language runtime
- Large byte arrays (keys, signatures) are copied across FFI boundaries
- Use appropriate disposal patterns for sensitive data when possible

## Troubleshooting

### Common Build Issues

1. **Missing Rust Targets**
   ```bash
   rustup target add aarch64-apple-ios
   rustup target add aarch64-linux-android
   ```

2. **NDK Path Issues**
   ```bash
   export ANDROID_NDK_HOME=/path/to/ndk
   ```

3. **UniFFI Version Mismatch**
   ```bash
   cargo install uniffi_bindgen --version 0.29
   ```

### Runtime Error Debugging

1. **Library Loading Issues**
   - Verify library architecture matches device
   - Check library search paths
   - Ensure all dependencies are included

2. **FFI Call Failures**
   - Validate input parameter formats
   - Check for null/empty values
   - Review error messages for clues

### Performance Considerations

- **Key Generation**: Expensive operation, do sparingly
- **Session Creation**: Moderate cost, cache sessions
- **Encrypt/Decrypt**: Fast operations, can be called frequently
- **Serialization**: JSON operations are CPU-intensive

### Platform-Specific Issues

**iOS:**
- Code signing may affect dynamic loading
- Simulator vs device architecture differences
- App Store review considerations for cryptography

**Android:**
- APK size impact from multiple architectures
- ProGuard/R8 may need configuration
- Permissions for cryptographic operations
