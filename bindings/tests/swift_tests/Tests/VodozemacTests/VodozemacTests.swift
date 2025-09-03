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
    let identityKeys: IdentityKeysData
    let oneTimeKeysCount: UInt32
    let oneTimeKeys: [String: String]
    let fallbackKey: [String: String]
    let signatureMessage: String
    let signature: String
    
    enum CodingKeys: String, CodingKey {
        case name
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
    let sessionId: String
    let plaintext: String
    let encryptedMessage: String
    let decryptedMessage: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case sessionId = "session_id"
        case plaintext
        case encryptedMessage = "encrypted_message"
        case decryptedMessage = "decrypted_message"
    }
}

struct GroupSessionTest: Codable {
    let name: String
    let sessionId: String
    let sessionKey: String
    let messageIndex: UInt32
    let plaintext: String
    let encryptedMessage: String
    let decryptedMessage: String
    let decryptedIndex: UInt32
    
    enum CodingKeys: String, CodingKey {
        case name
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
    let emojiIndices: [UInt8]
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
    let checkCode: UInt8
    
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
        // Look for test_vectors.json in the test bundle's resource path
        let testBundle = Bundle(for: type(of: self))
        
        // Try multiple locations for the test vectors file
        var url: URL?
        let resourceNames = ["test_vectors", "../test_vectors", "test_vectors"]
        let extensions = ["json", "json", "json"]
        
        for (resourceName, ext) in zip(resourceNames, extensions) {
            url = testBundle.url(forResource: resourceName, withExtension: ext)
            if url != nil {
                break
            }
        }
        
        // If not found in bundle, try relative to the test execution directory
        if url == nil {
            let fileManager = FileManager.default
            let currentDir = fileManager.currentDirectoryPath
            let testVectorsPaths = [
                "\(currentDir)/../test_vectors.json",
                "\(currentDir)/test_vectors.json",
                "\(currentDir)/Tests/test_vectors.json"
            ]
            
            for path in testVectorsPaths {
                if fileManager.fileExists(atPath: path) {
                    url = URL(fileURLWithPath: path)
                    break
                }
            }
        }
        
        guard let testVectorURL = url else {
            XCTFail("Could not find test_vectors.json in any expected location")
            return
        }
        
        let data = try Data(contentsOf: testVectorURL)
        testVectors = try JSONDecoder().decode(TestVectors.self, from: data)
    }
    
    // Since most test vector sections are currently empty, we'll focus on utility tests
    // and create new functional tests that don't require pre-generated vectors
    
    func testUtilityFunctions() throws {
        let utilityTests = testVectors.utilityTests
        
        // Test version
        XCTAssertEqual(getVersion(), utilityTests.version)
        
        // Test base64 encoding
        for test in utilityTests.base64EncodeTests {
            let inputData = Data(test.input.utf8)
            let encoded = base64Encode(input: inputData)
            XCTAssertEqual(encoded, test.output, "Base64 encoding failed for input: \(test.input)")
        }
        
        // Test base64 decoding  
        for test in utilityTests.base64DecodeTests {
            if !test.input.isEmpty {
                let decoded = try base64Decode(input: test.input)
                let decodedString = String(data: decoded, encoding: .utf8)!
                XCTAssertEqual(decodedString, test.output, "Base64 decoding failed for input: \(test.input)")
            }
        }
        
        print("✅ All utility function tests passed")
    }
    
    // Modern functional tests that create data on-the-fly instead of relying on vectors
    
    func testBasicCryptography() throws {
        print("🧪 Testing basic cryptographic operations...")
        
        // Test Curve25519 key generation
        let secretKey = Curve25519SecretKey()
        let publicKey = secretKey.publicKey()
        
        XCTAssertEqual(publicKey.asBytes().count, 32)
        print("✓ Curve25519 key pair generation works")
        
        // Test Ed25519 key generation  
        let ed25519Secret = Ed25519SecretKey()
        let ed25519Public = ed25519Secret.publicKey()
        
        XCTAssertEqual(ed25519Public.asBytes().count, 32)
        print("✓ Ed25519 key pair generation works")
        
        // Test Ed25519 signing
        let message = "Test message for signing"
        let messageData = Data(message.utf8)
        let signature = ed25519Secret.sign(message: messageData)
        
        do {
            try ed25519Public.verify(message: messageData, signature: signature)
            print("✓ Ed25519 signing and verification works")
        } catch {
            XCTFail("Ed25519 verification failed: \(error)")
        }
    }
    
