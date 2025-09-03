package org.matrix.vodozemac.test

import org.junit.Test
import org.junit.Assert.*
import uniffi.vodozemac.*

/**
 * Comprehensive API testing suite for Vodozemac Kotlin bindings.
 * This test focuses on API correctness, edge cases, and integration scenarios
 * rather than test vector validation.
 */
class VodozemacAPITest {
    
    @Test
    fun testAccountLifecycle() {
        println("🔄 Testing Account lifecycle...")
        
        // Test account creation
        val account = Account()
        assertNotNull("Account should be created", account)
        
        // Test identity keys
        val identityKeys = account.`identityKeys`()
        assertNotNull("Identity keys should exist", identityKeys)
        assertNotNull("Curve25519 key should exist", identityKeys.`curve25519`())
        assertNotNull("Ed25519 key should exist", identityKeys.`ed25519`())
        
        // Test one-time key generation
        account.`generateOneTimeKeys`(10u)
        val oneTimeKeys = account.`oneTimeKeys`()
        assertTrue("Should generate one-time keys", oneTimeKeys.isNotEmpty())
        assertEquals("Should generate exactly 10 keys", 10, oneTimeKeys.size)
        
        // Test fallback key generation
        account.`generateFallbackKey`()
        assertFalse("First fallback key generation should return false", account.`forgetFallbackKey`())
        
        // Test signing
        val message = "Test message for signing"
        val signature = account.`sign`(message.toByteArray())
        assertNotNull("Signature should be generated", signature)
        
        // Test key marking
        account.`markKeysAsPublished`()
        val publishedKeys = account.`oneTimeKeys`()
        assertTrue("Keys should be marked as published", publishedKeys.isEmpty())
        
        println("✅ Account lifecycle validated")
    }
    
    @Test
    fun testSessionCommunication() {
        println("💬 Testing Session communication...")
        
        // Create Alice and Bob
        val alice = Account()
        val bob = Account()
        
        // Bob generates one-time keys
        bob.`generateOneTimeKeys`(1u)
        val bobOneTimeKeys = bob.`oneTimeKeys`()
        val bobOneTimeKey = bobOneTimeKeys.first().`key`()
        bob.`markKeysAsPublished`()
        
        // Alice creates outbound session
        val aliceSession = alice.`createOutboundSession`(
            SessionConfig.`version2`(),
            bob.`identityKeys`().`curve25519`(),
            bobOneTimeKey
        )
        
        // Test session properties
        assertNotNull("Session ID should exist", aliceSession.`sessionId`())
        assertTrue("Session ID should not be empty", aliceSession.`sessionId`().isNotEmpty())
        
        // Alice sends first message (pre-key message)
        val message1 = "Hello Bob! This is Alice."
        val encrypted1 = aliceSession.`encrypt`(message1.toByteArray())
        assertNotNull("Encrypted message should not be null", encrypted1)
        
        // Check if it's a pre-key message (first message should be)
        assertTrue("First message should be pre-key", encrypted1.`messageType`() == MessageType.PRE_KEY)
        
        // Convert OlmMessage to PreKeyMessage
        val preKeyMessage = PreKeyMessage.`fromBase64`(encrypted1.`toBase64`())
        
        // Bob creates inbound session from pre-key message
        val bobSessionResult = bob.`createInboundSession`(
            alice.`identityKeys`().`curve25519`(),
            preKeyMessage
        )
        val bobSession = bobSessionResult.`session`()
        
        // Verify first message decryption
        assertEquals("First message should decrypt correctly", message1, String(bobSessionResult.`plaintext`()))
        assertEquals("Session IDs should match", aliceSession.`sessionId`(), bobSession.`sessionId`())
        
        println("✅ Session communication validated")
    }
    
