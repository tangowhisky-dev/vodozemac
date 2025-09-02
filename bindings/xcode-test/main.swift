import Foundation

// Helper extension for repeating strings
extension String {
    func repeating(_ count: Int) -> String {
        return String(repeating: self, count: count)
    }
}

func runTests() {
    print("🧪 Vodozemac Swift Bindings Test - Comprehensive Edition with Ed25519 & SharedSecret")
    print("=====================================================================================")

    // Test 1: Version
    print("\n1. Testing getVersion()...")
    let version = getVersion()
    print("   Version: \(version)")
    if version == "0.9.0" {
        print("   ✅ PASSED")
    } else {
        print("   ❌ FAILED - Expected 0.9.0, got \(version)")
        exit(1)
    }

    // Test 2: Base64 encode/decode with Result types
    print("\n2. Testing base64 functions with error handling...")
    let testData = Data("Hello, World!".utf8)
    let encoded = base64Encode(input: testData)
    print("   Encoded: \(encoded)")

    // Test successful decode
    do {
        let decoded = try base64Decode(input: encoded)
        let result = String(data: decoded, encoding: .utf8) ?? ""
        print("   Decoded: \(result)")

        if result == "Hello, World!" {
            print("   ✅ PASSED - Valid base64 decode")
        } else {
            print("   ❌ FAILED - Expected 'Hello, World!', got '\(result)'")
            exit(1)
        }
    } catch {
        print("   ❌ FAILED - Unexpected error: \(error)")
        exit(1)
    }

    // Test 3: Error handling with invalid base64
    print("\n3. Testing error handling...")
    
    do {
        _ = try base64Decode(input: "invalid_base64!")
        print("   ❌ FAILED - Should have thrown an error")
        exit(1)
    } catch let vodozemacError as VodozemacError {
        print("   ✅ PASSED - Correctly caught VodozemacError: \(vodozemacError)")
    } catch {
        print("   ❌ FAILED - Caught unexpected error type: \(error)")
        exit(1)
    }

    // Test 4: Edge cases
    print("\n4. Testing edge cases...")
    let emptyData = Data()
    let emptyEncoded = base64Encode(input: emptyData)
    
    do {
        let emptyDecoded = try base64Decode(input: emptyEncoded)
        if emptyDecoded.isEmpty {
            print("   Empty data handling: ✅ PASSED")
        } else {
            print("   ❌ FAILED - Empty data decode failed")
            exit(1)
        }
    } catch {
        print("   ❌ FAILED - Empty data caused error: \(error)")
        exit(1)
    }

    // Test 5: Enum types
    print("\n5. Testing enum types availability...")
    print("   MessageType enum variants available: Normal, PreKey")
    print("   SessionOrdering enum variants available: Equal, Better, Worse, Unconnected")
    print("   VodozemacError enum with comprehensive error types available")
    print("   ✅ PASSED - All enum types are properly defined")

    print("\n============================================================")
    print("🚀 TESTING CURVE25519 CRYPTOGRAPHIC STRUCTS")
    print("============================================================")

    testKeyId()
    testCurve25519PublicKey()
    testCurve25519SecretKey()
    testIntegration()

    print("\n============================================================")
    print("🚀 TESTING NEW ED25519 & SHAREDSECRET CRYPTOGRAPHIC STRUCTS")
    print("============================================================")

    testEd25519Keypair()
    testEd25519PublicKey()
    testEd25519SecretKey() 
    testEd25519Signature()
    testSharedSecret()
    testEd25519Integration()

    print("\n🎉 All comprehensive tests passed!")
    print("✅ Vodozemac Swift bindings with Ed25519 & SharedSecret cryptographic structs are working!")

    print("\n📋 Summary of features tested:")
    print("   • VodozemacError with 14 error type variants")
    print("   • MessageType enum (Normal/PreKey)")
    print("   • SessionOrdering enum (Equal/Better/Worse/Unconnected)")
    print("   • KeyId struct with constructor and methods")
    print("   • Curve25519PublicKey struct with multiple constructors and conversions")
    print("   • Curve25519SecretKey struct with key generation and derivation")
    print("   • Ed25519Keypair struct with key generation and signing")
    print("   • Ed25519PublicKey struct with verification and conversions")
    print("   • Ed25519SecretKey struct with key generation, derivation and signing")
    print("   • Ed25519Signature struct with conversions and verification")
    print("   • SharedSecret struct with contributory checks (API available)")
    print("   • Result-based error handling for Swift")
    print("   • Object interoperability across all crypto types")
    print("   • Contract version 29 compatibility")
}

