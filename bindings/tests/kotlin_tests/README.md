# Vodozemac Kotlin Bindings Test Suite

This directory contains comprehensive tests for the Vodozemac Kotlin bindings, providing validation of the Matrix cryptographic library's functionality through Kotlin/JVM interfaces.

## 📋 Table of Contents

- [Overview](#overview)
- [Test Coverage](#test-coverage)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Running Tests](#running-tests)
- [Test Details](#test-details)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)
- [Development](#development)

## 🔍 Overview

The Kotlin test suite validates the UniFFI-generated Kotlin bindings for Vodozemac, ensuring:

- **API Correctness**: All public APIs work as expected
- **Test Vector Validation**: Compatibility with reference implementations
- **Memory Safety**: Proper native library loading and resource management
- **Error Handling**: Graceful handling of edge cases and invalid inputs
- **Cross-Platform Support**: Universal binary compatibility (ARM64/x86_64)

## 🧪 Test Coverage

### **1. BasicLoadTest** (1 test)
- **Purpose**: Validates native library loading and basic functionality
- **Coverage**: 
  - JNA library loading
  - Vodozemac version verification
  - Native resource access

### **2. VodozemacAPITest** (8 tests)
- **Purpose**: Comprehensive API functionality testing
- **Coverage**:
  - **Account Lifecycle**: Creation, pickling/unpickling, key generation
  - **Session Communication**: Olm session establishment and message exchange
  - **Group Sessions**: Megolm group session creation and message handling
  - **SAS Verification**: Short Authentication String flows
  - **ECIES Channels**: Elliptic Curve Integrated Encryption Scheme
  - **Multiple Sessions**: Concurrent session management
  - **Edge Cases**: Invalid inputs, boundary conditions
  - **Utility Functions**: Base64 encoding, key derivation, random generation

### **3. VodozemacComprehensiveTest** (7 tests)
- **Purpose**: Test vector validation against reference implementations
- **Coverage**:
  - **Account Operations**: JSON test vectors from Rust implementation
  - **Session Operations**: Olm session test vectors
  - **Group Session Operations**: Megolm v1/v2 test vectors
  - **SAS Operations**: Verification flow test vectors
  - **ECIES Operations**: Encryption/decryption test vectors
  - **Error Handling**: Invalid input rejection
  - **Utility Functions**: Cross-implementation compatibility

**Total Test Count: 16 tests**

## ⚙️ Prerequisites

### **System Requirements**
- **Operating System**: macOS (ARM64/x86_64), Linux, Windows
- **Java**: JDK 11 or higher
- **Gradle**: 7.0+ (or use included wrapper)

### **Kotlin/Java Dependencies**
- **Kotlin**: 2.0.20
- **JNA**: 5.13.0 (for native library access)
- **JUnit**: 4.13.2 (testing framework)
- **kotlinx-serialization**: 1.6.0 (JSON processing)

### **Native Libraries**
- **Vodozemac Bindings**: Generated dylib files must be present
- **UniFFI Runtime**: Included in generated bindings

### **Generated Files Required**
```
generated/kotlin/
├── uniffi/
│   └── vodozemac/
│       └── vodozemac.kt              # Generated Kotlin bindings
├── libvodozemac_bindings_universal.dylib  # Universal binary (ARM64+x86_64)
├── libvodozemac_bindings_arm64.dylib      # ARM64 specific
└── libvodozemac_bindings_x86_64.dylib     # x86_64 specific

tests/
└── test_vectors.json                 # JSON test data
```

## 🚀 Quick Start

### **1. Generate Bindings** (if not already done)
```bash
cd /path/to/vodozemac/bindings
./generate_bindings.sh
```

### **2. Run All Tests**
```bash
cd bindings/tests/kotlin_tests
./run_kotlin_tests.sh
```

### **3. View Results**
```bash
# Check console output for summary
# Open HTML report for detailed results
open build/reports/tests/test/index.html
```

## 🏃 Running Tests

### **Using the Test Script**

#### **Run All Tests**
```bash
./run_kotlin_tests.sh
```

#### **Force Refresh Resources**
```bash
./run_kotlin_tests.sh --force-refresh
```
*Useful when bindings or libraries have been updated*

#### **Get Help**
```bash
./run_kotlin_tests.sh --help
```

### **Using Gradle Commands**

#### **Run All Tests**
```bash
gradle test
```

#### **Run Specific Test Class**
```bash
# API functionality tests
gradle test --tests VodozemacAPITest

# Test vector validation
gradle test --tests VodozemacComprehensiveTest

# Library loading test
gradle test --tests BasicLoadTest
```

#### **Run Individual Test Methods**
```bash
# Test account lifecycle
gradle test --tests VodozemacAPITest.testAccountLifecycle

# Test SAS verification
gradle test --tests VodozemacAPITest.testSasVerificationFlow

# Test group session operations
gradle test --tests VodozemacComprehensiveTest.testGroupSessionOperations
```

#### **Build and Test**
```bash
gradle clean build test
```

#### **Continuous Testing**
```bash
gradle test --continuous
```

#### **Debug Mode**
```bash
gradle test --debug-jvm
```

#### **Verbose Output**
```bash
gradle test --info --stacktrace
```

### **IDE Integration**

#### **IntelliJ IDEA / Android Studio**
1. Open the `kotlin_tests` directory as a Gradle project
2. Right-click on test classes/methods and select "Run"
3. Use the built-in test runner for debugging

#### **VS Code**
1. Install the Gradle and Kotlin extensions
2. Use the Test Explorer to run individual tests
3. Set breakpoints for debugging

## 📖 Test Details

### **VodozemacAPITest** - API Functionality

#### **testAccountLifecycle**
- Creates and validates Vodozemac accounts
- Tests pickling and unpickling operations
- Verifies identity and one-time keys

#### **testSessionCommunication**
- Establishes Olm sessions between accounts
- Tests pre-key and normal message encryption/decryption
- Validates message ordering and session state

#### **testGroupSessionScenario**
- Creates outbound and inbound group sessions
- Tests group message encryption and decryption
- Validates session key sharing and message indices

#### **testSasVerificationFlow**
- Tests Short Authentication String generation
- Validates verification flows and MAC calculations
- Tests cross-signing scenarios

#### **testEciesChannelEstablishment**
- Creates ECIES channels for secure communication
- Tests message encryption and decryption
- Validates key exchange and channel establishment

#### **testMultipleSessionsPerAccount**
- Tests concurrent session management
- Validates session isolation and independence
- Tests resource cleanup

#### **testEdgeCases**
- Invalid base64 input handling
- Malformed message rejection
- Boundary condition testing

#### **testUtilityFunctions**
- Base64 encoding/decoding
- Random number generation
- Key derivation functions

### **VodozemacComprehensiveTest** - Test Vector Validation

#### **testAccountOperations**
- Validates against JSON test vectors from Rust implementation
- Tests account creation, key generation, and serialization
- Ensures cross-implementation compatibility

#### **testSessionOperations**
- Tests Olm session establishment with reference data
- Validates message encryption/decryption against known vectors
- Ensures protocol compatibility

#### **testGroupSessionOperations**
- Tests Megolm v1 and v2 group sessions
- Validates against reference implementation test vectors
- Tests backward compatibility

#### **testSasOperations**
- Validates SAS flows against test vectors
- Tests MAC calculation and verification
- Ensures cryptographic correctness

#### **testEciesOperations**
- Tests ECIES encryption/decryption with known vectors
- Validates key exchange mechanisms
- Ensures secure channel establishment

#### **testErrorHandling**
- Tests proper rejection of invalid inputs
- Validates error messages and codes
- Ensures graceful failure handling

#### **testUtilityFunctions**
- Cross-validates utility functions against reference implementation
- Tests encoding/decoding consistency
- Validates mathematical operations

## 📁 Project Structure

```
kotlin_tests/
├── README.md                          # This documentation
├── build.gradle.kts                   # Gradle build configuration
├── settings.gradle                    # Gradle settings
├── gradle.properties                  # Gradle properties
├── run_kotlin_tests.sh               # Test execution script
│
├── src/
│   ├── main/
│   │   ├── kotlin/
│   │   │   └── uniffi/
│   │   │       └── vodozemac/
│   │   │           └── vodozemac.kt   # Generated Kotlin bindings
│   │   └── resources/
│   │       ├── libvodozemac_bindings_universal.dylib
│   │       ├── libvodozemac_bindings_arm64.dylib
│   │       └── libvodozemac_bindings_x86_64.dylib
│   │
│   └── test/
│       ├── kotlin/
│       │   ├── BasicLoadTest.kt       # Library loading tests
│       │   ├── VodozemacAPITest.kt    # API functionality tests
│       │   └── VodozemacComprehensiveTest.kt  # Test vector validation
│       └── resources/
│           └── test_vectors.json      # Test data from Rust implementation
│
└── build/                             # Gradle build outputs
    ├── classes/                       # Compiled classes
    ├── test-results/                  # XML test results
    └── reports/
        └── tests/
            └── test/
                └── index.html         # HTML test report
```

## 🔧 Troubleshooting

### **Common Issues**

#### **"Library not found" errors**
```bash
# Ensure native libraries are present
ls -la src/main/resources/*.dylib

# Force refresh resources
./run_kotlin_tests.sh --force-refresh
```

#### **"Class not found" errors**
```bash
# Clean and rebuild
gradle clean build
```

#### **Test vector loading failures**
```bash
# Verify test vectors file
ls -la src/test/resources/test_vectors.json

# Check file permissions
chmod 644 src/test/resources/test_vectors.json
```

#### **Architecture compatibility issues**
```bash
# Check library architectures
file src/main/resources/*.dylib

# Use universal binary for compatibility
ln -sf libvodozemac_bindings_universal.dylib src/main/resources/libvodozemac_bindings.dylib
```

### **Debug Commands**

#### **Verify Environment**
```bash
java -version
gradle --version
./run_kotlin_tests.sh --help
```

#### **Check Dependencies**
```bash
gradle dependencies --configuration testRuntimeClasspath
```

#### **Verbose Test Output**
```bash
gradle test --info --stacktrace
```

#### **Debug Native Library Loading**
```bash
gradle test -Djna.debug_load=true -Djna.debug_load.jna=true
```

## 🛠 Development

### **Adding New Tests**

#### **API Tests** (VodozemacAPITest.kt)
```kotlin
@Test
fun testNewFeature() {
    println("🧪 Testing new feature...")
    // Test implementation
    println("✅ New feature validated")
}
```

#### **Test Vector Tests** (VodozemacComprehensiveTest.kt)
```kotlin
@Test
fun testNewVectors() {
    println("📊 Testing new vectors...")
    val vectors = loadTestVectors()
    // Vector validation
    println("✅ New vectors validated")
}
```

### **Updating Dependencies**

#### **build.gradle.kts**
```kotlin
dependencies {
    implementation("net.java.dev.jna:jna:5.13.0")
    testImplementation("junit:junit:4.13.2")
    // Add new dependencies here
}
```

### **Regenerating Bindings**
```bash
cd ../../
./generate_bindings.sh
cd tests/kotlin_tests
./run_kotlin_tests.sh --force-refresh
```

### **Performance Testing**
```bash
# Run with timing
gradle test --profile

# Check performance report
open build/reports/profile/profile-*.html
```

---

## 📊 Test Results Example

```
🧪 Running Kotlin tests...

Running all test suites:
  - VodozemacAPITest (API functionality)
  - VodozemacComprehensiveTest (test vectors)
  - BasicLoadTest (library loading)

✅ Tests passed: 16/16

📊 Test Results Summary:
========================
✅ BasicLoadTest: 1/1 tests passed
✅ VodozemacAPITest: 8/8 tests passed
✅ VodozemacComprehensiveTest: 7/7 tests passed

🎉 All Kotlin tests completed successfully!
```

For more information about the Vodozemac library itself, see the main project documentation.