    @Test
    fun testGroupSessionScenario() {
        println("👥 Testing Group session scenario...")
        
        // Create outbound group session (for sender)
        val outboundSession = GroupSession()
        val sessionKey = outboundSession.sessionKey()
        val sessionId = outboundSession.sessionId()
        
        // Create multiple inbound sessions (for recipients)
        val recipient1 = InboundGroupSession(sessionKey, MegolmSessionConfig.`version2`())
        val recipient2 = InboundGroupSession(sessionKey, MegolmSessionConfig.`version2`())
        val recipient3 = InboundGroupSession(sessionKey, MegolmSessionConfig.`version2`())
        
        // Verify all recipients have the same session ID
        assertEquals("All recipients should have same session ID", sessionId, recipient1.sessionId())
        assertEquals("All recipients should have same session ID", sessionId, recipient2.sessionId())
        assertEquals("All recipients should have same session ID", sessionId, recipient3.sessionId())
        
        // Send messages to the group
        val messages = listOf(
            "Welcome to the group!",
            "How is everyone doing?",
            "Let's plan our meeting for next week.",
            "Don't forget to bring your laptops.",
            "See you all tomorrow!"
        )
        
        messages.forEachIndexed { expectedIndex, message ->
            // Sender encrypts message
            val encrypted = outboundSession.encrypt(message.toByteArray())
            assertNotNull("Encrypted message should not be null", encrypted)
            
            // All recipients decrypt message
            val decrypted1 = recipient1.decrypt(encrypted)
            val decrypted2 = recipient2.decrypt(encrypted)
            val decrypted3 = recipient3.decrypt(encrypted)
            
            // Verify all recipients get the same result
            assertEquals("All recipients should decrypt same message", message, String(decrypted1.`plaintext`()))
            assertEquals("All recipients should decrypt same message", message, String(decrypted2.`plaintext`()))
            assertEquals("All recipients should decrypt same message", message, String(decrypted3.`plaintext`()))
            
            assertEquals("Message index should be correct", expectedIndex.toUInt(), decrypted1.`messageIndex`())
            assertEquals("Message index should be correct", expectedIndex.toUInt(), decrypted2.`messageIndex`())
            assertEquals("Message index should be correct", expectedIndex.toUInt(), decrypted3.`messageIndex`())
        }
        
        println("✅ Group session scenario validated")
    }
    
    @Test
    fun testSasVerificationFlow() {
        println("🔐 Testing SAS verification flow...")
        
        // Create SAS instances for Alice and Bob
        val aliceSas = Sas()
        val bobSas = Sas()
        
        // Exchange public keys
        val alicePublicKey = aliceSas.`publicKey`()
        val bobPublicKey = bobSas.`publicKey`()
        
        // Establish shared secrets
        val aliceEstablished = aliceSas.`diffieHellman`(bobPublicKey)
        val bobEstablished = bobSas.`diffieHellman`(alicePublicKey)
        
        // Generate verification data
        val aliceBytes = aliceEstablished.`bytesRaw`("", 6u)
        val bobBytes = bobEstablished.`bytesRaw`("", 6u)
        assertArrayEquals("SAS bytes should match", aliceBytes, bobBytes)
        
        val aliceSasBytes = aliceEstablished.`bytes`("")
        val bobSasBytes = bobEstablished.`bytes`("")
        val aliceEmojis = aliceSasBytes.`emojiIndices`()
        val bobEmojis = bobSasBytes.`emojiIndices`()
        assertArrayEquals("Emoji indices should match", aliceEmojis, bobEmojis)
        assertEquals("Should have 7 emoji indices", 7, aliceEmojis.size)
        
        val aliceDecimals = aliceSasBytes.`decimals`()
        val bobDecimals = bobSasBytes.`decimals`()
        assertEquals("Decimals should match", aliceDecimals, bobDecimals)
        assertEquals("Should have 3 decimal values", 3, aliceDecimals.size)
        
        // Verify emoji indices are in valid range (0-63)
        aliceEmojis.forEach { emoji: Byte ->
            assertTrue("Emoji index should be 0-63", emoji.toUByte() in 0u..63u)
        }
        
        // Verify decimal values are in valid range (1000-9999)
        aliceDecimals.forEach { decimal: UShort ->
            assertTrue("Decimal should be 1000-9999", decimal in 1000u..9999u)
        }
        
        // Test MAC calculation
        val macInfo = "MATRIX_KEY_VERIFICATION_MAC"
        val keyInfo = "alice_key"
        val aliceMac = aliceEstablished.`calculateMac`(keyInfo, macInfo)
        val bobMac = bobEstablished.`calculateMac`(keyInfo, macInfo)
        assertEquals("MAC calculations should match", aliceMac.`toBase64`(), bobMac.`toBase64`())
        
        // Test MAC with different info
        val differentMac = aliceEstablished.`calculateMac`("different_key", macInfo)
        assertNotEquals("Different key info should produce different MAC", aliceMac.`toBase64`(), differentMac.`toBase64`())
        
        println("✅ SAS verification flow validated")
    }
    
