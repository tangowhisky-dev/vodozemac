import Foundation

func runOlmTests() -> Bool {
    print("🔐 Testing OLM (Olm) Double Ratchet Protocol...")
    print("================================================")
    
    var allTestsPassed = true
    
    // Run all OLM test functions
    allTestsPassed = testOlmAccountBasics() && allTestsPassed
    allTestsPassed = testOlmAccountPickle() && allTestsPassed
    allTestsPassed = testOlmIdentityKeys() && allTestsPassed
    allTestsPassed = testOlmOneTimeKeys() && allTestsPassed
    allTestsPassed = testOlmSessionCreation() && allTestsPassed
    allTestsPassed = testOlmMessageEncryption() && allTestsPassed
    allTestsPassed = testOlmSessionPickle() && allTestsPassed
    allTestsPassed = testOlmSessionConfig() && allTestsPassed
    allTestsPassed = testOlmIntegrationFlow() && allTestsPassed
    
    return allTestsPassed
}

func testOlmAccountBasics() -> Bool {
    print("\n1. Testing OLM Account basics...")
    
    do {
        // Create account
        let account = Account()
        print("   ✓ Account created")
        
        // Test identity keys
        let identityKeys = account.identityKeys()
        print("   ✓ Retrieved identity keys")
        print("     Ed25519: \(identityKeys.ed25519().toBase64())")
        print("     Curve25519: \(identityKeys.curve25519().toBase64())")
        
        // Test signing
        let message = "Hello, World!".data(using: .utf8)!
        let signature = account.sign(message: message)
        print("   ✓ Message signed")
        print("     Signature: \(signature.toBase64())")
        
        // Test pickling
        let pickle = account.pickle()
        print("   ✓ Account pickled successfully")
        
        // Unpickle the account
        let unPickledAccount = try Account.fromPickle(pickle: pickle)
        print("   ✓ Account unpickled successfully")
        
        // Test identity keys match
        let unPickledIdentityKeys = unPickledAccount.identityKeys()
        let ed25519Match = identityKeys.ed25519().toBase64() == unPickledIdentityKeys.ed25519().toBase64()
        let curve25519Match = identityKeys.curve25519().toBase64() == unPickledIdentityKeys.curve25519().toBase64()
        
        if ed25519Match && curve25519Match {
            print("   ✓ Identity keys match after unpickling")
        } else {
            print("   ❌ Identity keys do not match after unpickling")
            return false
        }
        
        return true
        
    } catch {
        print("   ❌ FAILED: \(error)")
        return false
    }
}

func testOlmAccountPickle() -> Bool {
    print("\n2. Testing OLM Account pickling...")
    
    do {
        // Create account and generate keys
        let account = Account()
        _ = account.generateOneTimeKeys(count: 3)
        
        // Pickle the account
        let pickle = account.pickle()
        print("   ✓ Account pickled successfully")
        
        // Unpickle the account
        let unPickledAccount = try Account.fromPickle(pickle: pickle)
        print("   ✓ Account unpickled successfully")
        
        // Verify identity keys match
        let originalKeys = account.identityKeys()
        let unPickledKeys = unPickledAccount.identityKeys()
        
        guard originalKeys.ed25519().toBase64() == unPickledKeys.ed25519().toBase64() &&
              originalKeys.curve25519().toBase64() == unPickledKeys.curve25519().toBase64() else {
            print("   ❌ FAILED: Identity keys don't match after unpickling")
            return false
        }
        
        print("   ✓ Identity keys match after unpickling")
        return true
        
    } catch {
        print("   ❌ FAILED: \(error)")
        return false
    }
}

func testOlmIdentityKeys() -> Bool {
    print("\n3. Testing OLM IdentityKeys...")
    
    do {
        let account = Account()
        let identityKeys = account.identityKeys()
        
        // Test key extraction
        let ed25519Key = identityKeys.ed25519()
        let curve25519Key = identityKeys.curve25519()
        
        // Verify keys are valid (non-empty base64)
        let ed25519Base64 = ed25519Key.toBase64()
        let curve25519Base64 = curve25519Key.toBase64()
        
        guard !ed25519Base64.isEmpty && !curve25519Base64.isEmpty else {
            print("   ❌ FAILED: Keys should not be empty")
            return false
        }
        
        guard ed25519Base64.count > 20 && curve25519Base64.count > 20 else {
            print("   ❌ FAILED: Keys seem too short")
            return false
        }
        
        print("   ✓ Ed25519 key: \(ed25519Base64)")
        print("   ✓ Curve25519 key: \(curve25519Base64)")
        print("   ✓ IdentityKeys working correctly")
        
        return true
        
    } catch {
        print("   ❌ FAILED: \(error)")
        return false
    }
}

