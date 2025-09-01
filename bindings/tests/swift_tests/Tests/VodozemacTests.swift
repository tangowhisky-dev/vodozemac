import XCTest
import Foundation
@testable import Vodozemac

struct TestVectors: Codable {
    let accountTests: [AccountTest]
    let sessionTests: [SessionTest]
    let groupSessionTests: [GroupSessionTest]
    let sasTests: [SasTest]
    let eciesTests: [EciesTest]
    let utilityTests: UtilityTests
    
    enum CodingKeys: String, CodingKey {
        case accountTests = "account_tests"
        case sessionTests = "session_tests"
        case groupSessionTests = "group_session_tests"
        case sasTests = "sas_tests"
        case eciesTests = "ecies_tests"
        case utilityTests = "utility_tests"
    }
}

struct AccountTest: Codable {
    let name: String
    let picklePassphrase: String
    let pickledAccount: String
    let identityKeys: IdentityKeysData
    let oneTimeKeysCount: UInt32
    let oneTimeKeys: [String: String]
    let fallbackKey: [String: String]
    let signatureMessage: String
    let signature: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case picklePassphrase = "pickle_passphrase"
        case pickledAccount = "pickled_account"
        case identityKeys = "identity_keys"
        case oneTimeKeysCount = "one_time_keys_count"
        case oneTimeKeys = "one_time_keys"
        case fallbackKey = "fallback_key"
        case signatureMessage = "signature_message"
        case signature
    }
}

struct IdentityKeysData: Codable {
    let curve25519: String
    let ed25519: String
}

struct SessionTest: Codable {
    let name: String
    let aliceAccount: String
    let bobAccount: String
    let picklePassphrase: String
    let sessionId: String
    let pickledSession: String
    let plaintext: String
    let encryptedMessage: String
    let decryptedMessage: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case aliceAccount = "alice_account"
        case bobAccount = "bob_account"
        case picklePassphrase = "pickle_passphrase"
        case sessionId = "session_id"
        case pickledSession = "pickled_session"
        case plaintext
        case encryptedMessage = "encrypted_message"
        case decryptedMessage = "decrypted_message"
    }
}

struct GroupSessionTest: Codable {
    let name: String
    let picklePassphrase: String
    let pickledOutbound: String
    let pickledInbound: String
    let sessionId: String
    let sessionKey: String
    let messageIndex: UInt32
    let plaintext: String
    let encryptedMessage: String
    let decryptedMessage: String
    let decryptedIndex: UInt32
    
    enum CodingKeys: String, CodingKey {
        case name
        case picklePassphrase = "pickle_passphrase"
        case pickledOutbound = "pickled_outbound"
        case pickledInbound = "pickled_inbound"
        case sessionId = "session_id"
        case sessionKey = "session_key"
        case messageIndex = "message_index"
        case plaintext
        case encryptedMessage = "encrypted_message"
        case decryptedMessage = "decrypted_message"
        case decryptedIndex = "decrypted_index"
    }
}

struct SasTest: Codable {
    let name: String
    let alicePublicKey: String
    let bobPublicKey: String
    let sharedSecret: String
    let info: String
    let sasBytes: String
    let emojiIndices: [UInt32]
    let decimals: [UInt16]
    let macInfo: String
    let macMessage: String
    let calculatedMac: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case alicePublicKey = "alice_public_key"
        case bobPublicKey = "bob_public_key"
        case sharedSecret = "shared_secret"
        case info
        case sasBytes = "sas_bytes"
        case emojiIndices = "emoji_indices"
        case decimals
        case macInfo = "mac_info"
        case macMessage = "mac_message"
        case calculatedMac = "calculated_mac"
    }
}

struct EciesTest: Codable {
    let name: String
    let alicePublicKey: String
    let bobPublicKey: String
    let plaintext: String
    let encryptedMessage: String
    let decryptedMessage: String
    let checkCode: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case alicePublicKey = "alice_public_key"
        case bobPublicKey = "bob_public_key"
        case plaintext
        case encryptedMessage = "encrypted_message"
        case decryptedMessage = "decrypted_message"
        case checkCode = "check_code"
    }
}

struct UtilityTests: Codable {
    let base64EncodeTests: [Base64Test]
    let base64DecodeTests: [Base64Test]
    let version: String
    
    enum CodingKeys: String, CodingKey {
        case base64EncodeTests = "base64_encode_tests"
        case base64DecodeTests = "base64_decode_tests"
        case version
    }
}

struct Base64Test: Codable {
    let input: String
    let output: String
}

final class VodozemacTests: XCTestCase {
    
    var testVectors: TestVectors!
    
    override func setUpWithError() throws {
        guard let url = Bundle.module.url(forResource: "test_vectors", withExtension: "json") else {
            XCTFail("Could not find test_vectors.json")
            return
        }
        
        let data = try Data(contentsOf: url)
        testVectors = try JSONDecoder().decode(TestVectors.self, from: data)
    }
    
    func testAccountOperations() throws {
        for accountTest in testVectors.accountTests {
            // Test account unpickling
            let account = try AccountWrapper.fromPickle(
                pickle: accountTest.pickledAccount,
                passphrase: accountTest.picklePassphrase
            )
            
            // Test identity keys
            let identityKeys = account.identityKeys()
            XCTAssertEqual(
                Data(identityKeys.curve25519),
                Data(base64Decode(input: accountTest.identityKeys.curve25519))
            )
            XCTAssertEqual(
                Data(identityKeys.ed25519),
                Data(base64Decode(input: accountTest.identityKeys.ed25519))
            )
            
            // Test signing
            let signature = account.sign(message: accountTest.signatureMessage)
            XCTAssertEqual(
                Data(signature.signature),
                Data(base64Decode(input: accountTest.signature))
            )
            
            // Test pickling
            let repickled = account.pickle(passphrase: accountTest.picklePassphrase)
            XCTAssertEqual(repickled, accountTest.pickledAccount)
        }
    }
    
