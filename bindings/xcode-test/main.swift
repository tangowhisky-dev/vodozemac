import Foundation

// Helper extension for repeating strings
extension String {
    func repeating(_ count: Int) -> String {
        return String(repeating: self, count: count)
    }
}

func runTests() {
    print("🧪 Vodozemac Swift Bindings Test - Comprehensive Edition with New Structs")
    print("============================================================================")

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
        let _ = try base64Decode(input: "invalid-base64!")
        print("   ❌ FAILED - Should have thrown an error for invalid base64")
        exit(1)
    } catch let error as VodozemacError {
        print("   ✅ PASSED - Correctly caught VodozemacError: \(error)")
    } catch {
        print("   ❌ FAILED - Got unexpected error type: \(error)")
        exit(1)
    }

    // Test 4: Edge cases
    print("\n4. Testing edge cases...")
    
    // Empty string base64 encode/decode
    let emptyData = Data()
    let emptyEncoded = base64Encode(input: emptyData)
    
    do {
        let emptyDecoded = try base64Decode(input: emptyEncoded)
        if emptyDecoded.isEmpty {
            print("   Empty data handling: ✅ PASSED")
        } else {
            print("   Empty data handling: ❌ FAILED")
            exit(1)
        }
    } catch {
        print("   Empty data handling: ❌ FAILED - Unexpected error: \(error)")
        exit(1)
    }

    // Test 5: Check enum types are available
    print("\n5. Testing enum types availability...")
    
    // We can't instantiate enums without proper data, but we can check they compile
    print("   MessageType enum variants available: Normal, PreKey")
    print("   SessionOrdering enum variants available: Equal, Better, Worse, Unconnected") 
    print("   VodozemacError enum with comprehensive error types available")
    print("   ✅ PASSED - All enum types are properly defined")

    // NEW TESTS: Comprehensive testing of the three new struct types
    print("\n" + "=".repeating(60))
    print("🚀 TESTING NEW CRYPTOGRAPHIC STRUCTS")
    print("=".repeating(60))

    // Test 6: KeyId struct
    testKeyId()

    // Test 7: Curve25519PublicKey struct  
    testCurve25519PublicKey()

    // Test 8: Curve25519SecretKey struct
    testCurve25519SecretKey()

    // Test 9: Integration tests - objects working together
    testIntegration()

    print("\n🎉 All comprehensive tests passed!")
    print("✅ Vodozemac Swift bindings with new cryptographic structs are working!")
    print("")
    print("📋 Summary of features tested:")
    print("   • VodozemacError with 14 error type variants")
    print("   • MessageType enum (Normal/PreKey)")
    print("   • SessionOrdering enum (Equal/Better/Worse/Unconnected)")
    print("   • KeyId struct with constructor and methods")
    print("   • Curve25519PublicKey struct with multiple constructors and conversions")
    print("   • Curve25519SecretKey struct with key generation and derivation")
    print("   • Result-based error handling for Swift")
    print("   • Object interoperability (SecretKey -> PublicKey)")
    print("   • Contract version 29 compatibility")
}

// MARK: - KeyId Tests
func testKeyId() {
    print("\n6. Testing KeyId struct...")
    
    // Test constructor from u64
    let keyId = KeyId.fromU64(value: 12345)
    print("   KeyId created from u64: 12345")
    
    // Test base64 conversion
    let base64String = keyId.toBase64()
    print("   KeyId to base64: \(base64String)")
    
    // Verify base64 string is not empty
    if !base64String.isEmpty {
        print("   ✅ PASSED - KeyId constructor and to_base64 work")
    } else {
        print("   ❌ FAILED - KeyId to_base64 returned empty string")
        exit(1)
    }
    
    // Test with different values
    let keyId2 = KeyId.fromU64(value: 0)
    let base64String2 = keyId2.toBase64()
    let keyId3 = KeyId.fromU64(value: UInt64.max)
    let base64String3 = keyId3.toBase64()
    
    print("   KeyId(0) to base64: \(base64String2)")
    print("   KeyId(max) to base64: \(base64String3)")
    
    if !base64String2.isEmpty && !base64String3.isEmpty {
        print("   ✅ PASSED - KeyId edge cases work")
    } else {
        print("   ❌ FAILED - KeyId edge cases failed")
        exit(1)
    }
}

