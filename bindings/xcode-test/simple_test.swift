import Foundation

print("🧪 Simple Vodozemac Test")
print("=======================")

// Test 1: Version
print("\n1. Testing getVersion()...")
let version = getVersion()
print("   Version: \(version)")
if version == "0.9.0" {
    print("   ✅ PASSED")
} else {
    print("   ❌ FAILED: Expected 0.9.0")
    exit(1)
}

// Test 2: Base64 encode/decode
print("\n2. Testing base64 functions...")
let testData = Array("Hello!".utf8)
let encoded = base64Encode(input: testData)
print("   Encoded: \(encoded)")

let decoded = base64Decode(input: encoded)
let result = String(bytes: decoded, encoding: .utf8) ?? ""
print("   Decoded: \(result)")

if result == "Hello!" {
    print("   ✅ PASSED")
} else {
    print("   ❌ FAILED: Round-trip failed")
    exit(1)
}

print("\n🎉 All tests passed!")
print("✅ Vodozemac Swift bindings are working with Xcode tools!")
