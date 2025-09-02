# Vodozemac UniFFI Bindings

This directory contains UniFFI bindings for the vodozemac cryptographic library, generating Swift, Kotlin, and Python bindings from Rust code.

## Architecture

The bindings use [Mozilla UniFFI](https://mozilla.github.io/uniffi-rs/) to automatically generate language bindings. This crate now relies exclusively on procedural macros via `#[derive(uniffi::Object)]` and `#[uniffi::export]`. UDL files are no longer used.

## Quick Start

### Generate Bindings

```bash
./generate_bindings.sh
```

### Test Bindings

```bash
# Run comprehensive Swift tests
./xcode-test/run_xcode_test.sh comprehensive

# Run basic Swift tests  
./xcode-test/run_xcode_test.sh basic
```

## Project Structure

```
bindings/
├── src/
│   └── lib.rs              # Main Rust implementations (proc-macro based)
├── generated/              # Auto-generated bindings (Swift/Kotlin/Python)
├── xcode-test/             # Swift testing infrastructure  
├── generate_bindings.sh    # Main build script
└── README.md               # This file
```

## Adding New API Bindings

### ⚠️ Important: Use Procedural Macros for Objects

**Key Learning**: For complex object types, use procedural macros instead of UDL interfaces to avoid UniFFI checksum mismatches.

### ✅ Recommended Approach: Procedural Macros

For complex structs with methods, use this approach:

#### 1. Define the Rust Struct

```rust
/// Wrapper around vodozemac::YourType
#[derive(uniffi::Object)]
pub struct YourType(vodozemac::YourType);

#[uniffi::export]
impl YourType {
    /// Constructor
    #[uniffi::constructor]
    pub fn new() -> std::sync::Arc<Self> {
        std::sync::Arc::new(Self(vodozemac::YourType::new()))
    }

    /// Constructor with error handling
    #[uniffi::constructor]
    pub fn from_data(data: Vec<u8>) -> Result<std::sync::Arc<Self>, VodozemacError> {
        let inner = vodozemac::YourType::from_data(&data)
            .map_err(|e| VodozemacError::Key(e.to_string()))?;
        Ok(std::sync::Arc::new(Self(inner)))
    }

    /// Method returning data
    pub fn to_bytes(&self) -> Vec<u8> {
        self.0.to_bytes().to_vec()
    }

    /// Method returning another object
    pub fn get_related(&self) -> std::sync::Arc<AnotherType> {
        std::sync::Arc::new(AnotherType(self.0.get_related()))
    }
}
```

#### 2. No UDL Interface Needed

With procedural macros, **don't add interface definitions** to the `.udl` file. UniFFI will automatically generate the interface from the macro annotations.

### Note on UDL

UDL support has been removed from this bindings crate to avoid API checksum mismatches and duplication. If reintegration is needed later, add a `build.rs` with `uniffi::generate_scaffolding` and reintroduce a `.udl` file.

## Key Patterns

### Constructor Patterns

```rust
// Simple constructor
#[uniffi::constructor]
pub fn new() -> std::sync::Arc<Self> {
    std::sync::Arc::new(Self(Inner::new()))
}

// Constructor with error handling
#[uniffi::constructor]  
pub fn from_data(data: Vec<u8>) -> Result<std::sync::Arc<Self>, VodozemacError> {
    // ... error handling
    Ok(std::sync::Arc::new(Self(inner)))
}
```

### Method Patterns

```rust
// Method returning primitive data
pub fn to_string(&self) -> String {
    self.0.to_string()
}

// Method returning bytes
pub fn to_bytes(&self) -> Vec<u8> {
    self.0.as_bytes().to_vec()
}

// Method returning another object
pub fn get_public_key(&self) -> std::sync::Arc<PublicKey> {
    std::sync::Arc::new(PublicKey(self.0.public_key()))
}
```

### Error Handling

Always use the custom `VodozemacError` enum for consistency:

```rust
pub fn fallible_method(data: Vec<u8>) -> Result<String, VodozemacError> {
    vodozemac_operation(&data)
        .map_err(|e| VodozemacError::Key(e.to_string()))
}
```

## Troubleshooting

### Checksum Mismatch Errors

**Problem**: `UniFFI API checksum mismatch`

**Solution**: You're likely mixing UDL interfaces with manual implementations. Switch to procedural macros:

1. Remove the `interface` definition from `.udl`
2. Add `#[derive(uniffi::Object)]` to your struct
3. Add `#[uniffi::export]` to your impl block
4. Use `#[uniffi::constructor]` for constructors

### Build Failures

**Problem**: Compilation errors with procedural macros

**Common Issues**:
- Missing `std::sync::Arc<Self>` return types for constructors
- Incompatible error types (use `VodozemacError`)
- Missing trait implementations on custom types

### Testing

Always test your changes:

```bash
# Clean rebuild
./generate_bindings.sh

# Test the bindings
./xcode-test/run_xcode_test.sh comprehensive
```

## Examples

See the existing implementations in `src/lib.rs`:

- `KeyId`: Simple object with constructor and method
- `Curve25519PublicKey`: Complex object with multiple constructors and error handling  
- `Curve25519SecretKey`: Object returning other objects

## Version Compatibility

- UniFFI: 0.29.4
- Contract Version: 29 (modified from default 30 for compatibility)
- Rust: Uses 2021 edition
- Swift: Compatible with Xcode command line tools

## References

- [UniFFI Book](https://mozilla.github.io/uniffi-rs/)
- [Procedural Macros Guide](https://mozilla.github.io/uniffi-rs/proc_macro/index.html)
- [UniFFI Examples](https://github.com/mozilla/uniffi-rs/tree/main/examples)