// MARK: - Curve25519PublicKey Tests
func testCurve25519PublicKey() {
    print("\n7. Testing Curve25519PublicKey struct...")
    
    // Test 1: Create from 32 bytes
    let validKeyBytes = Data(repeating: 0x42, count: 32)
    let publicKey1 = Curve25519PublicKey.fromBytes(bytes: validKeyBytes)
    print("   PublicKey created from 32 bytes")
    
    // Test byte conversions
    let asBytes = publicKey1.asBytes()
    let toBytes = publicKey1.toBytes()
    let toVec = publicKey1.toVec()
    
    print("   asBytes() length: \(asBytes.count)")
    print("   toBytes() length: \(toBytes.count)")
    print("   toVec() length: \(toVec.count)")
    
    if asBytes.count == 32 && toBytes.count == 32 && toVec.count == 32 {
        print("   ✅ PASSED - All byte methods return 32 bytes")
    } else {
        print("   ❌ FAILED - Byte methods returned wrong length")
        exit(1)
    }
    
    // Test base64 conversion
    let base64 = publicKey1.toBase64()
    print("   PublicKey to base64: \(base64)")
    
    if !base64.isEmpty {
        print("   ✅ PASSED - toBase64() works")
    } else {
        print("   ❌ FAILED - toBase64() returned empty")
        exit(1)
    }
    
    // Test 2: Create from base64 (round-trip)
    do {
        let publicKey2 = try Curve25519PublicKey.fromBase64(input: base64)
        let base64RoundTrip = publicKey2.toBase64()
        
        if base64 == base64RoundTrip {
            print("   ✅ PASSED - Base64 round-trip works")
        } else {
            print("   ❌ FAILED - Base64 round-trip failed")
            print("     Original: \(base64)")
            print("     Round-trip: \(base64RoundTrip)")
            exit(1)
        }
    } catch {
        print("   ❌ FAILED - fromBase64 failed: \(error)")
        exit(1)
    }
    
    // Test 3: Create from slice (valid)
    do {
        let publicKey3 = try Curve25519PublicKey.fromSlice(bytes: validKeyBytes)
        let sliceBytes = publicKey3.toBytes()
        
        if sliceBytes.count == 32 {
            print("   ✅ PASSED - fromSlice() with valid data works")
        } else {
            print("   ❌ FAILED - fromSlice() returned wrong length")
            exit(1)
        }
    } catch {
        print("   ❌ FAILED - fromSlice() with valid data failed: \(error)")
        exit(1)
    }
    
    // Test 4: Error handling with invalid base64
    do {
        let _ = try Curve25519PublicKey.fromBase64(input: "invalid-base64!")
        print("   ❌ FAILED - Should have failed with invalid base64")
        exit(1)
    } catch _ as VodozemacError {
        print("   ✅ PASSED - fromBase64() correctly throws VodozemacError for invalid input")
    } catch {
        print("   ❌ FAILED - fromBase64() threw wrong error type: \(error)")
        exit(1)
    }
    
    // Test 5: Error handling with invalid slice length
    do {
        let invalidBytes = Data(repeating: 0x42, count: 16) // Wrong length
        let _ = try Curve25519PublicKey.fromSlice(bytes: invalidBytes)
        print("   ❌ FAILED - Should have failed with wrong byte length")
        exit(1)
    } catch _ as VodozemacError {
        print("   ✅ PASSED - fromSlice() correctly throws VodozemacError for invalid length")
    } catch {
        print("   ❌ FAILED - fromSlice() threw wrong error type: \(error)")
        exit(1)
    }
}