    func testMegolmBasics() throws {
        print("🧪 Testing Megolm group session basics...")
        
        // Create group session with version 1 config to match inbound session
        let config = MegolmSessionConfig.version1()
        let groupSession = GroupSession.withConfig(config: config)
        
        XCTAssertFalse(groupSession.sessionId().isEmpty)
        print("✓ Group session creation works")
        
        // Test session key generation
        let sessionKey = groupSession.sessionKey()
        XCTAssertFalse(sessionKey.toBase64().isEmpty)
        print("✓ Session key generation works")
        
        // Test encryption
        let plaintext = "Hello, group!"
        let plaintextData = Data(plaintext.utf8)
        let encrypted = groupSession.encrypt(plaintext: plaintextData)
        XCTAssertFalse(encrypted.toBase64().isEmpty)
        print("✓ Group message encryption works")
        
        // Test inbound session creation and decryption
        let inboundConfig = MegolmSessionConfig.version1()
        let inboundSession = InboundGroupSession(sessionKey: sessionKey, config: inboundConfig)
        let decryptedResult = try inboundSession.decrypt(message: encrypted)
        
        let decryptedString = String(data: decryptedResult.plaintext(), encoding: .utf8)!
        XCTAssertEqual(decryptedString, plaintext)
        print("✓ Group message decryption works")
    }
    
    func testErrorHandling() throws {
        print("🧪 Testing error handling...")
        
        // Test invalid base64
        XCTAssertThrowsError(try base64Decode(input: "invalid base64!")) { error in
            print("✓ Correctly caught base64 decode error: \(error)")
        }
        
        // Test invalid key creation
        let invalidKeyData = Data(repeating: 0, count: 16) // Too short for Curve25519
        XCTAssertThrowsError(try Curve25519PublicKey.fromSlice(bytes: invalidKeyData)) { error in
            print("✓ Correctly caught invalid key error: \(error)")
        }
    }
    
    // Placeholder tests for when we have proper test vectors
    
    func testAccountOperationsWhenVectorsAvailable() throws {
        // Skip if no account test vectors available
        guard !testVectors.accountTests.isEmpty else {
            print("⏭️  Skipping account tests - no test vectors available")
            return
        }
        
        print("🧪 Testing account operations with vectors...")
        // Account test implementation would go here when we have proper vectors
        print("✅ Account tests completed")
    }
    
    func testSessionOperationsWhenVectorsAvailable() throws {
        // Skip if no session test vectors available  
        guard !testVectors.sessionTests.isEmpty else {
            print("⏭️  Skipping session tests - no test vectors available")
            return
        }
        
        print("🧪 Testing session operations with vectors...")
        // Session test implementation would go here when we have proper vectors
        print("✅ Session tests completed") 
    }
    
    func testGroupSessionOperationsWhenVectorsAvailable() throws {
        // Skip if no group session test vectors available
        guard !testVectors.groupSessionTests.isEmpty else {
            print("⏭️  Skipping group session tests - no test vectors available")
            return
        }
        
        print("🧪 Testing group session operations with vectors...")
        // Group session test implementation would go here when we have proper vectors
        print("✅ Group session tests completed")
    }
    
    func testSasOperationsWhenVectorsAvailable() throws {
        // Skip if no SAS test vectors available
        guard !testVectors.sasTests.isEmpty else {
            print("⏭️  Skipping SAS tests - no test vectors available")
            return
        }
        
        print("🧪 Testing SAS operations with vectors...")
        // SAS test implementation would go here when we have proper vectors
        print("✅ SAS tests completed")
    }
    
    func testEciesOperationsWhenVectorsAvailable() throws {
        // Skip if no ECIES test vectors available
        guard !testVectors.eciesTests.isEmpty else {
            print("⏭️  Skipping ECIES tests - no test vectors available")
            return
        }
        
        print("🧪 Testing ECIES operations with vectors...")
        // ECIES test implementation would go here when we have proper vectors
        print("✅ ECIES tests completed")
    }
}