    func testSessionOperations() throws {
        for sessionTest in testVectors.sessionTests {
            // Test session unpickling
            let session = try SessionWrapper.fromPickle(
                pickle: sessionTest.pickledSession,
                passphrase: sessionTest.picklePassphrase
            )
            
            // Test session ID
            XCTAssertEqual(session.sessionId(), sessionTest.sessionId)
            
            // Test message matching
            let matches = try session.sessionMatches(message: sessionTest.encryptedMessage)
            XCTAssertTrue(matches)
            
            // Test decryption
            let decrypted = try session.decrypt(message: sessionTest.encryptedMessage)
            XCTAssertEqual(decrypted, sessionTest.decryptedMessage)
            
            // Test pickling
            let repickled = session.pickle(passphrase: sessionTest.picklePassphrase)
            XCTAssertEqual(repickled, sessionTest.pickledSession)
        }
    }
    
    func testGroupSessionOperations() throws {
        for groupTest in testVectors.groupSessionTests {
            // Test outbound session
            let outbound = try GroupSessionWrapper.fromPickle(
                pickle: groupTest.pickledOutbound,
                passphrase: groupTest.picklePassphrase
            )
            
            XCTAssertEqual(outbound.sessionId(), groupTest.sessionId)
            XCTAssertEqual(outbound.sessionKey().key, groupTest.sessionKey)
            
            // Test inbound session
            let inbound = try InboundGroupSessionWrapper.fromPickle(
                pickle: groupTest.pickledInbound,
                passphrase: groupTest.picklePassphrase
            )
            
            XCTAssertEqual(inbound.sessionId(), groupTest.sessionId)
            
            // Test decryption
            let result = try inbound.decrypt(message: groupTest.encryptedMessage)
            XCTAssertEqual(result.plaintext, groupTest.decryptedMessage)
            XCTAssertEqual(result.messageIndex, groupTest.decryptedIndex)
        }
    }
    
    func testSasOperations() throws {
        for sasTest in testVectors.sasTests {
            // Create SAS instances
            let sas = SasWrapper()
            
            // Test public key format
            let publicKey = sas.publicKey()
            XCTAssertEqual(publicKey.key.count, 32)
            
            // For reference test, we can't recreate the exact same SAS
            // but we can test the API works correctly
            let otherSas = SasWrapper()
            let established = try sas.diffieHellman(otherKey: otherSas.publicKey())
            
            // Test bytes generation
            let sasBytes = established.bytes(info: sasTest.info)
            XCTAssertEqual(sasBytes.bytes.count, 32)
            
            // Test emoji and decimal generation
            let emojiIndices = established.generateBytesEmoji(sasBytes: sasBytes)
            XCTAssertEqual(emojiIndices.count, 7)
            
            let decimals = established.generateBytesDecimal(sasBytes: sasBytes)
            XCTAssertEqual(decimals.count, 3)
            
            // Test MAC calculation
            let mac = established.calculateMac(message: sasTest.macMessage, info: sasTest.macInfo)
            XCTAssertFalse(mac.mac.isEmpty)
        }
    }
    
    func testEciesOperations() throws {
        for eciesTest in testVectors.eciesTests {
            // Create ECIES instances
            let alice = EciesWrapper()
            let bob = EciesWrapper()
            
            // Test public key format
            let alicePublicKey = alice.publicKey()
            let bobPublicKey = bob.publicKey()
            XCTAssertEqual(alicePublicKey.key.count, 32)
            XCTAssertEqual(bobPublicKey.key.count, 32)
            
            // Establish channels
            let aliceEstablished = try alice.diffieHellman(otherKey: bobPublicKey)
            let bobEstablished = try bob.diffieHellman(otherKey: alicePublicKey)
            
            // Test encryption/decryption
            let encrypted = aliceEstablished.encrypt(plaintext: eciesTest.plaintext)
            let decrypted = try bobEstablished.decrypt(message: encrypted)
            XCTAssertEqual(decrypted, eciesTest.plaintext)
            
            // Test check code
            let checkCode = aliceEstablished.checkCode()
            XCTAssertEqual(checkCode.checkCode.count, 32)
        }
    }
    
    func testUtilityFunctions() throws {
        let utilityTests = testVectors.utilityTests
        
        // Test version
        XCTAssertEqual(version(), utilityTests.version)
        
        // Test base64 encoding
        for test in utilityTests.base64EncodeTests {
            let encoded = base64Encode(input: Array(test.input.utf8))
            XCTAssertEqual(encoded, test.output)
        }
        
        // Test base64 decoding
        for test in utilityTests.base64DecodeTests {
            let decoded = try base64Decode(input: test.input)
            let decodedString = String(data: Data(decoded), encoding: .utf8)!
            XCTAssertEqual(decodedString, test.output)
        }
    }
    
    func testErrorHandling() throws {
        // Test invalid pickle
        XCTAssertThrowsError(
            try AccountWrapper.fromPickle(pickle: "invalid", passphrase: "test")
        )
        
        // Test invalid base64
        XCTAssertThrowsError(
            try base64Decode(input: "invalid base64!")
        )
        
        // Test invalid message decryption
        let account = AccountWrapper()
        let session = try account.createOutboundSession(
            identityKey: Curve25519PublicKeyWrapper(key: Array(repeating: 0, count: 32)),
            oneTimeKey: Curve25519PublicKeyWrapper(key: Array(repeating: 1, count: 32))
        )
        
        XCTAssertThrowsError(
            try session.decrypt(message: "invalid_message")
        )
    }
}
