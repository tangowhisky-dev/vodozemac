# UniFFI Binding Expansion Guide

## The Checksum Mismatch Problem

When expanding UniFFI bindings, you may encounter this error:

```
UniFFI API checksum mismatch: try cleaning and rebuilding your project
```

This document explains the root cause and the proven solution.

## Root Cause Analysis

UniFFI uses **cryptographic checksums** to validate that method signatures match exactly between:
1. UDL interface definitions
2. Rust implementations  
3. Generated bindings

### The Mismatch

When you define an interface in UDL like this:

```udl
interface Curve25519PublicKey {
    bytes as_bytes();
    string to_base64();
}
```

UniFFI generates scaffolding code expecting functions with specific signatures:

```rust
// Generated scaffolding (invisible to you)
#[::uniffi::export_for_udl]
impl r#Curve25519PublicKey {
    pub fn r#as_bytes(&self) -> ::std::vec::Vec<u8> {
        unreachable!()  // Your implementation should replace this
    }
}
```

But if you manually implement:

```rust
// Your manual implementation  
impl Curve25519PublicKey {
    pub fn as_bytes(&self) -> Vec<u8> {
        // ...
    }
}
```

The signatures don't match exactly (`r#Curve25519PublicKey` vs `Curve25519PublicKey`, etc.), causing checksum mismatches.

## The Solution: Procedural Macros

Instead of UDL interfaces, use procedural macros:

### ❌ Before (UDL + Manual Implementation)

**vodozemac.udl**:
```udl
interface Curve25519PublicKey {
    bytes as_bytes();
    string to_base64();
}
```

**lib.rs**:
```rust
pub struct Curve25519PublicKey(vodozemac::Curve25519PublicKey);

impl Curve25519PublicKey {
    pub fn as_bytes(&self) -> Vec<u8> { /* ... */ }
    pub fn to_base64(&self) -> String { /* ... */ }
}
```

**Result**: Checksum mismatch ❌

### ✅ After (Procedural Macros Only)

**vodozemac.udl**: Remove the interface definition

**lib.rs**:
```rust
#[derive(uniffi::Object)]
pub struct Curve25519PublicKey(vodozemac::Curve25519PublicKey);

#[uniffi::export]
impl Curve25519PublicKey {
    pub fn as_bytes(&self) -> Vec<u8> { /* ... */ }
    pub fn to_base64(&self) -> String { /* ... */ }
}
```

**Result**: Perfect checksum match ✅

## Technical Details

### Why Procedural Macros Work

The `#[uniffi::export]` macro:
1. Automatically generates the correct FFI scaffolding
2. Ensures method signatures match exactly
3. Handles Arc wrapping automatically
4. Calculates checksums based on the actual implementation

### Checksum Calculation

UniFFI checksums are based on:
- Exact function signatures (including namespace prefixes)
- Parameter types and ordering
- Return types
- Error handling patterns

Even tiny differences (like `Vec<u8>` vs `::std::vec::Vec<u8>`) cause different checksums.

### When to Use Each Approach

| Use Case | Approach | Reason |
|----------|----------|---------|
| Simple functions | UDL namespace | No object state, straightforward |
| Enums | UDL enum | Simple value types |
| Error types | UDL [Error] | UniFFI error handling |
| Complex objects | Procedural macros | Avoids checksum mismatches |
| Methods on objects | Procedural macros | Precise signature matching |

## Implementation Patterns

### Object Definition

```rust
/// Document your wrapper
#[derive(uniffi::Object)]
pub struct YourType(vodozemac::YourType);
```

### Constructor Patterns

