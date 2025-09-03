use std::collections::HashMap;
use serde::{Deserialize, Serialize};
use vodozemac::{
    base64_encode,
    olm::{Account, SessionConfig as OlmSessionConfig},
    megolm::{GroupSession, InboundGroupSession, SessionConfig},
    sas::{Sas},
    ecies::Ecies,
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
        Base64Test {
            input: "Test with special chars: !@#$%^&*()".to_string(),
            output: base64_encode("Test with special chars: !@#$%^&*()".as_bytes()),
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
        Base64Test {
            input: "VGVzdCB3aXRoIHNwZWNpYWwgY2hhcnM6ICFAIyQlXiYqKCk".to_string(),
            output: "Test with special chars: !@#$%^&*()".to_string(),
        },
    ];
    
    UtilityTests {
        base64_encode_tests: encode_tests,
        base64_decode_tests: decode_tests,
        version: vodozemac::VERSION.to_string(),
    }
}

fn generate_account_tests() -> Vec<AccountTest> {
    println!("🔑 Generating Account test vectors...");
    let mut tests = Vec::new();
    
    // Test 1: Basic account creation and key extraction
    let mut account = Account::new();
    let identity_keys = account.identity_keys();
    let curve25519_key = &identity_keys.curve25519;
    let ed25519_key = &identity_keys.ed25519;
    
    // Generate some one-time keys
    account.generate_one_time_keys(5);
    let one_time_keys = account.one_time_keys();
    
    // Generate fallback key
    account.generate_fallback_key();
    let fallback_key = account.fallback_key();
    
    // Test signature
    let message = "Test message for signing";
    let signature = account.sign(message);
    
    tests.push(AccountTest {
        name: "Basic Account Operations".to_string(),
        identity_keys: IdentityKeysData {
            curve25519: curve25519_key.to_base64(),
            ed25519: ed25519_key.to_base64(),
        },
        one_time_keys_count: one_time_keys.len() as u32,
        one_time_keys: one_time_keys.iter()
            .map(|(id, key)| (format!("{:?}", id), key.to_base64()))
            .collect(),
        fallback_key: fallback_key.iter()
            .map(|(id, key)| (format!("{:?}", id), key.to_base64()))
            .collect(),
        signature_message: message.to_string(),
        signature: signature.to_base64(),
    });
    
    tests
}

fn generate_session_tests() -> Vec<SessionTest> {
    println!("📡 Generating Session test vectors...");
    let mut tests = Vec::new();
    
    // Create Alice and Bob accounts
    let alice_account = Account::new();
    let mut bob_account = Account::new();
    
    // Bob generates a one-time key
    bob_account.generate_one_time_keys(1);
    let bob_one_time_keys = bob_account.one_time_keys();
    let (_key_id, bob_one_time_key) = bob_one_time_keys.iter().next().unwrap();
    bob_account.mark_keys_as_published();
    
    // Alice creates an outbound session to Bob
    let session_config = OlmSessionConfig::version_1();
    let mut alice_session = alice_account.create_outbound_session(
        session_config,
        bob_account.identity_keys().curve25519,
        *bob_one_time_key
    );
    
    // Alice encrypts a message (this creates a pre-key message for first message)
    let plaintext = "Hello from Alice to Bob!";
    let encrypted = alice_session.encrypt(plaintext);
    
    // Extract the pre-key message for Bob to establish the session
    let pre_key_message = match &encrypted {
        vodozemac::olm::OlmMessage::PreKey(pre_key) => pre_key,
        _ => panic!("Expected pre-key message for first message"),
    };
    
    // Bob creates an inbound session using the pre-key message
    let bob_inbound_result = bob_account.create_inbound_session(
        alice_account.identity_keys().curve25519,
        pre_key_message
    ).expect("Failed to create inbound session");
    
    // The inbound session creation already decrypts the message!
    let decrypted_text = String::from_utf8(bob_inbound_result.plaintext).expect("Invalid UTF-8");
    
    tests.push(SessionTest {
        name: "Basic Olm Session Test".to_string(),
        session_id: alice_session.session_id(),
        plaintext: plaintext.to_string(),
        encrypted_message: match &encrypted {
            vodozemac::olm::OlmMessage::PreKey(msg) => msg.to_base64(),
            vodozemac::olm::OlmMessage::Normal(msg) => msg.to_base64(),
        },
        decrypted_message: decrypted_text,
    });
    
    tests
}