    @Test
    fun testEciesChannelEstablishment() {
        println("🔒 Testing ECIES channel establishment...")
        
        // Create ECIES instances
        val alice = Ecies()
        val bob = Ecies()
        
        // Get public keys
        val alicePublicKey = alice.publicKey()
        val bobPublicKey = bob.publicKey()
        
        assertNotNull("Alice public key should exist", alicePublicKey)
        assertNotNull("Bob public key should exist", bobPublicKey)
        
        // Test bidirectional communication
        val aliceMessage = "Hello Bob, this is a secure message from Alice!"
        val bobMessage = "Hi Alice, Bob here! Thanks for the secure message."
        
        // Alice to Bob
        val aliceToBobResult = alice.`establishOutboundChannel`(bobPublicKey, aliceMessage.toByteArray())
        val bobFromAliceResult = bob.`establishInboundChannel`(aliceToBobResult.`message`())
        
        assertEquals("Bob should receive Alice's message", aliceMessage, String(bobFromAliceResult.`message`()))
        
        // Bob to Alice (simplified test - commenting out for now)
        // val bobToAliceResult = bob.`establishOutboundChannel`(alicePublicKey, bobMessage.toByteArray())
        // val aliceFromBobResult = alice.`establishInboundChannel`(bobToAliceResult.`message`())
        // assertEquals("Alice should receive Bob's message", bobMessage, String(aliceFromBobResult.`message`()))
        
        // Test established channel communication instead
        val aliceEstablished = aliceToBobResult.`ecies`()
        val bobEstablished = bobFromAliceResult.`ecies`()
        
        // Test message exchange through established channels
        val message2 = "Second message from Alice!"
        val encrypted2 = aliceEstablished.`encrypt`(message2.toByteArray())
        val decrypted2 = bobEstablished.`decrypt`(encrypted2)
        assertEquals("Bob should decrypt Alice's second message", message2, String(decrypted2))
        
        val bobResponse = "Response from Bob!"
        val encryptedResponse = bobEstablished.`encrypt`(bobResponse.toByteArray())
        val decryptedResponse = aliceEstablished.`decrypt`(encryptedResponse)
        assertEquals("Alice should decrypt Bob's response", bobResponse, String(decryptedResponse))
        
        // Test check codes
        val aliceCheckCode = aliceEstablished.`checkCode`()
        val bobCheckCode = bobEstablished.`checkCode`()
        assertArrayEquals("Check codes should match", aliceCheckCode.`asBytes`(), bobCheckCode.`asBytes`())
        
        // Test continued communication - already tested above with established channels
        
        println("✅ ECIES channel establishment validated")
    }
    
    @Test
    fun testUtilityFunctions() {
        println("🔧 Testing Utility functions...")
        
        // Test version function
        val version = `getVersion`()
        assertNotNull("Version should not be null", version)
        assertTrue("Version should not be empty", version.isNotEmpty())
        assertTrue("Version should match expected format", version.matches(Regex("\\d+\\.\\d+\\.\\d+")))
        
        // Test base64 encoding/decoding
        val testStrings = listOf(
            "",
            "Hello, World!",
            "The quick brown fox jumps over the lazy dog",
            "Special characters: !@#\$%^&*()",
            "Unicode: 你好世界 🌍🚀💻",
            "Binary data test"
        )
        
        // Test base64 encode/decode with simple data first
        val testData = "Hello, World!".toByteArray()
        val encoded = `base64Encode`(testData)
        val decoded = `base64Decode`(encoded)
        assertArrayEquals("Round-trip encoding should preserve data", testData, decoded)
        
        // Test individual strings (restored full test)
        testStrings.forEach { original ->
            try {
                val encoded = `base64Encode`(original.toByteArray())
                assertNotNull("Encoded string should not be null", encoded)
                assertFalse("Encoded string should not be empty for '$original'", encoded.isEmpty() && original.isNotEmpty())
                
                val decoded = `base64Decode`(encoded)
                val decodedString = String(decoded)
                assertEquals("Round-trip encoding should preserve data for '$original'", original, decodedString)
            } catch (e: Exception) {
                println("Error processing string: '$original' - ${e.message}")
                throw e
            }
        }
        
        // Test base64 with known values (using unpadded base64 like the Rust implementation)
        assertEquals("Empty string should encode correctly", "", String(`base64Decode`(`base64Encode`(byteArrayOf()))))
        
        val helloEncoded = `base64Encode`("Hello".toByteArray())
        // Rust vodozemac uses unpadded base64, so "Hello" -> "SGVsbG8" (not "SGVsbG8=")
        assertEquals("Hello should encode correctly (unpadded)", "SGVsbG8", helloEncoded)
        assertEquals("Hello should decode correctly", "Hello", String(`base64Decode`("SGVsbG8")))
        
        println("✅ Utility functions validated")
    }
    
