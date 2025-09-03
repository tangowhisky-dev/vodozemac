# Vodozemac Rust Reference Implementation

## Overview

This Rust reference implementation serves as the **canonical test vector generator** for the Vodozemac cryptographic library. It generates comprehensive JSON test vectors that can be used for:

- **Cross-platform binding validation** (Swift, Kotlin, etc.)
- **Regression testing** across Vodozemac versions
- **API compatibility verification**
- **Reference implementation validation**

## Architecture

### Core Components

1. **Test Vector Structures**
   - Comprehensive data structures for all cryptographic operations
   - JSON serialization for cross-platform compatibility
   - Typed test cases for each API component

2. **Test Generators**
   - `generate_account_tests()` - Olm account operations (key generation, signing)
   - `generate_session_tests()` - Olm session encryption/decryption *(planned)*
   - `generate_group_session_tests()` - Megolm group messaging (v1 & v2)
   - `generate_sas_tests()` - Short Authentication String verification
   - `generate_ecies_tests()` - Elliptic Curve Integrated Encryption *(planned)*
   - `generate_utility_tests()` - Base64 encoding/decoding and version info

3. **Output Format**
   - Structured JSON test vectors (`../test_vectors.json`)
   - Human-readable with proper formatting
   - Consumed by binding test suites

## How It Works

### 1. Dependency Management

```toml
[dependencies]
vodozemac = { path = "../../../", default-features = false, features = ["libolm-compat"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
base64 = "0.22"
```

- Uses the **local Vodozemac crate** from the project root
- Enables `libolm-compat` for backward compatibility testing
- JSON serialization via Serde

### 2. Test Vector Generation Process

#### Account Tests
```rust
let mut account = Account::new();
let identity_keys = account.identity_keys();

// Generate one-time keys and fallback keys
account.generate_one_time_keys(5);
account.generate_fallback_key();

// Test digital signatures
let signature = account.sign("Test message");
```

#### Megolm Group Session Tests  
```rust
// Test both v1 (truncated MAC) and v2 (full MAC)
let config_v1 = SessionConfig::version_1();
let mut group_session = GroupSession::new(config_v1);

// Encrypt and decrypt messages
let encrypted = group_session.encrypt(plaintext.as_bytes());
let mut inbound_session = InboundGroupSession::new(&session_key, config_v1);
let decrypted = inbound_session.decrypt(&encrypted);
```

#### SAS (Short Authentication String) Tests
```rust
let alice_sas = Sas::new();
let bob_sas = Sas::new();

// Diffie-Hellman key exchange
let alice_established = alice_sas.diffie_hellman(bob_public_key);
let bob_established = bob_sas.diffie_hellman(alice_public_key);

// Generate verification codes
let sas_bytes = alice_established.bytes(info);
let emoji_indices = sas_bytes.emoji_indices();
let decimals = sas_bytes.decimals();
```

### 3. Current Implementation Status

| Component | Status | Test Count | Notes |
|-----------|--------|------------|-------|
| **Account** | ✅ Implemented | 1 | Key generation, signing |
| **Utility** | ✅ Implemented | 8 | Base64 encode/decode, version |
| **Group Session** | ✅ Implemented | 2 | Megolm v1 & v2 |
| **SAS** | ✅ Implemented | 1 | Key verification, MAC |
| **Session** | ⚠️ Planned | 0 | Complex protocol handling |
| **ECIES** | ⚠️ Planned | 0 | API availability pending |

### 4. Generated Test Vector Structure

```json
{
  "account_tests": [
    {
      "name": "Basic Account Operations",
      "identity_keys": { "curve25519": "...", "ed25519": "..." },
      "one_time_keys": { "KeyId(0)": "..." },
      "signature": "..."
    }
  ],
  "group_session_tests": [
    {
      "name": "Megolm v1 Group Session Test",
      "session_id": "...",
      "encrypted_message": "...",
      "decrypted_message": "..."
    }
  ],
  "sas_tests": [...],
  "utility_tests": {...}
}
```

## Usage

### Generate Test Vectors

```bash
cd bindings/tests/rust_reference
cargo run
```

**Output:**
- Generates `../test_vectors.json` with comprehensive test data
- Console shows generation progress and statistics
- All test vectors include both input data and expected outputs

### Integration with Bindings

The generated test vectors are consumed by:

1. **Swift Package Manager Tests** (`swift_tests/`)
   - Validates Swift bindings against reference vectors
   - Ensures API compatibility across platforms

2. **Future Binding Tests** (Kotlin, Python, etc.)
   - Common test vector format for all language bindings
   - Consistent validation across platforms

## Technical Details

### API Coverage

- **Cryptographic Primitives**: Curve25519, Ed25519
- **Olm Protocol**: Account management, key generation, signatures  
- **Megolm Protocol**: Group session encryption (v1 & v2)
- **SAS Protocol**: Key verification, emoji codes, decimal codes
- **Utilities**: Base64 encoding/decoding, version information

### Error Handling

```rust
let decrypted = inbound_session.decrypt(&encrypted)
    .expect("Failed to decrypt");
```

- Uses `.expect()` for test vector generation (should always succeed)
- Real-world usage would use proper error handling
- Any failure indicates a bug in the test generation or library

### Platform Independence

- All test vectors use **base64 encoding** for binary data
- **JSON format** ensures cross-platform compatibility
- **Deterministic generation** for reproducible test results

## Future Enhancements

### Planned Features

1. **Olm Session Tests**
   - Pre-key message handling
   - Session establishment protocol
   - Message encryption/decryption chains

2. **ECIES Tests**
   - Elliptic Curve Integrated Encryption
   - Key derivation and message authentication

3. **Error Case Testing**
   - Invalid input handling
   - Malformed message processing
   - Edge case validation

4. **Performance Benchmarking**
   - Operation timing data
   - Memory usage profiling
   - Scalability testing

### Extensibility

The modular design allows easy addition of new test generators:

```rust
fn generate_new_feature_tests() -> Vec<NewFeatureTest> {
    // Implementation here
}

// Add to main test vector generation
let test_vectors = TestVectors {
    new_feature_tests: generate_new_feature_tests(),
    // ...existing tests
};
```

## Maintenance

- **Update when API changes** - Keep in sync with Vodozemac API evolution
- **Version compatibility** - Test vectors include version information
- **Cross-reference with bindings** - Ensure binding tests use latest vectors
- **Documentation updates** - Keep README current with implementation

This reference implementation ensures that all Vodozemac language bindings maintain compatibility and correctness with the core Rust implementation.