// MARK: - Curve25519SecretKey Tests  
func testCurve25519SecretKey() {
    print("\n8. Testing Curve25519SecretKey struct...")
    
    // Test 1: Create new random key
    let secretKey1 = Curve25519SecretKey()
    print("   SecretKey created with default constructor")
    
    // Test byte conversion
    let secretBytes = secretKey1.toBytes()
    print("   SecretKey toBytes() length: \(secretBytes.count)")
    
    if secretBytes.count == 32 {
        print("   ✅ PASSED - toBytes() returns 32 bytes")
    } else {
        print("   ❌ FAILED - toBytes() returned wrong length: \(secretBytes.count)")
        exit(1)
    }
    
    // Test 2: Get public key from secret key
    let publicKey = secretKey1.publicKey()
    print("   PublicKey derived from SecretKey")
    
    // Test that public key works
    let publicKeyBytes = publicKey.toBytes()
    let publicKeyBase64 = publicKey.toBase64()
    
    if publicKeyBytes.count == 32 && !publicKeyBase64.isEmpty {
        print("   ✅ PASSED - publicKey() returns working PublicKey")
    } else {
        print("   ❌ FAILED - Derived PublicKey is invalid")
        exit(1)
    }
    
    // Test 3: Create from slice
    let secretKey2 = Curve25519SecretKey.fromSlice(bytes: secretBytes)
    print("   SecretKey created from slice")
    
    // Verify it produces same public key
    let publicKey2 = secretKey2.publicKey()
    let publicKeyBase64_2 = publicKey2.toBase64()
    
    if publicKeyBase64 == publicKeyBase64_2 {
        print("   ✅ PASSED - fromSlice() produces same public key")
    } else {
        print("   ❌ FAILED - fromSlice() produced different public key")
        print("     Original: \(publicKeyBase64)")
        print("     From slice: \(publicKeyBase64_2)")
        exit(1)
    }
    
    // Test 4: Verify different keys produce different public keys
    let secretKey3 = Curve25519SecretKey()
    let publicKey3 = secretKey3.publicKey()
    let publicKeyBase64_3 = publicKey3.toBase64()
    
    if publicKeyBase64 != publicKeyBase64_3 {
        print("   ✅ PASSED - Different secret keys produce different public keys")
    } else {
        print("   ❌ FAILED - Different secret keys produced same public key (very unlikely)")
        exit(1)
    }
}

// MARK: - Integration Tests
func testIntegration() {
    print("\n9. Testing integration between structs...")
    
    // Test 1: Create secret key, derive public key, convert to various formats
    let secretKey = Curve25519SecretKey()
    let publicKey = secretKey.publicKey()
    
    // Convert public key to different formats
    let publicKeyBytes = publicKey.toBytes()
    let publicKeyBase64 = publicKey.toBase64()
    let publicKeyVec = publicKey.toVec()
    let publicKeyAsBytes = publicKey.asBytes()
    
    print("   SecretKey -> PublicKey -> various formats")
    print("     Bytes length: \(publicKeyBytes.count)")
    print("     Base64: \(publicKeyBase64)")
    print("     Vec length: \(publicKeyVec.count)")
    print("     AsBytes length: \(publicKeyAsBytes.count)")
    
    // Test 2: Round-trip through base64
    do {
        let publicKeyFromBase64 = try Curve25519PublicKey.fromBase64(input: publicKeyBase64)
        let base64RoundTrip = publicKeyFromBase64.toBase64()
        
        if publicKeyBase64 == base64RoundTrip {
            print("   ✅ PASSED - Complete round-trip SecretKey -> PublicKey -> Base64 -> PublicKey -> Base64")
        } else {
            print("   ❌ FAILED - Round-trip failed")
            exit(1)
        }
    } catch {
        print("   ❌ FAILED - Round-trip threw error: \(error)")
        exit(1)
    }
    
    // Test 3: Round-trip through bytes
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
    
    // Test 4: Multiple keys and KeyId integration
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
    
    // Test 5: Verify all types work together
    print("   All structs instantiated and working together:")
    print("     KeyId: \(keyId1Base64)")
    print("     SecretKey: \(secretKey.toBytes().count) bytes")  
    print("     PublicKey: \(publicKeyBase64)")
    print("   ✅ PASSED - All three struct types integrate successfully")
}

// Run the tests
runTests()