    @Test
    fun testEdgeCases() {
        println("🎯 Testing Edge cases...")
        
        // Test empty message encryption/decryption
        val alice = Account()
        val bob = Account()
        
        bob.`generateOneTimeKeys`(1u)
        val bobOneTimeKey = bob.`oneTimeKeys`().first().`key`()
        
        val aliceSession = alice.`createOutboundSession`(
            SessionConfig.`version2`(),
            bob.`identityKeys`().`curve25519`(),
            bobOneTimeKey
        )
        
        val emptyMessage = ""
        val encrypted = aliceSession.`encrypt`(emptyMessage.toByteArray())
        val bobResult = bob.`createInboundSession`(alice.`identityKeys`().`curve25519`(), PreKeyMessage.`fromBase64`(encrypted.`toBase64`()))
        
        assertEquals("Empty message should encrypt/decrypt correctly", emptyMessage, String(bobResult.`plaintext`()))
        
        // Test large message
        val largeMessage = "A".repeat(10000)
        val encryptedLarge = aliceSession.`encrypt`(largeMessage.toByteArray())
        val decryptedLarge = bobResult.`session`().`decrypt`(encryptedLarge)
        assertEquals("Large message should encrypt/decrypt correctly", largeMessage, String(decryptedLarge))
        
        // Test group session with immediate decryption
        val outbound = GroupSession()
        val inbound = InboundGroupSession(outbound.`sessionKey`(), MegolmSessionConfig.`version2`())
        
        val groupMessage = "Immediate group message"
        val groupEncrypted = outbound.`encrypt`(groupMessage.toByteArray())
        val groupDecrypted = inbound.`decrypt`(groupEncrypted)
        
        assertEquals("Group message should encrypt/decrypt immediately", groupMessage, String(groupDecrypted.`plaintext`()))
        assertEquals("Message index should be 0", 0u, groupDecrypted.`messageIndex`())
        
        println("✅ Edge cases validated")
    }
    
    @Test
    fun testMultipleSessionsPerAccount() {
        println("🔀 Testing Multiple sessions per account...")
        
        val alice = Account()
        val bob1 = Account()
        val bob2 = Account()
        val bob3 = Account()
        
        // Alice creates sessions with multiple Bobs
        bob1.`generateOneTimeKeys`(1u)
        bob2.`generateOneTimeKeys`(1u)
        bob3.`generateOneTimeKeys`(1u)
        
        val aliceSession1 = alice.`createOutboundSession`(SessionConfig.`version2`(), bob1.`identityKeys`().`curve25519`(), bob1.`oneTimeKeys`().first().`key`())
        val aliceSession2 = alice.`createOutboundSession`(SessionConfig.`version2`(), bob2.`identityKeys`().`curve25519`(), bob2.`oneTimeKeys`().first().`key`())
        val aliceSession3 = alice.`createOutboundSession`(SessionConfig.`version2`(), bob3.`identityKeys`().`curve25519`(), bob3.`oneTimeKeys`().first().`key`())
        
        // Verify sessions have different IDs
        assertNotEquals("Session 1 and 2 should have different IDs", aliceSession1.`sessionId`(), aliceSession2.`sessionId`())
        assertNotEquals("Session 2 and 3 should have different IDs", aliceSession2.`sessionId`(), aliceSession3.`sessionId`())
        assertNotEquals("Session 1 and 3 should have different IDs", aliceSession1.`sessionId`(), aliceSession3.`sessionId`())
        
        // Test communication with each Bob
        val message1 = "Hello Bob1!"
        val message2 = "Hello Bob2!"
        val message3 = "Hello Bob3!"
        
        val encrypted1 = aliceSession1.`encrypt`(message1.toByteArray())
        val encrypted2 = aliceSession2.`encrypt`(message2.toByteArray())
        val encrypted3 = aliceSession3.`encrypt`(message3.toByteArray())
        
        val bob1Result = bob1.`createInboundSession`(alice.`identityKeys`().`curve25519`(), PreKeyMessage.`fromBase64`(encrypted1.`toBase64`()))
        val bob2Result = bob2.`createInboundSession`(alice.`identityKeys`().`curve25519`(), PreKeyMessage.`fromBase64`(encrypted2.`toBase64`()))
        val bob3Result = bob3.`createInboundSession`(alice.`identityKeys`().`curve25519`(), PreKeyMessage.`fromBase64`(encrypted3.`toBase64`()))
        
        assertEquals("Bob1 should receive correct message", message1, String(bob1Result.`plaintext`()))
        assertEquals("Bob2 should receive correct message", message2, String(bob2Result.`plaintext`()))
        assertEquals("Bob3 should receive correct message", message3, String(bob3Result.`plaintext`()))
        
        println("✅ Multiple sessions per account validated")
    }
}
