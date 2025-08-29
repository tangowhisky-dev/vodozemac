package org.matrix.vodozemac.test

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName
import kotlinx.serialization.json.Json
import org.junit.Test
import org.junit.Assert.*
import org.junit.Before
import java.io.File
import vodozemac.*

@Serializable
data class TestVectors(
    @SerialName("account_tests") val accountTests: List<AccountTest>,
    @SerialName("session_tests") val sessionTests: List<SessionTest>,
    @SerialName("group_session_tests") val groupSessionTests: List<GroupSessionTest>,
    @SerialName("sas_tests") val sasTests: List<SasTest>,
    @SerialName("ecies_tests") val eciesTests: List<EciesTest>,
    @SerialName("utility_tests") val utilityTests: UtilityTests
)

@Serializable
data class AccountTest(
    val name: String,
    @SerialName("pickle_passphrase") val picklePassphrase: String,
    @SerialName("pickled_account") val pickledAccount: String,
    @SerialName("identity_keys") val identityKeys: IdentityKeysData,
    @SerialName("one_time_keys_count") val oneTimeKeysCount: UInt,
    @SerialName("one_time_keys") val oneTimeKeys: Map<String, String>,
    @SerialName("fallback_key") val fallbackKey: Map<String, String>,
    @SerialName("signature_message") val signatureMessage: String,
    val signature: String
)

@Serializable
data class IdentityKeysData(
    val curve25519: String,
    val ed25519: String
)

@Serializable
data class SessionTest(
    val name: String,
    @SerialName("alice_account") val aliceAccount: String,
    @SerialName("bob_account") val bobAccount: String,
    @SerialName("pickle_passphrase") val picklePassphrase: String,
    @SerialName("session_id") val sessionId: String,
    @SerialName("pickled_session") val pickledSession: String,
    val plaintext: String,
    @SerialName("encrypted_message") val encryptedMessage: String,
    @SerialName("decrypted_message") val decryptedMessage: String
)

@Serializable
data class GroupSessionTest(
    val name: String,
    @SerialName("pickle_passphrase") val picklePassphrase: String,
    @SerialName("pickled_outbound") val pickledOutbound: String,
    @SerialName("pickled_inbound") val pickledInbound: String,
    @SerialName("session_id") val sessionId: String,
    @SerialName("session_key") val sessionKey: String,
    @SerialName("message_index") val messageIndex: UInt,
    val plaintext: String,
    @SerialName("encrypted_message") val encryptedMessage: String,
    @SerialName("decrypted_message") val decryptedMessage: String,
    @SerialName("decrypted_index") val decryptedIndex: UInt
)

@Serializable
data class SasTest(
    val name: String,
    @SerialName("alice_public_key") val alicePublicKey: String,
    @SerialName("bob_public_key") val bobPublicKey: String,
    @SerialName("shared_secret") val sharedSecret: String,
    val info: String,
    @SerialName("sas_bytes") val sasBytes: String,
    @SerialName("emoji_indices") val emojiIndices: List<UInt>,
    val decimals: List<UShort>,
    @SerialName("mac_info") val macInfo: String,
    @SerialName("mac_message") val macMessage: String,
    @SerialName("calculated_mac") val calculatedMac: String
)

@Serializable
data class EciesTest(
    val name: String,
    @SerialName("alice_public_key") val alicePublicKey: String,
    @SerialName("bob_public_key") val bobPublicKey: String,
    val plaintext: String,
    @SerialName("encrypted_message") val encryptedMessage: String,
    @SerialName("decrypted_message") val decryptedMessage: String,
    @SerialName("check_code") val checkCode: String
)

@Serializable
data class UtilityTests(
    @SerialName("base64_encode_tests") val base64EncodeTests: List<Base64Test>,
    @SerialName("base64_decode_tests") val base64DecodeTests: List<Base64Test>,
    val version: String
)

@Serializable
data class Base64Test(
    val input: String,
    val output: String
)

class VodozemacTest {
    
    private lateinit var testVectors: TestVectors
    
    @Before
    fun setUp() {
        val testVectorsJson = this::class.java.classLoader.getResource("test_vectors.json")
            ?.readText() ?: throw IllegalStateException("Could not find test_vectors.json")
        
        testVectors = Json.decodeFromString(testVectorsJson)
    }
    
    @Test
    fun testAccountOperations() {
        testVectors.accountTests.forEach { accountTest ->
            // Test account unpickling
            val account = AccountWrapper.fromPickle(
                pickle = accountTest.pickledAccount,
                passphrase = accountTest.picklePassphrase
            )
            
            // Test identity keys
            val identityKeys = account.identityKeys()
            assertArrayEquals(
                identityKeys.curve25519.toByteArray(),
                base64Decode(accountTest.identityKeys.curve25519).toByteArray()
            )
            assertArrayEquals(
                identityKeys.ed25519.toByteArray(),
                base64Decode(accountTest.identityKeys.ed25519).toByteArray()
            )
            
            // Test signing
            val signature = account.sign(accountTest.signatureMessage)
            assertArrayEquals(
                signature.signature.toByteArray(),
                base64Decode(accountTest.signature).toByteArray()
            )
            
            // Test pickling
            val repickled = account.pickle(accountTest.picklePassphrase)
            assertEquals(repickled, accountTest.pickledAccount)
        }
    }
    