fn generate_group_session_tests() -> Vec<GroupSessionTest> {
    println!("👥 Generating Group Session test vectors...");
    let mut tests = Vec::new();
    
    // Test with Megolm v1 (truncated MAC)
    let config = SessionConfig::version_1();
    let mut group_session = GroupSession::new(config);
    let session_key = group_session.session_key();
    let session_id = group_session.session_id();
    
    // Encrypt a message
    let plaintext = "Hello, group! This is a Megolm message.";
    let message_index = group_session.message_index();
    let encrypted = group_session.encrypt(plaintext.as_bytes());
    
    // Create inbound session and decrypt
    let mut inbound_session = InboundGroupSession::new(&session_key, config);
    let decrypted = inbound_session.decrypt(&encrypted).expect("Failed to decrypt");
    let decrypted_text = String::from_utf8(decrypted.plaintext.to_vec()).expect("Invalid UTF-8");
    
    tests.push(GroupSessionTest {
        name: "Megolm v1 Group Session Test".to_string(),
        session_id: session_id,
        session_key: session_key.to_base64(),
        message_index: message_index,
        plaintext: plaintext.to_string(),
        encrypted_message: encrypted.to_base64(),
        decrypted_message: decrypted_text,
        decrypted_index: decrypted.message_index,
    });
    
    // Test with Megolm v2 (full MAC)
    let config_v2 = SessionConfig::version_2();
    let mut group_session_v2 = GroupSession::new(config_v2);
    let session_key_v2 = group_session_v2.session_key();
    let session_id_v2 = group_session_v2.session_id();
    
    let plaintext_v2 = "Hello, group! This is a Megolm v2 message.";
    let message_index_v2 = group_session_v2.message_index();
    let encrypted_v2 = group_session_v2.encrypt(plaintext_v2.as_bytes());
    
    let mut inbound_session_v2 = InboundGroupSession::new(&session_key_v2, config_v2);
    let decrypted_v2 = inbound_session_v2.decrypt(&encrypted_v2).expect("Failed to decrypt v2");
    let decrypted_text_v2 = String::from_utf8(decrypted_v2.plaintext.to_vec()).expect("Invalid UTF-8");
    
    tests.push(GroupSessionTest {
        name: "Megolm v2 Group Session Test".to_string(),
        session_id: session_id_v2,
        session_key: session_key_v2.to_base64(),
        message_index: message_index_v2,
        plaintext: plaintext_v2.to_string(),
        encrypted_message: encrypted_v2.to_base64(),
        decrypted_message: decrypted_text_v2,
        decrypted_index: decrypted_v2.message_index,
    });
    
    tests
}

fn generate_sas_tests() -> Vec<SasTest> {
    println!("🔐 Generating SAS test vectors...");
    let mut tests = Vec::new();
    
    // Create Alice and Bob SAS instances
    let alice_sas = Sas::new();
    let bob_sas = Sas::new();
    
    // Exchange public keys
    let alice_public = alice_sas.public_key();
    let bob_public = bob_sas.public_key();
    
    // Establish shared secrets
    let alice_established = alice_sas.diffie_hellman(bob_public).expect("Alice DH failed");
    let bob_established = bob_sas.diffie_hellman(alice_public).expect("Bob DH failed");
    
    // Generate SAS bytes and verification codes
    let info = "Test SAS Info";
    let alice_sas_bytes = alice_established.bytes(info);
    let bob_sas_bytes = bob_established.bytes(info);
    
    // They should be identical
    assert_eq!(alice_sas_bytes.as_bytes(), bob_sas_bytes.as_bytes());
    
    let emoji_indices = alice_sas_bytes.emoji_indices();
    let decimals = alice_sas_bytes.decimals();
    
    // Generate MAC
    let mac_info = "Test MAC Info";
    let mac_message = "Message to authenticate";
    let alice_mac = alice_established.calculate_mac(mac_message, mac_info);
    
    tests.push(SasTest {
        name: "Basic SAS Test".to_string(),
        alice_public_key: alice_public.to_base64(),
        bob_public_key: bob_public.to_base64(),
        shared_secret: base64_encode(alice_sas_bytes.as_bytes()),
        info: info.to_string(),
        sas_bytes: base64_encode(alice_sas_bytes.as_bytes()),
        emoji_indices: emoji_indices.to_vec(),
        decimals: [decimals.0, decimals.1, decimals.2],
        mac_info: mac_info.to_string(),
        mac_message: mac_message.to_string(),
        calculated_mac: alice_mac.to_base64(),
    });
    
    tests
}

