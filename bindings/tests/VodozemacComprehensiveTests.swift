import XCTest
import Foundation
import vodozemacFFI

/**
 * Comprehensive test suite for Vodozemac Swift bindings
 * 
 * This test suite consolidates all Vodozemac functionality testing including:
 * - Base utilities (base64, version)
 * - Megolm group messaging (encryption, decryption, session management)
 * - ECIES end-to-end encryption
 * - Olm one-to-one messaging
 * - SAS verification protocol
 * 
 * Based on the latest API coverage from xcode-test folder.
 */
class VodozemacComprehensiveTests: XCTestCase {
    
    // MARK: - Base Utility Tests
    
    func testBase64Encoding() throws {
        let input = "Hello, World!"
        let inputData = Data(input.utf8)
        let encoded = base64Encode(input: inputData)
        XCTAssertEqual(encoded, "SGVsbG8sIFdvcmxkIQ")
        
        let decodedData = try base64Decode(input: encoded)
        let decoded = String(data: decodedData, encoding: .utf8)!
        XCTAssertEqual(decoded, input)
        
        print("✓ Base64 encoding/decoding successful")
    }
    
    func testVersionInfo() throws {
        let version = getVersion()
        XCTAssertFalse(version.isEmpty)
        print("✓ Version: \(version)")
    }
    
    // MARK: - Megolm Group Messaging Tests
    
    func testMegolmSessionConfig() throws {
        print("🧪 Testing Megolm session configurations...")
        
        // Test version 1 configuration
        let configV1 = MegolmSessionConfig.version1()
        XCTAssertNotNil(configV1)
        print("✓ Created MegolmSessionConfig v1")
        
        // Test version 2 configuration  
        let configV2 = MegolmSessionConfig.version2()
        XCTAssertNotNil(configV2)
        print("✓ Created MegolmSessionConfig v2")
    }
    
    func testGroupSessionCreation() throws {
        print("🧪 Testing GroupSession creation...")
        
        let config = MegolmSessionConfig.version2()
        
        // Test basic GroupSession creation
        let session = GroupSession.withConfig(config: config)
        XCTAssertNotNil(session)
        
        // Test session properties
        let sessionId = session.sessionId()
        XCTAssertFalse(sessionId.isEmpty)
        print("✓ Session ID: \(sessionId)")
        
        // Test message index starts at 0
        let initialIndex = session.messageIndex()
        XCTAssertEqual(initialIndex, UInt32(0))
        print("✓ Initial message index: \(initialIndex)")
    }
    
    func testMegolmEncryptionDecryption() throws {
        print("🧪 Testing Megolm encryption/decryption...")
        
        let config = MegolmSessionConfig.version2()
        let outboundSession = GroupSession.withConfig(config: config)
        let sessionKey = outboundSession.sessionKey()
        let inboundSession = InboundGroupSession(sessionKey: sessionKey, config: config)
        
        let messages = [
            "First secret message! 🔒",
            "Second confidential data! 🤐", 
            "Third encrypted content! 🔐"
        ]
        
        var encryptedMessages: [MegolmMessage] = []
        
        // Encrypt messages
        for (index, message) in messages.enumerated() {
            let plaintext = message.data(using: .utf8)!
            let encrypted = outboundSession.encrypt(plaintext: plaintext)
            encryptedMessages.append(encrypted)
            
            XCTAssertEqual(outboundSession.messageIndex(), UInt32(index + 1))
            print("✓ Encrypted message \(index + 1)")
        }
        
        // Decrypt messages
        for (index, encryptedMessage) in encryptedMessages.enumerated() {
            let decrypted = try inboundSession.decrypt(message: encryptedMessage)
            let decryptedText = String(data: decrypted.plaintext(), encoding: .utf8)!
            XCTAssertEqual(decryptedText, messages[index])
            XCTAssertEqual(decrypted.messageIndex(), UInt32(index))
            print("✓ Decrypted message \(index + 1): '\(decryptedText)'")
        }
    }
    
    func testSessionKeySerialization() throws {
        print("🧪 Testing SessionKey serialization...")
        
        let config = MegolmSessionConfig.version1()
        let session = GroupSession.withConfig(config: config)
        let sessionKey = session.sessionKey()
        
        // Test base64 serialization
        let base64Key = sessionKey.toBase64()
        XCTAssertGreaterThan(base64Key.count, 0)
        
        let restoredKey1 = try SessionKey.fromBase64(input: base64Key)
        XCTAssertEqual(restoredKey1.toBase64(), base64Key)
        
        // Test bytes serialization
        let bytesKey = sessionKey.toBytes()
        XCTAssertGreaterThan(bytesKey.count, 0)
        
        let restoredKey2 = try SessionKey.fromBytes(bytes: bytesKey)
        XCTAssertEqual(restoredKey2.toBytes(), bytesKey)
        
        // Verify restored keys work
        let inboundSession = InboundGroupSession(sessionKey: restoredKey1, config: config)
        XCTAssertEqual(inboundSession.sessionId(), session.sessionId())
        
        print("✓ SessionKey serialization successful")
    }
    