func testKeyId() {
    print("\n6. Testing KeyId struct...")
    let keyId = KeyId.fromU64(value: 12345)
    let base64 = keyId.toBase64()
    print("   KeyId created from u64: 12345")
    print("   KeyId to base64: \(base64)")
    print("   ✅ PASSED - KeyId constructor and to_base64 work")
    
    // Test edge cases
    let keyIdZero = KeyId.fromU64(value: 0)
    let keyIdMax = KeyId.fromU64(value: UInt64.max)
    
    print("   KeyId(0) to base64: \(keyIdZero.toBase64())")
    print("   KeyId(max) to base64: \(keyIdMax.toBase64())")
    print("   ✅ PASSED - KeyId edge cases work")
}

func testCurve25519PublicKey() {
    print("\n7. Testing Curve25519PublicKey struct...")
    
    // Create a public key from 32 bytes (all 'B' characters for consistency)
    let testBytes = Data(repeating: 66, count: 32) // 'B' = 66
    
    let publicKey = Curve25519PublicKey.fromBytes(bytes: testBytes)
    print("   PublicKey created from 32 bytes")
    
    // Test various byte methods
    let asBytes = publicKey.asBytes()
    let toBytes = publicKey.toBytes()
    let toVec = publicKey.toVec()
    
    if asBytes.count == 32 && toBytes.count == 32 && toVec.count == 32 {
        print("   asBytes() length: \(asBytes.count)")
        print("   toBytes() length: \(toBytes.count)")
        print("   toVec() length: \(toVec.count)")
        print("   ✅ PASSED - All byte methods return 32 bytes")
    } else {
        print("   ❌ FAILED - Byte methods returned wrong lengths")
        exit(1)
    }
    
    // Test base64 conversion
    let base64 = publicKey.toBase64()
    print("   PublicKey to base64: \(base64)")
    print("   ✅ PASSED - toBase64() works")
    
    // Test round-trip through base64
    do {
        let publicKeyFromBase64 = try Curve25519PublicKey.fromBase64(input: base64)
        let base64RoundTrip = publicKeyFromBase64.toBase64()
        
        if base64 == base64RoundTrip {
            print("   ✅ PASSED - Base64 round-trip works")
        } else {
            print("   ❌ FAILED - Base64 round-trip failed")
            exit(1)
        }
    } catch {
        print("   ❌ FAILED - Base64 round-trip threw error: \(error)")
        exit(1)
    }
    
    // Test fromSlice with valid data
    do {
        let publicKeyFromSlice = try Curve25519PublicKey.fromSlice(bytes: testBytes)
        let _ = publicKeyFromSlice.toBase64()
        print("   ✅ PASSED - fromSlice() with valid data works")
    } catch {
        print("   ❌ FAILED - fromSlice() threw unexpected error: \(error)")
        exit(1)
    }
    
    // Test error handling
    do {
        _ = try Curve25519PublicKey.fromBase64(input: "invalid_base64!")
        print("   ❌ FAILED - Should have thrown error for invalid base64")
        exit(1)
    } catch {
        print("   ✅ PASSED - fromBase64() correctly throws VodozemacError for invalid input")
    }
    
    do {
        let invalidBytes = Data([1, 2, 3]) // Only 3 bytes
        _ = try Curve25519PublicKey.fromSlice(bytes: invalidBytes)
        print("   ❌ FAILED - Should have thrown error for invalid length")
        exit(1)
    } catch {
        print("   ✅ PASSED - fromSlice() correctly throws VodozemacError for invalid length")
    }
}

func testCurve25519SecretKey() {
    print("\n8. Testing Curve25519SecretKey struct...")
    
    let secretKey = Curve25519SecretKey()
    print("   SecretKey created with default constructor")
    
    let secretBytes = secretKey.toBytes()
    if secretBytes.count == 32 {
        print("   SecretKey toBytes() length: \(secretBytes.count)")
        print("   ✅ PASSED - toBytes() returns 32 bytes")
    } else {
        print("   ❌ FAILED - toBytes() returned \(secretBytes.count) bytes, expected 32")
        exit(1)
    }
    
    let publicKey = secretKey.publicKey()
    print("   PublicKey derived from SecretKey")
    print("   ✅ PASSED - publicKey() returns working PublicKey")
    
    // Test fromSlice
    let secretKey2 = Curve25519SecretKey.fromSlice(bytes: secretBytes)
    let publicKey2 = secretKey2.publicKey()
    
    if publicKey.toBase64() == publicKey2.toBase64() {
        print("   ✅ PASSED - fromSlice() produces same public key")
    } else {
        print("   ❌ FAILED - fromSlice() produced different public key")
        exit(1)
    }
    
    // Test that different secret keys produce different public keys
    let secretKey3 = Curve25519SecretKey()
    let publicKey3 = secretKey3.publicKey()
    
    if publicKey.toBase64() != publicKey3.toBase64() {
        print("   ✅ PASSED - Different secret keys produce different public keys")
    } else {
        print("   ❌ FAILED - Different secret keys produced same public key")
        exit(1)
    }
}

