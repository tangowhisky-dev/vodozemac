# UniFFI Binding Expansion - Quick Reference

## 🚨 CRITICAL: Use Procedural Macros for Objects

When adding new API to vodozemac Swift bindings, **avoid UDL interfaces** for complex objects. They cause checksum mismatches.

## ✅ Correct Pattern

### 1. Rust Implementation (src/lib.rs)

```rust
#[derive(uniffi::Object)]
pub struct YourType(vodozemac::YourType);

#[uniffi::export]
impl YourType {
    #[uniffi::constructor]
    pub fn new() -> std::sync::Arc<Self> {
        std::sync::Arc::new(Self(vodozemac::YourType::new()))
    }

    #[uniffi::constructor]
    pub fn from_data(data: Vec<u8>) -> Result<std::sync::Arc<Self>, VodozemacError> {
        let inner = vodozemac::YourType::from_data(&data)
            .map_err(|e| VodozemacError::Key(e.to_string()))?;
        Ok(std::sync::Arc::new(Self(inner)))
    }

    pub fn to_bytes(&self) -> Vec<u8> {
        self.0.to_bytes().to_vec()
    }
}
```

### 2. DO NOT Add to UDL (src/vodozemac.udl)

❌ **Don't do this**:
```udl
interface YourType {  // This causes checksum mismatches!
    constructor();
    bytes to_bytes();
}
```

### 3. Build and Test

```bash
./generate_bindings.sh
./xcode-test/run_xcode_test.sh comprehensive
```

## 📚 Full Documentation

- `README.md` - Complete usage guide
- `UNIFFI_EXPANSION_GUIDE.md` - Technical deep-dive on the checksum solution  
- `IMPLEMENTATION_SUMMARY.md` - What was implemented and why

## 🎯 Working Examples

See `src/lib.rs` for working examples:
- `KeyId` - Simple object with constructor and method
- `Curve25519PublicKey` - Complex object with multiple constructors and error handling
- `Curve25519SecretKey` - Object that returns other objects

## 💡 Key Points

1. Use `#[derive(uniffi::Object)]` for structs
2. Use `#[uniffi::export]` for impl blocks  
3. Use `#[uniffi::constructor]` for constructors
4. Constructors return `std::sync::Arc<Self>`
5. Objects return `std::sync::Arc<OtherObject>`
6. Use `VodozemacError` for error handling
7. Test with `./xcode-test/run_xcode_test.sh comprehensive`

This approach eliminates UniFFI checksum mismatches completely! ✅
