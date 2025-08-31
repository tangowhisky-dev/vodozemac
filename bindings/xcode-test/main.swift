import Foundation

func runTests() {
    print("🧪 Vodozemac Swift Bindings Test")
    print("===============================")

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

    // Test 2: Base64 encode/decode
    print("\n2. Testing base64 functions...")
    let testData = Array("Hello, World!".utf8)
    let encoded = base64Encode(input: testData)
    print("   Encoded: \(encoded)")

    let decoded = base64Decode(input: encoded)
    let result = String(bytes: decoded, encoding: .utf8) ?? ""
    print("   Decoded: \(result)")

    if result == "Hello, World!" {
        print("   ✅ PASSED")
    } else {
        print("   ❌ FAILED - Expected 'Hello, World!', got '\(result)'")
        exit(1)
    }

    // Test 3: Edge cases
    print("\n3. Testing edge cases...")
    
    // Empty string base64 encode/decode
    let emptyData: [UInt8] = []
    let emptyEncoded = base64Encode(input: emptyData)
    let emptyDecoded = base64Decode(input: emptyEncoded)
    
    if emptyDecoded.isEmpty {
        print("   Empty data handling: ✅ PASSED")
    } else {
        print("   Empty data handling: ❌ FAILED")
        exit(1)
    }

    print("\n🎉 All tests passed!")
    print("✅ Vodozemac Swift bindings are working correctly!")
}

// Run the tests
runTests()