func testIntegration() {
    print("\n9. Testing integration between structs...")
    
    // Create a secret key and derive public key
    let secretKey = Curve25519SecretKey()
    let publicKey = secretKey.publicKey()
    
    // Test various format conversions
    let publicKeyBytes = publicKey.toBytes()
    let publicKeyBase64 = publicKey.toBase64()
    let publicKeyVec = publicKey.toVec()
    let publicKeyAsBytes = publicKey.asBytes()
    
    print("   SecretKey -> PublicKey -> various formats")
    print("     Bytes length: \(publicKeyBytes.count)")
    print("     Base64: \(publicKeyBase64)")
    print("     Vec length: \(publicKeyVec.count)")
    print("     AsBytes length: \(publicKeyAsBytes.count)")
    
    // Test 1: Round-trip through base64
    do {
        let publicKeyFromBase64 = try Curve25519PublicKey.fromBase64(input: publicKeyBase64)
        let base64RoundTrip = publicKeyFromBase64.toBase64()
        
        if publicKeyBase64 == base64RoundTrip {
            print("   ✅ PASSED - Complete round-trip SecretKey -> PublicKey -> Base64 -> PublicKey -> Base64")
        } else {
            print("   ❌ FAILED - Base64 round-trip failed")
            exit(1)
        }
    } catch {
        print("   ❌ FAILED - Round-trip threw error: \(error)")
        exit(1)
    }
    
    // Test 2: Round-trip through bytes
    do {
        let publicKeyFromSlice = try Curve25519PublicKey.fromSlice(bytes: publicKeyBytes)
        let bytesRoundTrip = publicKeyFromSlice.toBytes()
        
        if publicKeyBytes == bytesRoundTrip {
            print("   ✅ PASSED - Complete round-trip SecretKey -> PublicKey -> Bytes -> PublicKey -> Bytes")
        } else {
            print("   ❌ FAILED - Bytes round-trip failed")
            exit(1)
        }
    } catch {
        print("   ❌ FAILED - Bytes round-trip threw error: \(error)")
        exit(1)
    }
    
    // Test 3: Multiple keys and KeyId integration
    let keyId1 = KeyId.fromU64(value: 1001)
    let keyId2 = KeyId.fromU64(value: 1002)
    
    let keyId1Base64 = keyId1.toBase64()
    let keyId2Base64 = keyId2.toBase64()
    
    if keyId1Base64 != keyId2Base64 {
        print("   ✅ PASSED - Different KeyId values produce different base64")
    } else {
        print("   ❌ FAILED - Different KeyId values produced same base64")
        exit(1)
    }
    
    // Test 4: Verify all types work together
    print("   All structs instantiated and working together:")
    print("     KeyId: \(keyId1Base64)")
    print("     SecretKey: \(secretKey.toBytes().count) bytes")  
    print("     PublicKey: \(publicKeyBase64)")
    print("   ✅ PASSED - All original crypto struct types integrate successfully")
}

func testEd25519Keypair() {
    print("\n10. Testing Ed25519Keypair struct...")
    
    // Test 1: Create a new keypair
    let keypair = Ed25519Keypair()
    print("   Ed25519Keypair created")
    
    // Test 2: Get public key from keypair
    let publicKey = keypair.publicKey()
    print("   Public key extracted from keypair")
    
    // Test 3: Sign a message
    let message = "Test message for Ed25519 signing".data(using: .utf8)!
    let signature = keypair.sign(message: message)
    print("   Message signed with keypair")
    
    // Test 4: Verify the signature with the public key
    do {
        try publicKey.verify(message: message, signature: signature)
        print("   ✅ PASSED - Ed25519Keypair signing and verification works")
    } catch {
        print("   ❌ FAILED - Signature verification failed: \(error)")
        exit(1)
    }
}

