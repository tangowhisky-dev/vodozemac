use std::collections::HashMap;
use serde::{Deserialize, Serialize};
use vodozemac::{
    base64_encode,
};

#[derive(Serialize, Deserialize)]
struct TestVectors {
    account_tests: Vec<AccountTest>,
    session_tests: Vec<SessionTest>, 
    group_session_tests: Vec<GroupSessionTest>,
    sas_tests: Vec<SasTest>,
    ecies_tests: Vec<EciesTest>,
    utility_tests: UtilityTests,
}

#[derive(Serialize, Deserialize)]
struct AccountTest {
    name: String,
    identity_keys: IdentityKeysData,
    one_time_keys_count: u32,
    one_time_keys: HashMap<String, String>,
    fallback_key: HashMap<String, String>,
    signature_message: String,
    signature: String,
}

#[derive(Serialize, Deserialize)]
struct IdentityKeysData {
    curve25519: String,
    ed25519: String,
}

#[derive(Serialize, Deserialize)]
struct SessionTest {
    name: String,
    session_id: String,
    plaintext: String,
    encrypted_message: String,
    decrypted_message: String,
}

#[derive(Serialize, Deserialize)]
struct GroupSessionTest {
    name: String,
    session_id: String,
    session_key: String,
    message_index: u32,
    plaintext: String,
    encrypted_message: String,
    decrypted_message: String,
    decrypted_index: u32,
}

#[derive(Serialize, Deserialize)]
struct SasTest {
    name: String,
    alice_public_key: String,
    bob_public_key: String,
    shared_secret: String,
    info: String,
    sas_bytes: String,
    emoji_indices: Vec<u8>,
    decimals: [u16; 3],
    mac_info: String,
    mac_message: String,
    calculated_mac: String,
}

#[derive(Serialize, Deserialize)]
struct EciesTest {
    name: String,
    alice_public_key: String,
    bob_public_key: String,
    plaintext: String,
    encrypted_message: String,
    decrypted_message: String,
    check_code: u8,
}

#[derive(Serialize, Deserialize)]
struct UtilityTests {
    base64_encode_tests: Vec<Base64Test>,
    base64_decode_tests: Vec<Base64Test>,
    version: String,
}

#[derive(Serialize, Deserialize)]
struct Base64Test {
    input: String,
    output: String,
}

fn generate_utility_tests() -> UtilityTests {
    let encode_tests = vec![
        Base64Test {
            input: "Hello, World!".to_string(),
            output: base64_encode("Hello, World!".as_bytes()),
        },
        Base64Test {
            input: "The quick brown fox jumps over the lazy dog".to_string(),
            output: base64_encode("The quick brown fox jumps over the lazy dog".as_bytes()),
        },
        Base64Test {
            input: "".to_string(),
            output: base64_encode(&[]),
        },
    ];
    
    let decode_tests = vec![
        Base64Test {
            input: "SGVsbG8sIFdvcmxkIQ".to_string(),
            output: "Hello, World!".to_string(),
        },
        Base64Test {
            input: "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw".to_string(),
            output: "The quick brown fox jumps over the lazy dog".to_string(),
        },
        Base64Test {
            input: "".to_string(),
            output: "".to_string(),
        },
    ];
    
    UtilityTests {
        base64_encode_tests: encode_tests,
        base64_decode_tests: decode_tests,
        version: vodozemac::VERSION.to_string(),
    }
}

fn main() {
    println!("🔧 Generating simplified test vectors for Vodozemac...");
    
    // For now, let's create a simplified version focusing on utility tests
    // The complex API tests can be added later once we understand the current API better
    let test_vectors = TestVectors {
        account_tests: vec![],
        session_tests: vec![],
        group_session_tests: vec![],
        sas_tests: vec![],
        ecies_tests: vec![],
        utility_tests: generate_utility_tests(),
    };
    
    let json = serde_json::to_string_pretty(&test_vectors).unwrap();
    
    // Write to the tests directory
    let output_path = "../test_vectors.json";
    std::fs::write(output_path, json).unwrap();
    
    println!("✅ Simplified test vectors generated and saved to {}", output_path);
    println!("📊 Generated vectors include:");
    println!("   • {} base64 encode tests", test_vectors.utility_tests.base64_encode_tests.len());
    println!("   • {} base64 decode tests", test_vectors.utility_tests.base64_decode_tests.len());
    println!("   • Version: {}", test_vectors.utility_tests.version);
    println!("");
    println!("ℹ️  This is a simplified version focusing on utility functions.");
    println!("   The complex API tests will be implemented after API analysis.");
}
