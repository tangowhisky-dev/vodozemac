use std::collections::HashMap;
use serde::{Deserialize, Serialize};
use vodozemac::{
    ecies::{Ecies, EstablishedEcies},
    megolm::{GroupSession, InboundGroupSession, SessionOrdering},
    olm::{Account, OlmMessage, SessionConfig},
    sas::{EstablishedSas, Sas},
    types::{Curve25519PublicKey, Ed25519PublicKey},
    base64_encode, base64_decode,
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
    pickle_passphrase: String,
    pickled_account: String,
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
    alice_account: String,
    bob_account: String,
    pickle_passphrase: String,
    session_id: String,
    pickled_session: String,
    plaintext: String,
    encrypted_message: String,
    decrypted_message: String,
}

#[derive(Serialize, Deserialize)]
struct GroupSessionTest {
    name: String,
    pickle_passphrase: String,
    pickled_outbound: String,
    pickled_inbound: String,
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
    emoji_indices: Vec<u32>,
    decimals: Vec<u16>,
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
    check_code: String,
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

fn generate_account_tests() -> Vec<AccountTest> {
    let mut tests = Vec::new();
    
    // Test basic account creation and operations
    let mut account = Account::new();
    account.generate_one_time_keys(5);
    account.generate_fallback_key();
    
    let passphrase = "test_passphrase";
    let pickled = account.pickle(passphrase.as_bytes());
    let identity_keys = account.identity_keys();
    let one_time_keys = account.one_time_keys();
    let fallback_key = account.fallback_key();
    
    let signature_message = "Hello, world!";
    let signature = account.sign(signature_message);
    
    tests.push(AccountTest {
        name: "basic_account_operations".to_string(),
        pickle_passphrase: passphrase.to_string(),
        pickled_account: pickled,
        identity_keys: IdentityKeysData {
            curve25519: base64_encode(identity_keys.curve25519.to_bytes()),
            ed25519: base64_encode(identity_keys.ed25519.to_bytes()),
        },
        one_time_keys_count: one_time_keys.len() as u32,
        one_time_keys: one_time_keys
            .iter()
            .map(|(k, v)| (k.to_base64(), base64_encode(v.to_bytes())))
            .collect(),
        fallback_key: [(
            fallback_key.key_id().to_base64(),
            base64_encode(fallback_key.public_key().to_bytes())
        )].into_iter().collect(),
        signature_message: signature_message.to_string(),
        signature: base64_encode(signature.to_bytes()),
    });
    
    tests
}

fn generate_session_tests() -> Vec<SessionTest> {
    let mut tests = Vec::new();
    
    // Create Alice and Bob accounts
    let mut alice = Account::new();
    let mut bob = Account::new();
    bob.generate_one_time_keys(1);
    
    let passphrase = "session_test_passphrase";
    
    // Create outbound session from Alice to Bob
    let bob_identity = bob.identity_keys().curve25519;
    let bob_otk = *bob.one_time_keys().values().next().unwrap();
    let mut alice_session = alice.create_outbound_session(SessionConfig::version_1(), bob_identity, bob_otk);
    
    // Encrypt a message
    let plaintext = "Hello from Alice!";
    let encrypted = alice_session.encrypt(plaintext);
    
    // Create inbound session for Bob
    let result = bob.create_inbound_session(alice.identity_keys().curve25519, &encrypted).unwrap();
    let mut bob_session = result.session;
    let decrypted = result.plaintext;
    
    tests.push(SessionTest {
        name: "basic_session_flow".to_string(),
        alice_account: alice.pickle(passphrase.as_bytes()),
        bob_account: bob.pickle(passphrase.as_bytes()),
        pickle_passphrase: passphrase.to_string(),
        session_id: alice_session.session_id(),
        pickled_session: alice_session.pickle(passphrase.as_bytes()),
        plaintext: plaintext.to_string(),
        encrypted_message: encrypted.to_base64(),
        decrypted_message: decrypted,
    });
    
    tests
}

fn generate_group_session_tests() -> Vec<GroupSessionTest> {
    let mut tests = Vec::new();
    
    // Create outbound group session
    let mut outbound = GroupSession::new();
    let session_key = outbound.session_key();
    let session_id = outbound.session_id();
    
    // Create inbound group session
    let mut inbound = InboundGroupSession::new(&session_key, SessionOrdering::Stream);
    
    let passphrase = "group_test_passphrase";
    let plaintext = "Group message from Alice";
    let encrypted = outbound.encrypt(plaintext);
    
    // Decrypt the message
    let result = inbound.decrypt(&encrypted).unwrap();
    
    tests.push(GroupSessionTest {
        name: "basic_group_session".to_string(),
        pickle_passphrase: passphrase.to_string(),
        pickled_outbound: outbound.pickle(passphrase.as_bytes()),
        pickled_inbound: inbound.pickle(passphrase.as_bytes()),
        session_id,
        session_key: session_key.to_base64(),
        message_index: outbound.message_index() - 1,
        plaintext: plaintext.to_string(),
        encrypted_message: encrypted.to_base64(),
        decrypted_message: result.plaintext,
        decrypted_index: result.message_index,
    });
    
    tests
}

fn generate_sas_tests() -> Vec<SasTest> {
    let mut tests = Vec::new();
    
    // Create Alice and Bob SAS
    let alice = Sas::new();
    let bob = Sas::new();
    
    // Perform Diffie-Hellman
    let alice_established = alice.diffie_hellman(bob.public_key()).unwrap();
    let bob_established = bob.diffie_hellman(alice.public_key()).unwrap();
    
    let info = "MATRIX_KEY_VERIFICATION_SAS";
    let alice_bytes = alice_established.bytes(info);
    let bob_bytes = bob_established.bytes(info);
    
    // Ensure both sides generate the same bytes
    assert_eq!(alice_bytes.to_vec(), bob_bytes.to_vec());
    
    let emoji_indices = alice_bytes.emoji_indices();
    let decimals = alice_bytes.decimals();
    
    // MAC calculation
    let mac_info = "MATRIX_KEY_VERIFICATION_MAC";
    let mac_message = "test_mac_message";
    let calculated_mac = alice_established.calculate_mac(mac_message, mac_info);
    
    tests.push(SasTest {
        name: "basic_sas_flow".to_string(),
        alice_public_key: base64_encode(alice.public_key().to_bytes()),
        bob_public_key: base64_encode(bob.public_key().to_bytes()),
        shared_secret: base64_encode(alice_bytes.to_vec()),
        info: info.to_string(),
        sas_bytes: base64_encode(alice_bytes.to_vec()),
        emoji_indices: emoji_indices.to_vec(),
        decimals: decimals.to_vec(),
        mac_info: mac_info.to_string(),
        mac_message: mac_message.to_string(),
        calculated_mac: calculated_mac.to_base64(),
    });
    
    tests
}

fn generate_ecies_tests() -> Vec<EciesTest> {
    let mut tests = Vec::new();
    
    // Create Alice and Bob ECIES
    let alice = Ecies::new();
    let bob = Ecies::new();
    
    // Establish shared channels
    let alice_established = alice.diffie_hellman(bob.public_key());
    let bob_established = bob.diffie_hellman(alice.public_key());
    
    let plaintext = "ECIES encrypted message";
    let encrypted = alice_established.encrypt(plaintext);
    let decrypted = bob_established.decrypt(&encrypted).unwrap();
    
    assert_eq!(plaintext, decrypted);
    
    tests.push(EciesTest {
        name: "basic_ecies_flow".to_string(),
        alice_public_key: base64_encode(alice.public_key().to_bytes()),
        bob_public_key: base64_encode(bob.public_key().to_bytes()),
        plaintext: plaintext.to_string(),
        encrypted_message: encrypted.to_base64(),
        decrypted_message: decrypted,
        check_code: base64_encode(alice_established.check_code().to_bytes()),
    });
    
    tests
}

fn generate_utility_tests() -> UtilityTests {
    let encode_tests = vec![
        Base64Test {
            input: "hello world".to_string(),
            output: base64_encode(b"hello world"),
        },
        Base64Test {
            input: "".to_string(),
            output: base64_encode(b""),
        },
        Base64Test {
            input: "test123!@#".to_string(),
            output: base64_encode(b"test123!@#"),
        },
    ];
    
    let decode_tests = vec![
        Base64Test {
            input: base64_encode(b"hello world"),
            output: "hello world".to_string(),
        },
        Base64Test {
            input: base64_encode(b""),
            output: "".to_string(),
        },
        Base64Test {
            input: base64_encode(b"test123!@#"),
            output: "test123!@#".to_string(),
        },
    ];
    
    UtilityTests {
        base64_encode_tests: encode_tests,
        base64_decode_tests: decode_tests,
        version: env!("CARGO_PKG_VERSION").to_string(),
    }
}

fn main() {
    let test_vectors = TestVectors {
        account_tests: generate_account_tests(),
        session_tests: generate_session_tests(),
        group_session_tests: generate_group_session_tests(),
        sas_tests: generate_sas_tests(),
        ecies_tests: generate_ecies_tests(),
        utility_tests: generate_utility_tests(),
    };
    
    let json = serde_json::to_string_pretty(&test_vectors).unwrap();
    println!("{}", json);
    
    // Also save to file
    std::fs::write("../test_vectors.json", json).unwrap();
    println!("\nTest vectors saved to test_vectors.json");
}