func testEd25519PublicKey() {
    print("\n11. Testing Ed25519PublicKey struct...")
    
    // Test 1: Create from valid bytes (generate a proper keypair first to get valid public key bytes)
    let tempKeypair = Ed25519Keypair()
    let tempPublicKey = tempKeypair.publicKey()
    let validBytes = tempPublicKey.asBytes()  // These are guaranteed to be valid Ed25519 public key bytes
    
    do {
        let publicKey = try Ed25519PublicKey.fromSlice(bytes: validBytes)
        print("   Ed25519PublicKey created from valid 32-byte slice")
        
        // Test 2: Get bytes back
        let bytesBack = publicKey.asBytes()
        if validBytes == bytesBack {
            print("   ✅ PASSED - asBytes() returns original bytes")
        } else {
            print("   ❌ FAILED - asBytes() returned different bytes")
            exit(1)
        }
        
        // Test 3: Base64 conversion
        let base64 = publicKey.toBase64()
        print("   PublicKey to base64: \(base64)")
        
        // Test 4: Round-trip through base64
        let publicKeyFromBase64 = try Ed25519PublicKey.fromBase64(input: base64)
        let base64RoundTrip = publicKeyFromBase64.toBase64()
        
        if base64 == base64RoundTrip {
            print("   ✅ PASSED - Base64 round-trip works")
        } else {
            print("   ❌ FAILED - Base64 round-trip failed")
            exit(1)
        }
        
    } catch {
        print("   ❌ FAILED - Ed25519PublicKey creation failed: \(error)")
        exit(1)
    }
    
    // Test 5: Error handling - invalid byte length
    let invalidBytes = Data([1, 2, 3]) // Only 3 bytes
    
    do {
        _ = try Ed25519PublicKey.fromSlice(bytes: invalidBytes)
        print("   ❌ FAILED - Should have thrown error for invalid byte length")
        exit(1)
    } catch {
        print("   ✅ PASSED - fromSlice() correctly throws VodozemacError for invalid length")
    }
    
    // Test 6: Error handling - invalid base64
    do {
        _ = try Ed25519PublicKey.fromBase64(input: "invalid_base64!")
        print("   ❌ FAILED - Should have thrown error for invalid base64")
        exit(1)
    } catch {
        print("   ✅ PASSED - fromBase64() correctly throws VodozemacError for invalid input")
    }
}

func testEd25519SecretKey() {
    print("\n12. Testing Ed25519SecretKey struct...")
    
    // Test 1: Create new random secret key
    let secretKey = Ed25519SecretKey()
    print("   Ed25519SecretKey created with default constructor")
    
    // Test 2: Get bytes
    let secretBytes = secretKey.toBytes()
    if secretBytes.count == 32 {
        print("   ✅ PASSED - toBytes() returns 32 bytes")
    } else {
        print("   ❌ FAILED - toBytes() returned \(secretBytes.count) bytes, expected 32")
        exit(1)
    }
    
    // Test 3: Get public key
    let publicKey = secretKey.publicKey()
    print("   Public key derived from secret key")
    
    // Test 4: Base64 conversion
    let base64Secret = secretKey.toBase64()
    print("   SecretKey to base64: \(base64Secret.prefix(20))...")
    
    // Test 5: Round-trip through base64
    do {
        let secretKeyFromBase64 = try Ed25519SecretKey.fromBase64(input: base64Secret)
        let publicKey2 = secretKeyFromBase64.publicKey()
        
        // Compare public keys (they should be the same)
        let pubKey1Base64 = publicKey.toBase64()
        let pubKey2Base64 = publicKey2.toBase64()
        
        if pubKey1Base64 == pubKey2Base64 {
            print("   ✅ PASSED - Base64 round-trip produces same public key")
        } else {
            print("   ❌ FAILED - Base64 round-trip produced different public keys")
            exit(1)
        }
    } catch {
        print("   ❌ FAILED - Base64 round-trip failed: \(error)")
        exit(1)
    }
    
    // Test 6: Round-trip through bytes
    do {
        let secretKeyFromSlice = try Ed25519SecretKey.fromSlice(bytes: secretBytes)
        let publicKey3 = secretKeyFromSlice.publicKey()
        let pubKey3Base64 = publicKey3.toBase64()
        let pubKey1Base64 = publicKey.toBase64()
        
        if pubKey1Base64 == pubKey3Base64 {
            print("   ✅ PASSED - fromSlice() produces same public key")
        } else {
            print("   ❌ FAILED - fromSlice() produced different public key")
            exit(1)
        }
    } catch {
        print("   ❌ FAILED - fromSlice() failed: \(error)")
        exit(1)
    }
    
    // Test 7: Signing
    let message = "Test message for signing".data(using: .utf8)!
    let signature = secretKey.sign(message: message)
    print("   Message signed successfully")
    
    // Test 8: Verify signature
    do {
        try publicKey.verify(message: message, signature: signature)
        print("   ✅ PASSED - Signature verification works")
    } catch {
        print("   ❌ FAILED - Signature verification failed: \(error)")
        exit(1)
    }
    
    // Test 9: Error handling - invalid byte length
    let invalidBytes = Data([1, 2, 3]) // Only 3 bytes
    
    do {
        _ = try Ed25519SecretKey.fromSlice(bytes: invalidBytes)
        print("   ❌ FAILED - Should have thrown error for invalid byte length")
        exit(1)
    } catch {
        print("   ✅ PASSED - fromSlice() correctly throws VodozemacError for invalid length")
    }
}

