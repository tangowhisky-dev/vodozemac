import XCTest
@testable import vodozemac

/**
 * Test suite for Megolm module bindings.
 * 
 * This test suite verifies that all 9 megolm structs are working correctly:
 * 1. MegolmSessionConfig - Configuration for sessions
 * 2. DecryptedMessage - Result of decryption
 * 3. ExportedSessionKey - Session key for sharing
 * 4. GroupSession - Outbound group session
 * 5. GroupSessionPickle - Serialized group session
 * 6. InboundGroupSession - Inbound group session
 * 7. InboundGroupSessionPickle - Serialized inbound group session
 * 8. MegolmMessage - Encrypted message
 * 9. SessionKey - Signed session key
 */
class MegolmBindingsTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /**
     * Test MegolmSessionConfig creation and usage
     */
    func testMegolmSessionConfig() throws {
        // Test Version 1 config
        let config1 = MegolmSessionConfig.version1()
        XCTAssertNotNil(config1)
        
        // Test Version 2 config
        let config2 = MegolmSessionConfig.version2()
        XCTAssertNotNil(config2)
    }
    
    /**
     * Test GroupSession creation and basic operations
     */
    func testGroupSession() throws {
        // Test default constructor
        let session1 = GroupSession.new()
        XCTAssertNotNil(session1)
        
        // Test with custom config
        let config = MegolmSessionConfig.version1()
        let session2 = GroupSession.withConfig(config: config)
        XCTAssertNotNil(session2)
        
        // Test message index
        let initialIndex = session1.messageIndex()
        XCTAssertEqual(initialIndex, 0)
        
        // Test session ID
        let sessionId = session1.sessionId()
        XCTAssertGreaterThan(sessionId.count, 0)
        
        // Test session key generation
        let sessionKey = session1.sessionKey()
        XCTAssertNotNil(sessionKey)
    }
    
    /**
     * Test message encryption and decryption flow
     */
    func testEncryptionDecryption() throws {
        // Create outbound session
        let config = MegolmSessionConfig.version2()
        let outboundSession = GroupSession.withConfig(config: config)
        
        // Get session key for sharing
        let sessionKey = outboundSession.sessionKey()
        
        // Create inbound session
        let inboundSession = InboundGroupSession(sessionKey: sessionKey, config: config)
        
        // Test encryption
        let plaintext = "Hello, Megolm World! 🌍".data(using: .utf8)!
        let encryptedMessage = outboundSession.encrypt(plaintext: plaintext)
        XCTAssertNotNil(encryptedMessage)
        
        // Test message properties
        XCTAssertEqual(encryptedMessage.messageIndex(), 0)
        XCTAssertGreaterThan(encryptedMessage.ciphertext().count, 0)
        
        // Test decryption
        let decryptedMessage = try inboundSession.decrypt(message: encryptedMessage)
        XCTAssertNotNil(decryptedMessage)
        XCTAssertEqual(decryptedMessage.plaintext(), plaintext)
        XCTAssertEqual(decryptedMessage.messageIndex(), 0)
        
        // Test session IDs match
        XCTAssertEqual(outboundSession.sessionId(), inboundSession.sessionId())
    }
    
    /**
     * Test multiple message encryption/decryption
     */
    func testMultipleMessages() throws {
        let config = MegolmSessionConfig.version2()
        let outboundSession = GroupSession.withConfig(config: config)
        let sessionKey = outboundSession.sessionKey()
        let inboundSession = InboundGroupSession(sessionKey: sessionKey, config: config)
        
        // Encrypt multiple messages
        let messages = ["First message", "Second message", "Third message"]
        var encryptedMessages: [MegolmMessage] = []
        
        for (index, messageText) in messages.enumerated() {
            let plaintext = messageText.data(using: .utf8)!
            let encrypted = outboundSession.encrypt(plaintext: plaintext)
            XCTAssertEqual(encrypted.messageIndex(), UInt32(index))
            encryptedMessages.append(encrypted)
        }
        
        // Decrypt messages (can be out of order)
        for (index, encryptedMessage) in encryptedMessages.enumerated() {
            let decrypted = try inboundSession.decrypt(message: encryptedMessage)
            let originalText = messages[index]
            let originalData = originalText.data(using: .utf8)!
            XCTAssertEqual(decrypted.plaintext(), originalData)
            XCTAssertEqual(decrypted.messageIndex(), UInt32(index))
        }
    }
    
    /**
     * Test ExportedSessionKey functionality
     */
    func testExportedSessionKey() throws {
        let config = MegolmSessionConfig.version1()
        let outboundSession = GroupSession.withConfig(config: config)
        let sessionKey = outboundSession.sessionKey()
        let inboundSession = InboundGroupSession(sessionKey: sessionKey, config: config)
        
        // Test export at specific index
        let exportedKey = inboundSession.exportAt(messageIndex: 0)
        XCTAssertNotNil(exportedKey)
        
        // Test exported key serialization
        let base64Key = exportedKey!.toBase64()
        XCTAssertGreaterThan(base64Key.count, 0)
        
        let bytesKey = exportedKey!.toBytes()
        XCTAssertGreaterThan(bytesKey.count, 0)
        
        // Test creating ExportedSessionKey from base64
        let restoredKey1 = try ExportedSessionKey.fromBase64(input: base64Key)
        XCTAssertEqual(restoredKey1.toBase64(), base64Key)
        
        // Test creating ExportedSessionKey from bytes
        let restoredKey2 = try ExportedSessionKey.fromBytes(bytes: bytesKey)
        XCTAssertEqual(restoredKey2.toBytes(), bytesKey)
        
        // Test importing with exported key
        let importedSession = InboundGroupSession.import(exportedKey: exportedKey!, config: config)
        XCTAssertNotNil(importedSession)
        XCTAssertEqual(importedSession.sessionId(), inboundSession.sessionId())
    }
    
    /**
     * Test MegolmMessage serialization
     */
    func testMegolmMessageSerialization() throws {
        let config = MegolmSessionConfig.version2()
        let session = GroupSession.withConfig(config: config)
        let plaintext = "Test message for serialization".data(using: .utf8)!
        
        // Create encrypted message
        let message = session.encrypt(plaintext: plaintext)
        
        // Test base64 serialization
        let base64String = message.toBase64()
        XCTAssertGreaterThan(base64String.count, 0)
        
        let restoredMessage1 = try MegolmMessage.fromBase64(input: base64String)
        XCTAssertEqual(restoredMessage1.messageIndex(), message.messageIndex())
        XCTAssertEqual(restoredMessage1.toBase64(), base64String)
        
        // Test bytes serialization
        let bytes = message.toBytes()
        XCTAssertGreaterThan(bytes.count, 0)
        
        let restoredMessage2 = try MegolmMessage.fromBytes(bytes: bytes)
        XCTAssertEqual(restoredMessage2.messageIndex(), message.messageIndex())
        XCTAssertEqual(restoredMessage2.toBytes(), bytes)
    }
    
    /**
     * Test SessionKey functionality
     */
    func testSessionKey() throws {
        let config = MegolmSessionConfig.version2()
        let session = GroupSession.withConfig(config: config)
        
        // Get session key
        let sessionKey = session.sessionKey()
        
        // Test serialization
        let base64Key = sessionKey.toBase64()
        XCTAssertGreaterThan(base64Key.count, 0)
        
        let bytesKey = sessionKey.toBytes()
        XCTAssertGreaterThan(bytesKey.count, 0)
        
        // Test restoration from base64
        let restoredKey1 = try SessionKey.fromBase64(input: base64Key)
        XCTAssertEqual(restoredKey1.toBase64(), base64Key)
        
        // Test restoration from bytes
        let restoredKey2 = try SessionKey.fromBytes(bytes: bytesKey)
        XCTAssertEqual(restoredKey2.toBytes(), bytesKey)
        
        // Test creating inbound session with restored key
        let inboundSession = InboundGroupSession(sessionKey: restoredKey1, config: config)
        XCTAssertEqual(inboundSession.sessionId(), session.sessionId())
    }
    
    /**
     * Test GroupSession pickling
     */
    func testGroupSessionPickling() throws {
        let config = MegolmSessionConfig.version1()
        let originalSession = GroupSession.withConfig(config: config)
        
        // Encrypt a message to advance the session
        let plaintext = "Test message".data(using: .utf8)!
        _ = originalSession.encrypt(plaintext: plaintext)
        let messageIndex = originalSession.messageIndex()
        
        // Create pickle
        let pickle = originalSession.pickle()
        XCTAssertNotNil(pickle)
        
        // Test pickle encryption
        let pickleKey = Data(repeating: 0x42, count: 32)
        let encryptedPickle = try pickle.encrypt(pickle_key: pickleKey)
        XCTAssertGreaterThan(encryptedPickle.count, 0)
        
        // Test pickle decryption and restoration
        let restoredPickle = try GroupSessionPickle.fromEncrypted(ciphertext: encryptedPickle, pickleKey: pickleKey)
        let restoredSession = try GroupSession.fromPickle(pickle: restoredPickle)
        
        XCTAssertEqual(restoredSession.messageIndex(), messageIndex)
        XCTAssertEqual(restoredSession.sessionId(), originalSession.sessionId())
    }
    
    /**
     * Test InboundGroupSession pickling
     */
    func testInboundGroupSessionPickling() throws {
        let config = MegolmSessionConfig.version2()
        let outboundSession = GroupSession.withConfig(config: config)
        let sessionKey = outboundSession.sessionKey()
        let originalInboundSession = InboundGroupSession(sessionKey: sessionKey, config: config)
        
        // Get initial properties
        let sessionId = originalInboundSession.sessionId()
        let firstKnownIndex = originalInboundSession.firstKnownIndex()
        
        // Create pickle
        let pickle = originalInboundSession.pickle()
        XCTAssertNotNil(pickle)
        
        // Test pickle encryption
        let pickleKey = Data(repeating: 0x33, count: 32)
        let encryptedPickle = try pickle.encrypt(pickle_key: pickleKey)
        XCTAssertGreaterThan(encryptedPickle.count, 0)
        
        // Test pickle decryption and restoration
        let restoredPickle = try InboundGroupSessionPickle.fromEncrypted(ciphertext: encryptedPickle, pickleKey: pickleKey)
        let restoredSession = try InboundGroupSession.fromPickle(pickle: restoredPickle)
        
        XCTAssertEqual(restoredSession.sessionId(), sessionId)
        XCTAssertEqual(restoredSession.firstKnownIndex(), firstKnownIndex)
    }
    
    /**
     * Test session comparison
     */
    func testSessionComparison() throws {
        let config = MegolmSessionConfig.version2()
        let outboundSession = GroupSession.withConfig(config: config)
        let sessionKey = outboundSession.sessionKey()
        
        // Create two identical inbound sessions
        let session1 = InboundGroupSession(sessionKey: sessionKey, config: config)
        let session2 = InboundGroupSession(sessionKey: sessionKey, config: config)
        
        // They should be equal
        let comparison = session1.compare(other: session2)
        XCTAssertEqual(comparison, SessionOrdering.equal)
    }
    
    /**
     * Test error handling
     */
    func testErrorHandling() throws {
        // Test invalid base64 for ExportedSessionKey
        XCTAssertThrowsError(try ExportedSessionKey.fromBase64(input: "invalid_base64!")) { error in
            XCTAssertTrue(error is VodozemacError)
        }
        
        // Test invalid base64 for SessionKey
        XCTAssertThrowsError(try SessionKey.fromBase64(input: "invalid_base64!")) { error in
            XCTAssertTrue(error is VodozemacError)
        }
        
        // Test invalid base64 for MegolmMessage
        XCTAssertThrowsError(try MegolmMessage.fromBase64(input: "invalid_base64!")) { error in
            XCTAssertTrue(error is VodozemacError)
        }
        
        // Test invalid pickle key length
        let config = MegolmSessionConfig.version1()
        let session = GroupSession.withConfig(config: config)
        let pickle = session.pickle()
        
        let invalidPickleKey = Data(repeating: 0x42, count: 16) // Wrong size
        XCTAssertThrowsError(try pickle.encrypt(pickle_key: invalidPickleKey)) { error in
            XCTAssertTrue(error is VodozemacError)
        }
    }
    
    /**
     * Test comprehensive encryption/decryption workflow
     */
    func testComprehensiveWorkflow() throws {
        print("🧪 Starting comprehensive Megolm workflow test...")
        
        // 1. Create configuration
        let config = MegolmSessionConfig.version2()
        print("✓ Created MegolmSessionConfig")
        
        // 2. Create outbound group session
        let outboundSession = GroupSession.withConfig(config: config)
        print("✓ Created GroupSession")
        
        // 3. Get session key for sharing
        let sessionKey = outboundSession.sessionKey()
        print("✓ Generated SessionKey: \(sessionKey.toBase64().prefix(20))...")
        
        // 4. Create inbound group session
        let inboundSession = InboundGroupSession(sessionKey: sessionKey, config: config)
        print("✓ Created InboundGroupSession")
        
        // 5. Encrypt multiple messages
        let messages = [
            "First secret message! 🔒",
            "Second confidential data! 🤐",
            "Third encrypted content! 🔐"
        ]
        
        var encryptedMessages: [MegolmMessage] = []
        for (index, message) in messages.enumerated() {
            let plaintext = message.data(using: .utf8)!
            let encrypted = outboundSession.encrypt(plaintext: plaintext)
            encryptedMessages.append(encrypted)
            print("✓ Encrypted message \(index + 1): \(encrypted.toBase64().prefix(30))...")
        }
        
        // 6. Decrypt all messages
        for (index, encryptedMessage) in encryptedMessages.enumerated() {
            let decrypted = try inboundSession.decrypt(message: encryptedMessage)
            let decryptedText = String(data: decrypted.plaintext(), encoding: .utf8)!
            XCTAssertEqual(decryptedText, messages[index])
            print("✓ Decrypted message \(index + 1): '\(decryptedText)'")
        }
        
        // 7. Test session export/import
        let exportedKey = inboundSession.exportAt(messageIndex: 1)!
        let importedSession = InboundGroupSession.import(exportedKey: exportedKey, config: config)
        XCTAssertEqual(importedSession.sessionId(), inboundSession.sessionId())
        print("✓ Successfully exported and imported session")
        
        // 8. Test pickling workflow
        let outboundPickle = outboundSession.pickle()
        let inboundPickle = inboundSession.pickle()
        
        let pickleKey = Data(repeating: 0x55, count: 32)
        let encryptedOutboundPickle = try outboundPickle.encrypt(pickle_key: pickleKey)
        let encryptedInboundPickle = try inboundPickle.encrypt(pickle_key: pickleKey)
        print("✓ Created encrypted pickles")
        
        // 9. Restore from pickles
        let restoredOutboundPickle = try GroupSessionPickle.fromEncrypted(
            ciphertext: encryptedOutboundPickle, 
            pickleKey: pickleKey
        )
        let restoredInboundPickle = try InboundGroupSessionPickle.fromEncrypted(
            ciphertext: encryptedInboundPickle, 
            pickleKey: pickleKey
        )
        
        let restoredOutbound = try GroupSession.fromPickle(pickle: restoredOutboundPickle)
        let restoredInbound = try InboundGroupSession.fromPickle(pickle: restoredInboundPickle)
        
        XCTAssertEqual(restoredOutbound.sessionId(), outboundSession.sessionId())
        XCTAssertEqual(restoredInbound.sessionId(), inboundSession.sessionId())
        print("✓ Successfully restored sessions from pickles")
        
        print("🎉 Comprehensive Megolm workflow test completed successfully!")
    }
}