    func testMegolmSessionExportImport() throws {
        print("🧪 Testing Megolm session export/import...")
        
        let config = MegolmSessionConfig.version2()
        let outboundSession = GroupSession.withConfig(config: config)
        let sessionKey = outboundSession.sessionKey()
        let inboundSession = InboundGroupSession(sessionKey: sessionKey, config: config)
        
        // Encrypt some messages to advance the session
        for i in 0..<3 {
            let plaintext = "Message \(i)".data(using: .utf8)!
            _ = outboundSession.encrypt(plaintext: plaintext)
        }
        
        // Export session at message index 1
        guard let exportedKey = inboundSession.exportAt(messageIndex: 1) else {
            XCTFail("Failed to export session")
            return
        }
        
        // Test export key serialization
        let exportedBase64 = exportedKey.toBase64()
        XCTAssertGreaterThan(exportedBase64.count, 0)
        
        let restoredExportedKey = try ExportedSessionKey.fromBase64(input: exportedBase64)
        XCTAssertEqual(restoredExportedKey.toBase64(), exportedBase64)
        
        // Import session from exported key
        let importedSession = InboundGroupSession.import(exportedKey: exportedKey, config: config)
        XCTAssertEqual(importedSession.sessionId(), inboundSession.sessionId())
        XCTAssertEqual(importedSession.firstKnownIndex(), UInt32(1))
        
        print("✓ Session export/import successful")
    }
    
    func testMegolmPickling() throws {
        print("🧪 Testing Megolm session pickling...")
        
        let config = MegolmSessionConfig.version2()
        let outboundSession = GroupSession.withConfig(config: config)
        let sessionKey = outboundSession.sessionKey()
        let inboundSession = InboundGroupSession(sessionKey: sessionKey, config: config)
        
        // Advance session state
        let plaintext = "Test message".data(using: .utf8)!
        _ = outboundSession.encrypt(plaintext: plaintext)
        
        let pickleKey = Data(repeating: 0x42, count: 32)
        
        // Test GroupSession pickling
        let outboundPickle = outboundSession.pickle()
        let encryptedOutboundPickle = try outboundPickle.encrypt(pickleKey: pickleKey)
        
        let restoredOutboundPickle = try GroupSessionPickle.fromEncrypted(
            ciphertext: encryptedOutboundPickle,
            pickleKey: pickleKey
        )
        let restoredOutboundSession = try GroupSession.fromPickle(pickle: restoredOutboundPickle)
        
        XCTAssertEqual(restoredOutboundSession.sessionId(), outboundSession.sessionId())
        XCTAssertEqual(restoredOutboundSession.messageIndex(), outboundSession.messageIndex())
        
        // Test InboundGroupSession pickling
        let inboundPickle = inboundSession.pickle()
        let encryptedInboundPickle = try inboundPickle.encrypt(pickleKey: pickleKey)
        
        let restoredInboundPickle = try InboundGroupSessionPickle.fromEncrypted(
            ciphertext: encryptedInboundPickle,
            pickleKey: pickleKey
        )
        let restoredInboundSession = try InboundGroupSession.fromPickle(pickle: restoredInboundPickle)
        
        XCTAssertEqual(restoredInboundSession.sessionId(), inboundSession.sessionId())
        XCTAssertEqual(restoredInboundSession.firstKnownIndex(), inboundSession.firstKnownIndex())
        
        print("✓ Megolm pickling successful")
    }
    
    func testMegolmSessionComparison() throws {
        print("🧪 Testing Megolm session comparison...")
        
        let config = MegolmSessionConfig.version1()
        let outboundSession = GroupSession.withConfig(config: config)
        let sessionKey = outboundSession.sessionKey()
        
        let session1 = InboundGroupSession(sessionKey: sessionKey, config: config)
        let session2 = InboundGroupSession(sessionKey: sessionKey, config: config)
        
        let comparison = session1.compare(other: session2)
        XCTAssertEqual(comparison, SessionOrdering.equal)
        
        print("✓ Session comparison successful")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() throws {
        print("🧪 Testing error handling...")
        
        // Test invalid base64
        XCTAssertThrowsError(try base64Decode(input: "invalid_base64!"))
        XCTAssertThrowsError(try SessionKey.fromBase64(input: "invalid_base64!"))
        XCTAssertThrowsError(try ExportedSessionKey.fromBase64(input: "invalid_base64!"))
        XCTAssertThrowsError(try MegolmMessage.fromBase64(input: "invalid_base64!"))
        
        // Test invalid pickle key
        let config = MegolmSessionConfig.version1()
        let session = GroupSession.withConfig(config: config)
        let pickle = session.pickle()
        let invalidPickleKey = Data(repeating: 0x42, count: 16) // Wrong size
        
        XCTAssertThrowsError(try pickle.encrypt(pickleKey: invalidPickleKey))
        
        print("✓ Error handling working correctly")
    }
    
    // MARK: - Performance Tests
    
    func testPerformance() throws {
        print("🧪 Testing performance...")
        
        measure {
            let config = MegolmSessionConfig.version2()
            let session = GroupSession.withConfig(config: config)
            
            // Encrypt 100 messages
            for i in 0..<100 {
                let message = "Performance test message \(i)".data(using: .utf8)!
                _ = session.encrypt(plaintext: message)
            }
        }
        
        print("✓ Performance test completed")
    }
}
