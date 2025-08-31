#[cfg(test)]
mod test_bindings {
    use crate::{base64_decode, base64_encode, get_version};

    #[test]
    fn test_base64_encode() {
        let input = "Hello, World!".as_bytes().to_vec();
        let encoded = base64_encode(input);
        assert_eq!(encoded, "SGVsbG8sIFdvcmxkIQ");
    }

    #[test]
    fn test_base64_decode() {
        let input = "SGVsbG8sIFdvcmxkIQ".to_string();
        let decoded = base64_decode(input);
        let decoded_string = String::from_utf8(decoded).unwrap();
        assert_eq!(decoded_string, "Hello, World!");
    }

    #[test]
    fn test_base64_roundtrip() {
        let original = "Test data for round trip 🦀".as_bytes().to_vec();
        let encoded = base64_encode(original.clone());
        let decoded = base64_decode(encoded);
        assert_eq!(decoded, original);
    }

    #[test]
    fn test_get_version() {
        let version = get_version();
        assert_eq!(version, "0.9.0");
        assert!(!version.is_empty());
    }

    #[test]
    fn test_base64_decode_invalid() {
        let invalid_input = "invalid!@#$%".to_string();
        let decoded = base64_decode(invalid_input);
        assert!(decoded.is_empty());
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
        let decoded = base64_decode(empty_input);
        assert!(decoded.is_empty());
    }
}
