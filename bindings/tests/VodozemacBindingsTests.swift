import XCTest
import Foundation

class VodozemacBindingsTests: XCTestCase {

    func testBase64Encode() {
        // Test encoding a simple string
        let input: [UInt8] = Array("Hello, World!".utf8)
        let encoded = base64Encode(input: input)
        
        XCTAssertEqual(encoded, "SGVsbG8sIFdvcmxkIQ", "Base64 encoding should work correctly")
    }
    
    func testBase64Decode() throws {
        // Test decoding a base64 string
        let input = "SGVsbG8sIFdvcmxkIQ"
        let decoded = base64Decode(input: input)
        let decodedString = try XCTUnwrap(String(bytes: decoded, encoding: .utf8))
        
        XCTAssertEqual(decodedString, "Hello, World!", "Base64 decoding should work correctly")
    }
    
    func testBase64RoundTrip() {
        // Test that encoding and decoding are consistent
        let originalData: [UInt8] = Array("Test data for round trip".utf8)
        let encoded = base64Encode(input: originalData)
        let decoded = base64Decode(input: encoded)
        
        XCTAssertEqual(decoded, originalData, "Base64 round trip should preserve data")
    }
    
    func testGetVersion() {
        // Test that version is returned
        let version = getVersion()
        
        XCTAssertFalse(version.isEmpty, "Version should not be empty")
        XCTAssertEqual(version, "0.9.0", "Version should match vodozemac version")
    }
    
    func testBase64DecodeInvalidInput() {
        // Test with invalid base64 input - should return empty array based on our implementation
        let invalidBase64 = "invalid!@#$%"
        let decoded = base64Decode(input: invalidBase64)
        
        XCTAssertTrue(decoded.isEmpty, "Invalid base64 should result in empty array")
    }
}
