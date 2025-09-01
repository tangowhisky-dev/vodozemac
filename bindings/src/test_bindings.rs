#[cfg(test)]
mod test_bindings {
    use crate::{base64_decode, base64_encode, get_version, Curve25519PublicKey, Curve25519SecretKey, KeyId};

    #[test]
    fn test_base64_encode() {
        let input = "Hello, World!".as_bytes().to_vec();
        let encoded = base64_encode(input);
        assert_eq!(encoded, "SGVsbG8sIFdvcmxkIQ");
    }

    #[test]
    fn test_base64_decode() {
        let input = "SGVsbG8sIFdvcmxkIQ".to_string();
        let decoded = base64_decode(input).unwrap();
        let decoded_string = String::from_utf8(decoded).unwrap();
        assert_eq!(decoded_string, "Hello, World!");
    }

    #[test]
    fn test_base64_roundtrip() {
        let original = "Test data for round trip 🦀".as_bytes().to_vec();
        let encoded = base64_encode(original.clone());
        let decoded = base64_decode(encoded).unwrap();
        assert_eq!(decoded, original);
    }

    #[test]
    fn test_get_version() {
        let version = get_version();
        assert!(!version.is_empty());
        // Version should be in semantic version format
        assert!(version.contains('.'));
    }

    #[test]
    fn test_base64_decode_invalid() {
        let invalid_input = "invalid!@#$%".to_string();
        let result = base64_decode(invalid_input);
        assert!(result.is_err());
    }

    #[test]
    fn test_base64_encode_empty() {
        let empty_input = Vec::new();
        let encoded = base64_encode(empty_input);
        assert_eq!(encoded, "");
    }

    #[test]
    fn test_base64_decode_empty() {
        let empty_input = "".to_string();
        let decoded = base64_decode(empty_input).unwrap();
        assert!(decoded.is_empty());
    }

    // Tests for KeyId
    #[test]
    fn test_key_id_from_u64() {
        let key_id = KeyId::from_u64(123);
        let encoded = key_id.to_base64();
        assert!(!encoded.is_empty());
        // Test with a known value - KeyId(123) should produce a consistent base64
        assert_eq!(encoded.len(), 11); // Base64 encoding of 8-byte u64 without padding
    }

    #[test]
    fn test_key_id_zero() {
        let key_id = KeyId::from_u64(0);
        let encoded = key_id.to_base64();
        // Base64 encoding of zero should be all 'A's with proper padding
        assert_eq!(encoded, "AAAAAAAAAAA");
    }

    // Tests for Curve25519SecretKey
    #[test]
    fn test_curve25519_secret_key_new() {
        let secret_key = Curve25519SecretKey::new();
        let bytes = secret_key.to_bytes();
        assert_eq!(bytes.len(), 32);
    }

    #[test]
    fn test_curve25519_secret_key_from_slice() {
        let bytes = vec![1u8; 32];
        let secret_key = Curve25519SecretKey::from_slice(bytes.clone());
        let recovered_bytes = secret_key.to_bytes();
        assert_eq!(recovered_bytes, bytes);
    }

    #[test]
    fn test_curve25519_secret_key_public_key() {
        let secret_key = Curve25519SecretKey::new();
        let public_key = secret_key.public_key();
        let public_bytes = public_key.to_bytes();
        assert_eq!(public_bytes.len(), 32);
    }

    #[test]
    #[should_panic(expected = "Curve25519SecretKey requires exactly 32 bytes")]
    fn test_curve25519_secret_key_from_slice_wrong_length() {
        let bytes = vec![1u8; 31]; // Wrong length
        Curve25519SecretKey::from_slice(bytes);
    }

    // Tests for Curve25519PublicKey
    #[test]
    fn test_curve25519_public_key_from_bytes() {
        let bytes = vec![1u8; 32];
        let public_key = Curve25519PublicKey::from_bytes(bytes.clone());
        let recovered_bytes = public_key.to_bytes();
        assert_eq!(recovered_bytes, bytes);
    }

    #[test]
    #[should_panic(expected = "Curve25519PublicKey requires exactly 32 bytes")]
    fn test_curve25519_public_key_from_bytes_wrong_length() {
        let bytes = vec![1u8; 31]; // Wrong length
        Curve25519PublicKey::from_bytes(bytes);
    }

    #[test]
    fn test_curve25519_public_key_from_slice() {
        let bytes = vec![2u8; 32];
        let public_key = Curve25519PublicKey::from_slice(bytes.clone()).unwrap();
        let recovered_bytes = public_key.to_bytes();
        assert_eq!(recovered_bytes, bytes);
    }

    #[test]
    fn test_curve25519_public_key_from_slice_wrong_length() {
        let bytes = vec![2u8; 31]; // Wrong length
        let result = Curve25519PublicKey::from_slice(bytes);
        assert!(result.is_err());
    }

    #[test]
    fn test_curve25519_public_key_to_vec() {
        let bytes = vec![3u8; 32];
        let public_key = Curve25519PublicKey::from_bytes(bytes.clone());
        let vec_bytes = public_key.to_vec();
        assert_eq!(vec_bytes, bytes);
    }

    #[test]
    fn test_curve25519_public_key_as_bytes() {
        let bytes = vec![4u8; 32];
        let public_key = Curve25519PublicKey::from_bytes(bytes.clone());
        let as_bytes = public_key.as_bytes();
        assert_eq!(as_bytes, bytes);
    }

    #[test]
    fn test_curve25519_public_key_base64_roundtrip() {
        let bytes = vec![5u8; 32];
        let public_key = Curve25519PublicKey::from_bytes(bytes);
        let base64_str = public_key.to_base64();
        assert!(!base64_str.is_empty());
        
        let recovered_key = Curve25519PublicKey::from_base64(base64_str).unwrap();
        let recovered_bytes = recovered_key.to_bytes();
        assert_eq!(recovered_bytes, vec![5u8; 32]);
    }

    #[test]
    fn test_curve25519_public_key_from_base64_invalid() {
        let invalid_base64 = "invalid_base64!@#".to_string();
        let result = Curve25519PublicKey::from_base64(invalid_base64);
        assert!(result.is_err());
    }

    // Integration test: secret key to public key consistency
    #[test]
    fn test_curve25519_key_pair_consistency() {
        let secret_key = Curve25519SecretKey::new();
        let public_key_from_secret = secret_key.public_key();
        
        let secret_bytes = secret_key.to_bytes();
        let recovered_secret = Curve25519SecretKey::from_slice(secret_bytes);
        let public_key_from_recovered = recovered_secret.public_key();
        
        assert_eq!(public_key_from_secret.to_bytes(), public_key_from_recovered.to_bytes());
    }
}
