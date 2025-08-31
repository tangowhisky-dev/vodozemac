#!/usr/bin/env swift

// Simple Swift test program to verify vodozemac bindings work
// Run this with: swift test_bindings.swift

import Foundation
import vodozemac_bindings

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
    print("\\n📚 Integration Guide: See docs/XcodeIntegrationGuide.md")
    print("🔧 To use in your project: Copy generated/ files to your Xcode project")
}

// Run the tests
testVodozemacBindings()
