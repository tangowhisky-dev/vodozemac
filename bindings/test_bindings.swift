#!/usr/bin/env swift

// Simple Swift test program to verify vodozemac bindings work
// Run this with: swift test_bindings.swift

import Foundation
// Import generated bindings - update this path as needed
// The actual module name will depend on how you've structured your project

// For testing with generated files directly:
// swift -I generated -L ../target/debug -lvodozemac_bindings test_bindings.swift

// Load the generated Swift bindings
// In a real project, you would import this as a module

// For this test, we need to compile and link against the library
// Usage: swift -I generated -L ../target/debug -lvodozemac_bindings test_bindings.swift
func testVodozemacBindings() {
    print("🔬 Testing Vodozemac Swift Bindings")
    print("==================================")
    
    // Test 1: Version check
    print("\\n1️⃣ Testing getVersion()...")
    let version = getVersion()
    print("   ✅ Vodozemac version: \\(version)")
    assert(!version.isEmpty, "Version should not be empty")
    assert(version == "0.9.0", "Version should be 0.9.0")
    
    // Test 2: Base64 encoding
    print("\\n2️⃣ Testing base64Encode()...")
    let testString = "Hello, Matrix World! 🚀"
    let testData = Array(testString.utf8)
    let encoded = base64Encode(input: testData)
    print("   Original: \\(testString)")
    print("   Encoded:  \\(encoded)")
    assert(!encoded.isEmpty, "Encoded string should not be empty")
    
    // Test 3: Base64 decoding
    print("\\n3️⃣ Testing base64Decode()...")
    let decoded = base64Decode(input: encoded)
    let decodedString = String(bytes: decoded, encoding: .utf8)!
    print("   Decoded:  \\(decodedString)")
    assert(decodedString == testString, "Decoded string should match original")
    
    // Test 4: Round-trip with known values
    print("\\n4️⃣ Testing known base64 values...")
    let knownInput = "SGVsbG8sIFdvcmxkIQ=="  // "Hello, World!" in base64
    let knownDecoded = base64Decode(input: knownInput)
    let knownString = String(bytes: knownDecoded, encoding: .utf8)!
    print("   Known base64: \\(knownInput)")
    print("   Decoded to:   \\(knownString)")
    assert(knownString == "Hello, World!", "Known base64 should decode correctly")
    
    // Test 5: Error handling
    print("\\n5️⃣ Testing error handling...")
    let invalidBase64 = "invalid!@#$%^&*()"
    let invalidDecoded = base64Decode(input: invalidBase64)
    print("   Invalid input:  \\(invalidBase64)")
    print("   Result length:  \\(invalidDecoded.count)")
    assert(invalidDecoded.isEmpty, "Invalid base64 should result in empty array")
    
    print("\\n🎉 All tests passed! Vodozemac Swift bindings are working correctly.")
    
    // Test new cryptographic types
    testCryptographicTypes()
    
    print("\\n📚 Integration Guide: See docs/XcodeIntegrationGuide.md")
    print("🔧 To use in your project: Copy generated/ files to your Xcode project")
}

func testCryptographicTypes() {
    print("\\n🔐 Testing Cryptographic Types")
    print("==============================")
    
    // Test 6: Curve25519SecretKey
    print("\\n6️⃣ Testing Curve25519SecretKey...")
    let secretKey = Curve25519SecretKey()
    let secretBytes = secretKey.toBytes()
    print("   ✅ Created secret key with \\(secretBytes.count) bytes")
    assert(secretBytes.count == 32, "Secret key should be 32 bytes")
    
    // Test 7: Curve25519SecretKey from bytes
    print("\\n7️⃣ Testing Curve25519SecretKey from bytes...")
    let testSecretBytes = Data(repeating: 42, count: 32)
    let secretFromBytes = Curve25519SecretKey.fromSlice(bytes: testSecretBytes)
    let recoveredBytes = secretFromBytes.toBytes()
    print("   ✅ Created secret key from known bytes")
    assert(recoveredBytes == testSecretBytes, "Secret key bytes should match")
    
    // Test 8: Public key derivation
    print("\\n8️⃣ Testing public key derivation...")
    let publicKey = secretKey.publicKey()
    let publicBytes = publicKey.toBytes()
    print("   ✅ Derived public key with \\(publicBytes.count) bytes")
    assert(publicBytes.count == 32, "Public key should be 32 bytes")
    
    // Test 9: Curve25519PublicKey from bytes
    print("\\n9️⃣ Testing Curve25519PublicKey from bytes...")
    let testPublicBytes = Data(repeating: 100, count: 32)
    let publicFromBytes = Curve25519PublicKey.fromBytes(bytes: testPublicBytes)
    let recoveredPublicBytes = publicFromBytes.toBytes()
    print("   ✅ Created public key from known bytes")
    assert(recoveredPublicBytes == testPublicBytes, "Public key bytes should match")
    
    // Test 10: Public key base64 encoding
    print("\\n🔟 Testing Curve25519PublicKey base64...")
    let publicBase64 = publicFromBytes.toBase64()
    print("   Base64: \\(publicBase64)")
    assert(!publicBase64.isEmpty, "Base64 should not be empty")
    
    let publicFromBase64 = try! Curve25519PublicKey.fromBase64(input: publicBase64)
    let roundtripBytes = publicFromBase64.toBytes()
    print("   ✅ Base64 round-trip successful")
    assert(roundtripBytes == testPublicBytes, "Base64 round-trip should preserve bytes")
    
    // Test 11: Public key methods
    print("\\n1️⃣1️⃣ Testing Curve25519PublicKey methods...")
    let asBytes = publicFromBytes.asBytes()
    let toVec = publicFromBytes.toVec()
    assert(asBytes == testPublicBytes, "asBytes should match original")
    assert(toVec == testPublicBytes, "toVec should match original")
    print("   ✅ All public key methods work correctly")
    
    // Test 12: Public key from slice
    print("\\n1️⃣2️⃣ Testing Curve25519PublicKey from slice...")
    let publicFromSlice = try! Curve25519PublicKey.fromSlice(bytes: testPublicBytes)
    let sliceBytes = publicFromSlice.toBytes()
    assert(sliceBytes == testPublicBytes, "fromSlice should preserve bytes")
    print("   ✅ Public key from slice works correctly")
    
    // Test 13: Key pair consistency  
    print("\\n1️⃣3️⃣ Testing key pair consistency...")
    let secret1 = Curve25519SecretKey()
    let public1 = secret1.publicKey()
    
    let secretBytes1 = secret1.toBytes()
    let secret2 = Curve25519SecretKey.fromSlice(bytes: secretBytes1)
    let public2 = secret2.publicKey()
    
    assert(public1.toBytes() == public2.toBytes(), "Key pair should be consistent")
    print("   ✅ Key pair consistency verified")
    
    // Test 14: Error handling for public key
    print("\\n1️⃣4️⃣ Testing public key error handling...")
    do {
        _ = try Curve25519PublicKey.fromBase64(input: "invalid_base64!@#")
        assert(false, "Should have thrown an error")
    } catch {
        print("   ✅ Correctly caught error for invalid base64: \\(error)")
    }
    
    do {
        _ = try Curve25519PublicKey.fromSlice(bytes: Array(repeating: 0, count: 31)) // Wrong length
        assert(false, "Should have thrown an error")  
    } catch {
        print("   ✅ Correctly caught error for wrong length: \\(error)")
    }
    
    print("\\n🎉 All cryptographic type tests passed!")
}

// Run the tests
testVodozemacBindings()