```rust
#[uniffi::export]
impl YourType {
    /// Default constructor
    #[uniffi::constructor]
    pub fn new() -> std::sync::Arc<Self> {
        std::sync::Arc::new(Self(vodozemac::YourType::new()))
    }

    /// Fallible constructor
    #[uniffi::constructor]
    pub fn from_data(data: Vec<u8>) -> Result<std::sync::Arc<Self>, VodozemacError> {
        let inner = vodozemac::YourType::from_data(&data)
            .map_err(|e| VodozemacError::Key(e.to_string()))?;
        Ok(std::sync::Arc::new(Self(inner)))
    }
}
```

### Method Patterns

```rust
#[uniffi::export]
impl YourType {
    /// Return primitives directly
    pub fn to_string(&self) -> String {
        self.0.to_string()
    }

    /// Return bytes as Vec<u8>
    pub fn to_bytes(&self) -> Vec<u8> {
        self.0.as_bytes().to_vec()
    }

    /// Return other objects wrapped in Arc
    pub fn get_key(&self) -> std::sync::Arc<PublicKey> {
        std::sync::Arc::new(PublicKey(self.0.public_key()))
    }

    /// Methods with error handling
    pub fn process(&self, data: Vec<u8>) -> Result<Vec<u8>, VodozemacError> {
        self.0.process(&data)
            .map(|r| r.to_vec())
            .map_err(|e| VodozemacError::Key(e.to_string()))
    }
}
```

## Migration Guide

### From UDL Interface to Procedural Macros

1. **Remove UDL definition**:
   ```diff
   - interface YourType {
   -     constructor();
   -     string method();
   - };
   ```

2. **Add derive macro**:
   ```diff
   + #[derive(uniffi::Object)]
     pub struct YourType(Inner);
   ```

3. **Add export macro**:
   ```diff
   + #[uniffi::export]
     impl YourType {
   ```

4. **Add constructor attributes**:
   ```diff
   + #[uniffi::constructor]
     pub fn new() -> std::sync::Arc<Self> {
   ```

5. **Update return types**:
   ```diff
   - pub fn new() -> Self {
   + pub fn new() -> std::sync::Arc<Self> {
   ```

6. **Rebuild and test**:
   ```bash
   ./generate_bindings.sh
   ./xcode-test/run_xcode_test.sh comprehensive
   ```

## Debugging Tips

### Check Generated Scaffolding

If you're getting checksum mismatches, examine the generated scaffolding:

```bash
find target -name "*.uniffi.rs" -exec cat {} \;
```

Look for the expected function signatures and compare with your implementation.

### Extract Actual Checksums

Use Python to extract the actual checksums from the compiled library:

```python
import ctypes
lib = ctypes.CDLL('./target/debug/libvodozemac_bindings.dylib')
func = getattr(lib, 'uniffi_vodozemac_bindings_checksum_method_yourtype_yourmethod')
func.restype = ctypes.c_uint16
print(f"Actual checksum: {func()}")
```

Compare with expected checksums in the generated Swift code.

### Common Checksum Mismatch Causes

1. **Struct name mismatch**: `YourType` vs `r#YourType`
2. **Return type mismatch**: `Self` vs `Arc<Self>` for constructors
3. **Parameter type mismatch**: `&str` vs `String`
4. **Missing error handling**: `Result<T, E>` vs `T`
5. **Arc wrapping**: Objects must return `Arc<OtherObject>`

## Success Criteria

Your implementation is correct when:
- ✅ `./generate_bindings.sh` completes without errors
- ✅ Swift bindings compile successfully
- ✅ `./xcode-test/run_xcode_test.sh comprehensive` passes
- ✅ No "checksum mismatch" errors at runtime

## Related Issues

- [UniFFI Issue #XXX](https://github.com/mozilla/uniffi-rs/issues): Checksum calculation details
- [UniFFI Proc Macro Guide](https://mozilla.github.io/uniffi-rs/proc_macro/index.html): Official documentation

This approach has been verified to work with:
- UniFFI 0.29.4
- Contract version 29
- Complex object hierarchies (KeyId, Curve25519PublicKey, Curve25519SecretKey)
- Error handling with custom error types