fn generate_ecies_tests() -> Vec<EciesTest> {
    println!("🔒 Generating ECIES test vectors...");
    let mut tests = Vec::new();
    
    // Alice creates an ECIES channel to Bob
    let alice_ecies = Ecies::new();
    let bob_ecies = Ecies::new();
    
    // Get public keys
    let alice_public_key = alice_ecies.public_key();
    let bob_public_key = bob_ecies.public_key();
    
    // Alice establishes an outbound channel to Bob
    let plaintext = "This is a test message for ECIES encryption";
    let alice_result = alice_ecies.establish_outbound_channel(
        bob_public_key, 
        plaintext.as_bytes()
    ).expect("Failed to establish outbound channel");
    
    // Bob receives Alice's initial message and establishes inbound channel
    let bob_result = bob_ecies.establish_inbound_channel(
        &alice_result.message
    ).expect("Failed to establish inbound channel");
    
    // Bob's message should match the original plaintext
    let decrypted_text = String::from_utf8(bob_result.message.clone()).expect("Invalid UTF-8");
    
    // Get check codes for verification
    let alice_check_code = alice_result.ecies.check_code();
    let bob_check_code = bob_result.ecies.check_code();
    
    // They should match
    assert_eq!(alice_check_code.as_bytes(), bob_check_code.as_bytes());
    
    tests.push(EciesTest {
        name: "Basic ECIES Test".to_string(),
        alice_public_key: alice_public_key.to_base64(),
        bob_public_key: bob_public_key.to_base64(),
        plaintext: plaintext.to_string(),
        encrypted_message: alice_result.message.encode(),
        decrypted_message: decrypted_text,
        check_code: alice_check_code.as_bytes()[0], // Use first byte as sample
    });
    
    tests
}

fn main() {
    println!("🔧 Comprehensive Test Vector Generation for Vodozemac v{}", vodozemac::VERSION);
    println!("====================================================================");
    
    let test_vectors = TestVectors {
        account_tests: generate_account_tests(),
        session_tests: generate_session_tests(),
        group_session_tests: generate_group_session_tests(),
        sas_tests: generate_sas_tests(),
        ecies_tests: generate_ecies_tests(),
        utility_tests: generate_utility_tests(),
    };
    
    let json = serde_json::to_string_pretty(&test_vectors).unwrap();
    
    // Write to the tests directory
    let output_path = "../test_vectors.json";
    std::fs::write(output_path, json).unwrap();
    
    println!("");
    println!("✅ Comprehensive test vectors generated and saved to {}", output_path);
    println!("📊 Generated test vectors include:");
    println!("   • {} Account tests (key generation, signing)", test_vectors.account_tests.len());
    println!("   • {} Session tests (Olm encryption/decryption)", test_vectors.session_tests.len());
    println!("   • {} Group Session tests (Megolm v1 & v2)", test_vectors.group_session_tests.len());
    println!("   • {} SAS tests (key verification)", test_vectors.sas_tests.len());
    println!("   • {} ECIES tests (elliptic curve encryption)", test_vectors.ecies_tests.len());
    println!("   • {} base64 encode tests", test_vectors.utility_tests.base64_encode_tests.len());
    println!("   • {} base64 decode tests", test_vectors.utility_tests.base64_decode_tests.len());
    println!("   • Version: {}", test_vectors.utility_tests.version);
    println!("");
    println!("🎯 These test vectors can be used for:");
    println!("   • Cross-platform binding validation");
    println!("   • Regression testing");
    println!("   • API compatibility verification");
    println!("   • Reference implementation validation");
}