func testOlmOneTimeKeys() -> Bool {
    print("\n4. Testing OLM One-time key generation...")
    
    do {
        let account = Account()
        
        // Generate different amounts of keys
        let result1 = account.generateOneTimeKeys(count: 1)
        let generated1 = result1.generated()
        guard generated1.count == 1 else {
            print("   ❌ FAILED: Expected 1 key, got \(generated1.count)")
            return false
        }
        print("   ✓ Generated 1 one-time key successfully")
        
        let result5 = account.generateOneTimeKeys(count: 5)
        let generated5 = result5.generated()
        guard generated5.count == 5 else {
            print("   ❌ FAILED: Expected 5 keys, got \(generated5.count)")
            return false
        }
        print("   ✓ Generated 5 one-time keys successfully")
        
        // Verify keys are different
        let key1Base64 = generated1[0].toBase64()
        let key2Base64 = generated5[0].toBase64()
        
        guard key1Base64 != key2Base64 else {
            print("   ❌ FAILED: Keys should be different")
            return false
        }
        
        print("   ✓ Keys are unique: \(key1Base64) != \(key2Base64)")
        return true
        
    } catch {
        print("   ❌ FAILED: \(error)")
        return false
    }
}

func testOlmSessionCreation() -> Bool {
    print("\n5. Testing OLM Session creation...")
    
    do {
        // Create two accounts (Alice and Bob)
        let alice = Account()
        let bob = Account()
        
        let aliceIdentity = alice.identityKeys()
        let bobIdentity = bob.identityKeys()
        
        // Bob generates one-time keys
        let bobOneTimeResult = bob.generateOneTimeKeys(count: 1)
        let bobOneTimeKeys = bobOneTimeResult.generated()
        let bobOneTimeKey = bobOneTimeKeys[0]
        
        // Alice creates outbound session to Bob
        let sessionConfig = SessionConfig.version1()
        let aliceSession = alice.createOutboundSession(
            sessionConfig: sessionConfig,
            identityKey: bobIdentity.curve25519(),
            oneTimeKey: bobOneTimeKey
        )
        print("   ✓ Alice created outbound session to Bob")
        
        // Test session methods
        let sessionId = aliceSession.sessionId()
        print("   ✓ Session ID: \(sessionId)")
        
        let hasReceived = aliceSession.hasReceivedMessage()
        print("   ✓ Has received message: \(hasReceived)")
        
        return true
        
    } catch {
        print("   ❌ FAILED: \(error)")
        return false
    }
}

func testOlmMessageEncryption() -> Bool {
    print("\n6. Testing OLM Message encryption/decryption...")
    
    do {
        // Alice and Bob accounts
        let alice = Account()
        let bob = Account()
        
        let aliceIdentity = alice.identityKeys()
        let bobIdentity = bob.identityKeys()
        let bobOneTimeResult = bob.generateOneTimeKeys(count: 1)
        let bobOneTimeKeys = bobOneTimeResult.generated()
        
        let sessionConfig = SessionConfig.version1()
        let aliceSession = alice.createOutboundSession(
            sessionConfig: sessionConfig,
            identityKey: bobIdentity.curve25519(),
            oneTimeKey: bobOneTimeKeys[0]
        )
        
        // Alice encrypts a message
        let plaintext = "Hello, Bob! This is Alice sending a secret message."
        let plaintextData = plaintext.data(using: .utf8)!
        
        let encryptedMessage = aliceSession.encrypt(plaintext: plaintextData)
        print("   ✓ Alice encrypted message successfully")
        
        // Test message base64 conversion
        let messageBase64 = encryptedMessage.toBase64()
        let messageFromBase64 = try OlmMessage.fromBase64(message: messageBase64)
        
        // Verify they're equivalent (both should have same base64)
        guard messageBase64 == messageFromBase64.toBase64() else {
            print("   ❌ FAILED: Message base64 round-trip failed")
            return false
        }
        print("   ✓ Message base64 conversion works correctly")
        
        // Bob creates inbound session and decrypts
        // First check the message type
        let messageType = encryptedMessage.messageType()
        
        guard messageType == MessageType.preKey else {
            print("   ❌ FAILED: First message should be PreKey type")
            return false
        }
        
        // Convert OlmMessage to PreKeyMessage for inbound session creation
        let preKeyMessage = try PreKeyMessage.fromBase64(message: messageBase64)
        
        let bobInboundResult = try bob.createInboundSession(
            theirIdentityKey: aliceIdentity.curve25519(),
            preKeyMessage: preKeyMessage
        )
        let bobSession = bobInboundResult.session()
        let decryptedData = try bobSession.decrypt(message: encryptedMessage)
        
        let decryptedText = String(data: decryptedData, encoding: .utf8) ?? ""
        
        guard decryptedText == plaintext else {
            print("   ❌ FAILED: Decrypted text doesn't match. Got: '\(decryptedText)'")
            return false
        }
        
        print("   ✓ Bob decrypted message successfully: '\(decryptedText)'")
        
        // Test bidirectional communication
        let bobReply = "Hello Alice! This is Bob replying securely."
        let bobReplyData = bobReply.data(using: .utf8)!
        let bobEncrypted = bobSession.encrypt(plaintext: bobReplyData)
        
        let aliceDecrypted = try aliceSession.decrypt(message: bobEncrypted)
        let aliceReceivedText = String(data: aliceDecrypted, encoding: .utf8) ?? ""
        
        guard aliceReceivedText == bobReply else {
            print("   ❌ FAILED: Alice didn't receive Bob's reply correctly")
            return false
        }
        
        print("   ✓ Bidirectional communication works: '\(aliceReceivedText)'")
        return true
        
    } catch {
        print("   ❌ FAILED: \(error)")
        return false
    }
}