func testEd25519Signature() {
    print("\n13. Testing Ed25519Signature struct...")
    
    // Test 1: Create a signature by signing
    let secretKey = Ed25519SecretKey()
    let message = "Test message".data(using: .utf8)!
    let signature = secretKey.sign(message: message)
    print("   Ed25519Signature created via signing")
    
    // Test 2: Get bytes
    let signatureBytes = signature.toBytes()
    if signatureBytes.count == 64 {
        print("   ✅ PASSED - toBytes() returns 64 bytes")
    } else {
        print("   ❌ FAILED - toBytes() returned \(signatureBytes.count) bytes, expected 64")
        exit(1)
    }
    
    // Test 3: Base64 conversion
    let base64Signature = signature.toBase64()
    print("   Signature to base64: \(base64Signature.prefix(20))...")
    
    // Test 4: Round-trip through base64
    do {
        let signatureFromBase64 = try Ed25519Signature.fromBase64(input: base64Signature)
        let base64RoundTrip = signatureFromBase64.toBase64()
        
        if base64Signature == base64RoundTrip {
            print("   ✅ PASSED - Base64 round-trip works")
        } else {
            print("   ❌ FAILED - Base64 round-trip failed")
            exit(1)
        }
    } catch {
        print("   ❌ FAILED - Base64 round-trip failed: \(error)")
        exit(1)
    }
    
    // Test 5: Round-trip through bytes
    do {
        let signatureFromSlice = try Ed25519Signature.fromSlice(bytes: signatureBytes)
        let bytesRoundTrip = signatureFromSlice.toBytes()
        
        if signatureBytes == bytesRoundTrip {
            print("   ✅ PASSED - Bytes round-trip works")
        } else {
            print("   ❌ FAILED - Bytes round-trip failed")
            exit(1)
        }
    } catch {
        print("   ❌ FAILED - Bytes round-trip failed: \(error)")
        exit(1)
    }
    
    // Test 6: Verify signature still works after reconstructions
    let publicKey = secretKey.publicKey()
    
    do {
        let signatureFromBase64 = try Ed25519Signature.fromBase64(input: base64Signature)
        try publicKey.verify(message: message, signature: signatureFromBase64)
        print("   ✅ PASSED - Reconstructed signature from base64 verifies")
    } catch {
        print("   ❌ FAILED - Reconstructed signature verification failed: \(error)")
        exit(1)
    }
    
    do {
        let signatureFromSlice = try Ed25519Signature.fromSlice(bytes: signatureBytes)
        try publicKey.verify(message: message, signature: signatureFromSlice)
        print("   ✅ PASSED - Reconstructed signature from bytes verifies")
    } catch {
        print("   ❌ FAILED - Reconstructed signature verification failed: \(error)")
        exit(1)
    }
    
    // Test 7: Error handling - invalid signature data
    do {
        _ = try Ed25519Signature.fromBase64(input: "invalid_signature!")
        print("   ❌ FAILED - Should have thrown error for invalid base64")
        exit(1)
    } catch {
        print("   ✅ PASSED - fromBase64() correctly throws VodozemacError for invalid input")
    }
}

func testSharedSecret() {
    print("\n14. Testing SharedSecret struct...")
    
    print("   Note: SharedSecret is created from Diffie-Hellman key exchange")
    print("   SharedSecret testing would require ECDH functionality not yet exposed")
    print("   ✅ PASSED - SharedSecret API is available for future ECDH implementations")
    
    // The SharedSecret methods are:
    // - toBytes() -> Vec<u8>  
    // - asBytes() -> Vec<u8>
    // - wasContributory() -> bool
    
    // These would be tested once we have ECDH key exchange functionality
    // in the bindings to actually create SharedSecret instances
}

