import Foundation

func runMegolmTests() -> Bool {
    print("🧪 Starting Megolm Tests")
    print("========================")
    
    var passed = 0
    var total = 0
    
    // Test 1: MegolmSessionConfig creation
    func testMegolmSessionConfig() -> Bool {
        total += 1
        print("\n• Testing MegolmSessionConfig creation...")
        
        _ = MegolmSessionConfig.version1()
        _ = MegolmSessionConfig.version2()
        
        print("  Created version 1 and version 2 configs successfully")
        passed += 1
        return true
    }
    
    // Test 2: GroupSession creation and basic operations
    func testGroupSession() -> Bool {
        total += 1
        print("\n• Testing GroupSession creation and basic operations...")
        
        let session = GroupSession()
        
        // Test session ID
        let sessionId = session.sessionId()
        print("  Session ID: \(sessionId)")
        
        // Test message index
        let messageIndex = session.messageIndex()
        print("  Initial message index: \(messageIndex)")
        
        if messageIndex == 0 {
            print("  ✅ Initial message index is correct")
            passed += 1
            return true
        } else {
            print("  ❌ Expected initial message index 0, got \(messageIndex)")
            return false
        }
    }
    
    // Test 3: GroupSession with custom config
    func testGroupSessionWithConfig() -> Bool {
        total += 1
        print("\n• Testing GroupSession with custom config...")
        
        let config = MegolmSessionConfig.version1()
        let session = GroupSession.withConfig(config: config)
        
        let sessionId = session.sessionId()
        print("  Session ID with custom config: \(sessionId)")
        
        passed += 1
        return true
    }
    
    // Test 4: Message encryption
    func testMessageEncryption() -> Bool {
        total += 1
        print("\n• Testing message encryption...")
        
        let session = GroupSession()
        let plaintext = Data("Hello, Megolm!".utf8)
        
        let encryptedMessage = session.encrypt(plaintext: plaintext)
        
        let messageIndex = encryptedMessage.messageIndex()
        let ciphertext = encryptedMessage.ciphertext()
        
        print("  Encrypted message index: \(messageIndex)")
        print("  Ciphertext length: \(ciphertext.count) bytes")
        
        if messageIndex == 0 && ciphertext.count > 0 {
            print("  ✅ Message encrypted successfully")
            passed += 1
            return true
        } else {
            print("  ❌ Encryption failed")
            return false
        }
    }
    
    // Test 5: Session key generation
    func testSessionKeyGeneration() -> Bool {
        total += 1
        print("\n• Testing session key generation...")
        
        let session = GroupSession()
        let sessionKey = session.sessionKey()
        
        let keyBase64 = sessionKey.toBase64()
        let keyBytes = sessionKey.toBytes()
        
        print("  Session key (base64): \(keyBase64.prefix(50))...")
        print("  Session key length: \(keyBytes.count) bytes")
        
        if keyBytes.count > 0 && keyBase64.count > 0 {
            print("  ✅ Session key generated successfully")
            passed += 1
            return true
        } else {
            print("  ❌ Session key generation failed")
            return false
        }
    }
    
    // Test 6: InboundGroupSession creation
    func testInboundGroupSession() -> Bool {
        total += 1
        print("\n• Testing InboundGroupSession creation...")
        
        let outboundSession = GroupSession()
        let sessionKey = outboundSession.sessionKey()
        let config = MegolmSessionConfig.version2()
        
        let inboundSession = InboundGroupSession(sessionKey: sessionKey, config: config)
        
        let sessionId = inboundSession.sessionId()
        let firstKnownIndex = inboundSession.firstKnownIndex()
        
        print("  Inbound session ID: \(sessionId)")
        print("  First known index: \(firstKnownIndex)")
        
        if firstKnownIndex == 0 {
            print("  ✅ InboundGroupSession created successfully")
            passed += 1
            return true
        } else {
            print("  ❌ Expected first known index 0, got \(firstKnownIndex)")
            return false
        }
    }
    
    // Test 7: End-to-end encryption and decryption
    func testEndToEndEncryption() -> Bool {
        total += 1
        print("\n• Testing end-to-end encryption and decryption...")
        
        do {
            let outboundSession = GroupSession()
            let sessionKey = outboundSession.sessionKey()
            let config = MegolmSessionConfig.version2()
            let inboundSession = InboundGroupSession(sessionKey: sessionKey, config: config)
            
            let originalText = "This is a secret message!"
            let plaintext = Data(originalText.utf8)
            
            // Encrypt message
            let encryptedMessage = outboundSession.encrypt(plaintext: plaintext)
            
            // Decrypt message
            let decryptedMessage = try inboundSession.decrypt(message: encryptedMessage)
            let decryptedText = String(data: decryptedMessage.plaintext(), encoding: .utf8) ?? ""
            
            print("  Original: \(originalText)")
            print("  Decrypted: \(decryptedText)")
            print("  Message index: \(decryptedMessage.messageIndex())")
            
            if decryptedText == originalText && decryptedMessage.messageIndex() == 0 {
                print("  ✅ End-to-end encryption/decryption successful")
                passed += 1
                return true
            } else {
                print("  ❌ Decryption failed or message index incorrect")
                return false
            }
        } catch {
            print("  ❌ FAILED: \(error)")
            return false
        }
    }
    
    // Test 8: Multiple messages
    func testMultipleMessages() -> Bool {
        total += 1
        print("\n• Testing multiple message encryption/decryption...")
        
        do {
            let outboundSession = GroupSession()
            let sessionKey = outboundSession.sessionKey()
            let config = MegolmSessionConfig.version2()
            let inboundSession = InboundGroupSession(sessionKey: sessionKey, config: config)
            
            let messages = ["First message", "Second message", "Third message"]
            
            for (index, message) in messages.enumerated() {
                let plaintext = Data(message.utf8)
                let encryptedMessage = outboundSession.encrypt(plaintext: plaintext)
                let decryptedMessage = try inboundSession.decrypt(message: encryptedMessage)
                let decryptedText = String(data: decryptedMessage.plaintext(), encoding: .utf8) ?? ""
                
                print("  Message \(index): \(message) -> \(decryptedText)")
                
                if decryptedText != message || decryptedMessage.messageIndex() != UInt32(index) {
                    print("  ❌ Message \(index) failed")
                    return false
                }
            }
            
            print("  ✅ Multiple messages encrypted/decrypted successfully")
            passed += 1
            return true
        } catch {
            print("  ❌ FAILED: \(error)")
            return false
        }
    }
    
    // Test 9: ExportedSessionKey
    func testExportedSessionKey() -> Bool {
        total += 1
        print("\n• Testing ExportedSessionKey...")
        
        let outboundSession = GroupSession()
        let sessionKey = outboundSession.sessionKey()
        let config = MegolmSessionConfig.version2()
        let inboundSession = InboundGroupSession(sessionKey: sessionKey, config: config)
        
        // Export the session key
        if let exportedKey = inboundSession.exportAt(messageIndex: 0) {
            let keyBase64 = exportedKey.toBase64()
            let keyBytes = exportedKey.toBytes()
            
            print("  Exported key (base64): \(keyBase64.prefix(50))...")
            print("  Exported key length: \(keyBytes.count) bytes")
            
            // Test creating InboundGroupSession from exported key
            let importedSession = InboundGroupSession.import(exportedKey: exportedKey, config: config)
            let importedSessionId = importedSession.sessionId()
            
            print("  Imported session ID: \(importedSessionId)")
            
            print("  ✅ ExportedSessionKey test successful")
            passed += 1
            return true
        } else {
            print("  ❌ Failed to export session key")
            return false
        }
    }
    
    // Test 10: MegolmMessage serialization
    func testMegolmMessageSerialization() -> Bool {
        total += 1
        print("\n• Testing MegolmMessage serialization...")
        
        do {
            let session = GroupSession()
            let plaintext = Data("Test message".utf8)
            let encryptedMessage = session.encrypt(plaintext: plaintext)
            
            // Test to_bytes and to_base64
            let messageBytes = encryptedMessage.toBytes()
            let messageBase64 = encryptedMessage.toBase64()
            
            print("  Message bytes length: \(messageBytes.count)")
            print("  Message base64 length: \(messageBase64.count)")
            
            // Test creating MegolmMessage from bytes
            let recreatedFromBytes = try MegolmMessage.fromBytes(bytes: messageBytes)
            let recreatedFromBase64 = try MegolmMessage.fromBase64(input: messageBase64)
            
            // Compare message indices
            let originalIndex = encryptedMessage.messageIndex()
            let bytesIndex = recreatedFromBytes.messageIndex()
            let base64Index = recreatedFromBase64.messageIndex()
            
            print("  Original message index: \(originalIndex)")
            print("  From bytes message index: \(bytesIndex)")
            print("  From base64 message index: \(base64Index)")
            
            if originalIndex == bytesIndex && bytesIndex == base64Index {
                print("  ✅ MegolmMessage serialization successful")
                passed += 1
                return true
            } else {
                print("  ❌ Message indices don't match")
                return false
            }
        } catch {
            print("  ❌ FAILED: \(error)")
            return false
        }
    }
    
    // Test 11: Session pickling (following OLM pattern)
    func testSessionPickling() -> Bool {
        total += 1
        print("\n• Testing GroupSession pickling...")
        
        do {
            let originalSession = GroupSession()
            let originalSessionId = originalSession.sessionId()
            
            // Encrypt a message to advance the ratchet
            let plaintext = Data("Test message".utf8)
            _ = originalSession.encrypt(plaintext: plaintext)
            let messageIndex = originalSession.messageIndex()
            
            // Create pickle and immediately use it to create session (avoid holding reference)
            print("  Session pickled successfully")
            let restoredSession = try { () -> GroupSession in
                let pickle = originalSession.pickle()
                return try GroupSession.fromPickle(pickle: pickle)
            }()
            
            let restoredSessionId = restoredSession.sessionId()
            let restoredMessageIndex = restoredSession.messageIndex()
            
            print("  Original session ID: \(originalSessionId)")
            print("  Restored session ID: \(restoredSessionId)")
            print("  Original message index: \(messageIndex)")
            print("  Restored message index: \(restoredMessageIndex)")
            
            if originalSessionId == restoredSessionId && messageIndex == restoredMessageIndex {
                print("  ✅ Session pickling successful")
                passed += 1
                return true
            } else {
                print("  ❌ Session pickling failed - session data doesn't match")
                return false
            }
        } catch {
            print("  ❌ FAILED: \(error)")
            return false
        }
    }
    
    // Run all tests
    _ = [
        testMegolmSessionConfig(),
        testGroupSession(),
        testGroupSessionWithConfig(),
        testMessageEncryption(),
        testSessionKeyGeneration(),
        testInboundGroupSession(),
        testEndToEndEncryption(),
        testMultipleMessages(),
        testExportedSessionKey(),
        testMegolmMessageSerialization(),
        testSessionPickling()
    ]
    
    print("\n========================")
    print("Megolm Tests Summary:")
    print("Passed: \(passed)/\(total)")
    print("Success rate: \(passed == total ? "100%" : "\(Int(Double(passed)/Double(total) * 100))%")")
    
    if passed == total {
        print("✅ ALL MEGOLM TESTS PASSED!")
        return true
    } else {
        print("❌ Some Megolm tests failed")
        return false
    }
}