func testOlmSessionPickle() -> Bool {
    print("\n7. Testing OLM Session pickling...")
    
    do {
        // Create session
        let alice = Account()
        let bob = Account()
        
        let bobIdentity = bob.identityKeys()
        let bobOneTimeResult = bob.generateOneTimeKeys(count: 1)
        let bobOneTimeKeys = bobOneTimeResult.generated()
        
        let sessionConfig = SessionConfig.version1()
        let session = alice.createOutboundSession(
            sessionConfig: sessionConfig,
            identityKey: bobIdentity.curve25519(),
            oneTimeKey: bobOneTimeKeys[0]
        )
        
        // Pickle the session
        let sessionPickle = session.pickle()
        print("   ✓ Session pickled successfully")
        
        // Unpickle the session
        let unPickledSession = try Session.fromPickle(pickle: sessionPickle)
        print("   ✓ Session unpickled successfully")
        
        // Verify session IDs match
        let originalSessionId = session.sessionId()
        let unPickledSessionId = unPickledSession.sessionId()
        
        guard originalSessionId == unPickledSessionId else {
            print("   ❌ FAILED: Session IDs don't match after unpickling")
            return false
        }
        
        print("   ✓ Session IDs match: \(originalSessionId)")
        return true
        
    } catch {
        print("   ❌ FAILED: \(error)")
        return false
    }
}

func testOlmSessionConfig() -> Bool {
    print("\n8. Testing OLM SessionConfig...")
    
    do {
        // Test SessionConfig variants
        let version1 = SessionConfig.version1()
        let version2 = SessionConfig.version2()
        
        print("   ✓ SessionConfig.version1() created")
        print("   ✓ SessionConfig.version2() created")
        
        // Use configs in session creation
        let alice = Account()
        let bob = Account()
        
        let bobIdentity = bob.identityKeys()
        let bobOneTimeResult = bob.generateOneTimeKeys(count: 2)
        let bobOneTimeKeys = bobOneTimeResult.generated()
        
        // Create session with version1 config
        let sessionV1 = alice.createOutboundSession(
            sessionConfig: version1,
            identityKey: bobIdentity.curve25519(),
            oneTimeKey: bobOneTimeKeys[0]
        )
        
        // Create session with version2 config  
        let sessionV2 = alice.createOutboundSession(
            sessionConfig: version2,
            identityKey: bobIdentity.curve25519(),
            oneTimeKey: bobOneTimeKeys[1]
        )
        
        print("   ✓ Sessions created with different configs")
        print("   ✓ SessionV1 ID: \(sessionV1.sessionId())")
        print("   ✓ SessionV2 ID: \(sessionV2.sessionId())")
        
        return true
        
    } catch {
        print("   ❌ FAILED: \(error)")
        return false
    }
}