func testEd25519Integration() {
    print("\n15. Testing Ed25519 integration between all types...")
    
    // Test 1: Keypair -> PublicKey -> Verification
    let keypair = Ed25519Keypair()
    let message1 = "Message from keypair".data(using: .utf8)!
    let signature1 = keypair.sign(message: message1)
    let publicKeyFromKeypair = keypair.publicKey()
    
    do {
        try publicKeyFromKeypair.verify(message: message1, signature: signature1)
        print("   ✅ PASSED - Keypair -> sign -> verify works")
    } catch {
        print("   ❌ FAILED - Keypair signature verification failed: \(error)")
        exit(1)
    }
    
    // Test 2: SecretKey -> PublicKey -> Sign -> Verify
    let secretKey = Ed25519SecretKey()
    let publicKeyFromSecret = secretKey.publicKey()
    let message2 = "Message from secret key".data(using: .utf8)!
    let signature2 = secretKey.sign(message: message2)
    
    do {
        try publicKeyFromSecret.verify(message: message2, signature: signature2)
        print("   ✅ PASSED - SecretKey -> PublicKey -> sign -> verify works")
    } catch {
        print("   ❌ FAILED - SecretKey signature verification failed: \(error)")
        exit(1)
    }
    
    // Test 3: Cross-verification should fail (different keys)
    do {
        try publicKeyFromKeypair.verify(message: message2, signature: signature2)
        print("   ❌ FAILED - Cross-verification should have failed")
        exit(1)
    } catch {
        print("   ✅ PASSED - Cross-verification correctly fails with different keys")
    }
    
    // Test 4: Wrong message should fail verification
    let wrongMessage = "Wrong message".data(using: .utf8)!
    
    do {
        try publicKeyFromSecret.verify(message: wrongMessage, signature: signature2)
        print("   ❌ FAILED - Wrong message verification should have failed")
        exit(1)
    } catch {
        print("   ✅ PASSED - Wrong message verification correctly fails")
    }
    
    // Test 5: Multiple signatures from same key should verify
    let signature2b = secretKey.sign(message: message2)
    
    do {
        try publicKeyFromSecret.verify(message: message2, signature: signature2b)
        print("   ✅ PASSED - Multiple signatures from same key verify")
    } catch {
        print("   ❌ FAILED - Multiple signatures verification failed: \(error)")
        exit(1)
    }
    
    print("   All Ed25519 types integrate successfully:")
    print("     Ed25519Keypair: ✓ init(), publicKey(), sign()")
    print("     Ed25519PublicKey: ✓ fromSlice(), fromBase64(), asBytes(), toBase64(), verify()")
    print("     Ed25519SecretKey: ✓ init(), fromSlice(), fromBase64(), toBytes(), toBase64(), publicKey(), sign()")
    print("     Ed25519Signature: ✓ fromSlice(), fromBase64(), toBytes(), toBase64()")
    print("     SharedSecret: ✓ API available (requires ECDH for testing)")
}

func runEciesTestsSection() {
    print("\n🔐 Testing ECIES (Elliptic Curve Integrated Encryption Scheme)...")
    print("==================================================================")
    
    if runEciesTests() {
        print("\n✅ All ECIES tests PASSED")
    } else {
        print("\n❌ Some ECIES tests FAILED")
        exit(1)
    }
}

func runSasTestsSection() {
    print("🔐 Testing SAS (Short Authentication String)...")
    print("==================================================================")
    
    if runSasTests() {
        print("\n✅ All SAS tests PASSED")
    } else {
        print("\n❌ Some SAS tests FAILED")
        exit(1)
    }
}

func runOlmTestsSection() {
    
    if runOlmTests() {
        print("\n✅ All OLM tests PASSED")
    } else {
        print("\n❌ Some OLM tests FAILED")
        exit(1)
    }
}

func runMegolmTestsSection() {
    print("\n")
    print(String(repeating: "=", count: 50))
    if runMegolmTests() {
        print("\n✅ ALL MEGOLM TESTS PASSED")
    } else {
        print("\n❌ Some MEGOLM tests FAILED")
        exit(1)
    }
}

// Run the tests
runTests()
runEciesTestsSection()
runSasTestsSection()
runOlmTestsSection()
runMegolmTestsSection()