    @Test
    fun testSessionOperations() {
        testVectors.sessionTests.forEach { sessionTest ->
            // Test session unpickling
            val session = SessionWrapper.fromPickle(
                pickle = sessionTest.pickledSession,
                passphrase = sessionTest.picklePassphrase
            )
            
            // Test session ID
            assertEquals(session.sessionId(), sessionTest.sessionId)
            
            // Test message matching
            val matches = session.sessionMatches(sessionTest.encryptedMessage)
            assertTrue(matches)
            
            // Test decryption
            val decrypted = session.decrypt(sessionTest.encryptedMessage)
            assertEquals(decrypted, sessionTest.decryptedMessage)
            
            // Test pickling
            val repickled = session.pickle(sessionTest.picklePassphrase)
            assertEquals(repickled, sessionTest.pickledSession)
        }
    }
    
    @Test
    fun testGroupSessionOperations() {
        testVectors.groupSessionTests.forEach { groupTest ->
            // Test outbound session
            val outbound = GroupSessionWrapper.fromPickle(
                pickle = groupTest.pickledOutbound,
                passphrase = groupTest.picklePassphrase
            )
            
            assertEquals(outbound.sessionId(), groupTest.sessionId)
            assertEquals(outbound.sessionKey().key, groupTest.sessionKey)
            
            // Test inbound session
            val inbound = InboundGroupSessionWrapper.fromPickle(
                pickle = groupTest.pickledInbound,
                passphrase = groupTest.picklePassphrase
            )
            
            assertEquals(inbound.sessionId(), groupTest.sessionId)
            
            // Test decryption
            val result = inbound.decrypt(groupTest.encryptedMessage)
            assertEquals(result.plaintext, groupTest.decryptedMessage)
            assertEquals(result.messageIndex, groupTest.decryptedIndex)
        }
    }
    
    @Test
    fun testSasOperations() {
        testVectors.sasTests.forEach { sasTest ->
            // Create SAS instances
            val sas = SasWrapper()
            
            // Test public key format
            val publicKey = sas.publicKey()
            assertEquals(publicKey.key.size, 32)
            
            // For reference test, we can't recreate the exact same SAS
            // but we can test the API works correctly
            val otherSas = SasWrapper()
            val established = sas.diffieHellman(otherSas.publicKey())
            
            // Test bytes generation
            val sasBytes = established.bytes(sasTest.info)
            assertEquals(sasBytes.bytes.size, 32)
            
            // Test emoji and decimal generation
            val emojiIndices = established.generateBytesEmoji(sasBytes)
            assertEquals(emojiIndices.size, 7)
            
            val decimals = established.generateBytesDecimal(sasBytes)
            assertEquals(decimals.size, 3)
            
            // Test MAC calculation
            val mac = established.calculateMac(sasTest.macMessage, sasTest.macInfo)
            assertTrue(mac.mac.isNotEmpty())
        }
    }
    
    @Test
    fun testEciesOperations() {
        testVectors.eciesTests.forEach { eciesTest ->
            // Create ECIES instances
            val alice = EciesWrapper()
            val bob = EciesWrapper()
            
            // Test public key format
            val alicePublicKey = alice.publicKey()
            val bobPublicKey = bob.publicKey()
            assertEquals(alicePublicKey.key.size, 32)
            assertEquals(bobPublicKey.key.size, 32)
            
            // Establish channels
            val aliceEstablished = alice.diffieHellman(bobPublicKey)
            val bobEstablished = bob.diffieHellman(alicePublicKey)
            
            // Test encryption/decryption
            val encrypted = aliceEstablished.encrypt(eciesTest.plaintext)
            val decrypted = bobEstablished.decrypt(encrypted)
            assertEquals(decrypted, eciesTest.plaintext)
            
            // Test check code
            val checkCode = aliceEstablished.checkCode()
            assertEquals(checkCode.checkCode.size, 32)
        }
    }
    
    @Test
    fun testUtilityFunctions() {
        val utilityTests = testVectors.utilityTests
        
        // Test version
        assertEquals(version(), utilityTests.version)
        
        // Test base64 encoding
        utilityTests.base64EncodeTests.forEach { test ->
            val encoded = base64Encode(test.input.toByteArray().toList())
            assertEquals(encoded, test.output)
        }
        
        // Test base64 decoding
        utilityTests.base64DecodeTests.forEach { test ->
            val decoded = base64Decode(test.input)
            val decodedString = String(decoded.toByteArray())
            assertEquals(decodedString, test.output)
        }
    }
    
    @Test
    fun testErrorHandling() {
        // Test invalid pickle
        try {
            AccountWrapper.fromPickle("invalid", "test")
            fail("Should have thrown exception")
        } catch (e: Exception) {
            // Expected
        }
        
        // Test invalid base64
        try {
            base64Decode("invalid base64!")
            fail("Should have thrown exception")
        } catch (e: Exception) {
            // Expected
        }
        
        // Test invalid message decryption
        val account = AccountWrapper()
        val session = account.createOutboundSession(
            identityKey = Curve25519PublicKeyWrapper(ByteArray(32).toList()),
            oneTimeKey = Curve25519PublicKeyWrapper(ByteArray(32) { 1 }.toList())
        )
        
        try {
            session.decrypt("invalid_message")
            fail("Should have thrown exception")
        } catch (e: Exception) {
            // Expected
        }
    }
}