func testOlmIntegrationFlow() -> Bool {
    print("\n9. Testing OLM complete integration flow...")
    
    do {
        // Full OLM flow: Account creation, session establishment, messaging, persistence
        print("   → Creating Alice and Bob accounts...")
        let alice = Account()
        let bob = Account()
        
        print("   → Generating identity keys and one-time keys...")
        let aliceIdentity = alice.identityKeys()
        let bobIdentity = bob.identityKeys()
        let bobOneTimeResult = bob.generateOneTimeKeys(count: 1)
        let bobOneTimeKeys = bobOneTimeResult.generated()
        
        print("   → Alice creating outbound session...")
        let sessionConfig = SessionConfig.version1()
        let aliceSession = alice.createOutboundSession(
            sessionConfig: sessionConfig,
            identityKey: bobIdentity.curve25519(),
            oneTimeKey: bobOneTimeKeys[0]
        )
        
        print("   → Alice sending first message...")
        let message1 = "Integration test message 1 from Alice"
        let encrypted1 = aliceSession.encrypt(plaintext: message1.data(using: .utf8)!)
        
        print("   → Bob creating inbound session...")
        let messageBase64 = encrypted1.toBase64()
        let preKeyMessage = try PreKeyMessage.fromBase64(message: messageBase64)
        let bobInboundResult = try bob.createInboundSession(
            theirIdentityKey: aliceIdentity.curve25519(),
            preKeyMessage: preKeyMessage
        )
        let bobSession = bobInboundResult.session()
        
        print("   → Bob decrypting first message...")
        let decrypted1 = try bobSession.decrypt(message: encrypted1)
        let receivedMessage1 = String(data: decrypted1, encoding: .utf8)!
        
        guard receivedMessage1 == message1 else {
            print("   ❌ FAILED: Message 1 mismatch")
            return false
        }
        
        print("   → Message 1 success: '\(receivedMessage1)'")
        
        print("   → Bob replying...")
        let message2 = "Integration test reply from Bob"
        let encrypted2 = bobSession.encrypt(plaintext: message2.data(using: .utf8)!)
        let decrypted2 = try aliceSession.decrypt(message: encrypted2)
        let receivedMessage2 = String(data: decrypted2, encoding: .utf8)!
        
        guard receivedMessage2 == message2 else {
            print("   ❌ FAILED: Message 2 mismatch")
            return false
        }
        
        print("   → Message 2 success: '\(receivedMessage2)'")
        
        print("   → Testing multiple message rounds...")
        for i in 3...5 {
            let aliceMsg = "Alice message \(i)"
            let bobMsg = "Bob reply \(i)"
            
            // Alice -> Bob
            let encAlice = aliceSession.encrypt(plaintext: aliceMsg.data(using: .utf8)!)
            let decAlice = try bobSession.decrypt(message: encAlice)
            let receivedAlice = String(data: decAlice, encoding: .utf8)!
            
            guard receivedAlice == aliceMsg else {
                print("   ❌ FAILED: Alice message \(i) mismatch")
                return false
            }
            
            // Bob -> Alice
            let encBob = bobSession.encrypt(plaintext: bobMsg.data(using: .utf8)!)
            let decBob = try aliceSession.decrypt(message: encBob)
            let receivedBob = String(data: decBob, encoding: .utf8)!
            
            guard receivedBob == bobMsg else {
                print("   ❌ FAILED: Bob message \(i) mismatch")
                return false
            }
            
            print("   → Round \(i): ✓ '\(receivedAlice)' / ✓ '\(receivedBob)'")
        }
        
        print("   → Testing session persistence...")
        
        // Pickle both accounts and sessions
        let aliceAccountPickle = alice.pickle()
        let bobAccountPickle = bob.pickle()
        let aliceSessionPickle = aliceSession.pickle()
        let bobSessionPickle = bobSession.pickle()
        
        // Restore from pickles
        let restoredAliceAccount = try Account.fromPickle(pickle: aliceAccountPickle)
        let restoredBobAccount = try Account.fromPickle(pickle: bobAccountPickle)
        let restoredAliceSession = try Session.fromPickle(pickle: aliceSessionPickle)
        let restoredBobSession = try Session.fromPickle(pickle: bobSessionPickle)
        
        // Verify restored sessions work
        let finalMessage = "Final message after restore"
        let finalEncrypted = restoredAliceSession.encrypt(plaintext: finalMessage.data(using: .utf8)!)
        let finalDecrypted = try restoredBobSession.decrypt(message: finalEncrypted)
        let finalReceived = String(data: finalDecrypted, encoding: .utf8)!
        
        guard finalReceived == finalMessage else {
            print("   ❌ FAILED: Restored session message mismatch")
            return false
        }
        
        print("   ✓ Integration flow completed successfully!")
        print("   ✓ Verified: Account creation, session establishment, bidirectional messaging, persistence")
        print("   ✓ Final message: '\(finalReceived)'")
        
        return true
        
    } catch {
        print("   ❌ FAILED: \(error)")
        return false
    }
}
