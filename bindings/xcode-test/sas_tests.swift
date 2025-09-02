import Foundation

func testSasBasicFlow() -> Bool {
    print("Testing SAS basic flow...")
    
    do {
        // Test SAS creation
        let alice = Sas()
        let bob = Sas()
        
        let alicePublicKey = try alice.publicKey()
        let bobPublicKey = try bob.publicKey()
        
        print("✓ SAS sessions created and public keys extracted successfully")
        
        // Test establishing shared secret
        let aliceEstablished = try alice.diffieHellman(theirPublicKey: bobPublicKey)
        let bobEstablished = try bob.diffieHellman(theirPublicKey: alicePublicKey)
        
        print("✓ Shared secrets established successfully")
        
        // Test generating SAS bytes with same info string
        let info = "AGREED_INFO_STRING"
        let aliceSasBytes = aliceEstablished.bytes(info: info)
        let bobSasBytes = bobEstablished.bytes(info: info)
        
        // Check that emoji indices match
        let aliceEmojis = aliceSasBytes.emojiIndices()
        let bobEmojis = bobSasBytes.emojiIndices()
        
        guard aliceEmojis == bobEmojis else {
            print("✗ Emoji indices don't match")
            return false
        }
        
        // Check that decimals match
        let aliceDecimals = aliceSasBytes.decimals()
        let bobDecimals = bobSasBytes.decimals()
        
        guard aliceDecimals == bobDecimals else {
            print("✗ Decimals don't match")
            return false
        }
        
        // Check that raw bytes match
        let aliceBytes = aliceSasBytes.asBytes()
        let bobBytes = bobSasBytes.asBytes()
        
        guard aliceBytes == bobBytes else {
            print("✗ Raw bytes don't match")
            return false
        }
        
        print("✓ SAS bytes match: emoji indices, decimals, and raw bytes all identical")
        print("   Emoji indices count: \(aliceEmojis.count)")
        print("   Decimals: \(aliceDecimals)")
        
        return true
        
    } catch {
        print("✗ SAS basic flow failed: \(error)")
        return false
    }
}

func testSasWithRawPublicKey() -> Bool {
    print("Testing SAS with raw (base64) public key...")
    
    do {
        let alice = Sas()
        let bob = Sas()
        
        // Get both public keys first before diffie_hellman consumes the objects
        let alicePublicKey = try alice.publicKey()
        let bobPublicKey = try bob.publicKey()
        let bobKeyBase64 = bobPublicKey.toBase64()
        
        print("✓ Bob's public key: \(bobKeyBase64)")
        
        // Alice uses raw public key method
        let aliceEstablished = try alice.diffieHellmanWithRaw(otherPublicKey: bobKeyBase64)
        let bobEstablished = try bob.diffieHellman(theirPublicKey: alicePublicKey)
        
        // Test with same info
        let info = "RAW_KEY_TEST"
        let aliceSasBytes = aliceEstablished.bytes(info: info)
        let bobSasBytes = bobEstablished.bytes(info: info)
        
        guard aliceSasBytes.asBytes() == bobSasBytes.asBytes() else {
            print("✗ SAS bytes don't match when using raw public key")
            return false
        }
        
        print("✓ SAS with raw public key successful")
        return true
        
    } catch {
        print("✗ SAS with raw public key failed: \(error)")
        return false
    }
}

func testSasRawBytesGeneration() -> Bool {
    print("Testing SAS raw bytes generation...")
    
    do {
        let alice = Sas()
        let bob = Sas()
        
        // Get both public keys first
        let alicePublicKey = try alice.publicKey()
        let bobPublicKey = try bob.publicKey()
        
        let aliceEstablished = try alice.diffieHellman(theirPublicKey: bobPublicKey)
        let bobEstablished = try bob.diffieHellman(theirPublicKey: alicePublicKey)
        
        let info = "RAW_BYTES_TEST"
        
        // Test different byte counts
        let counts: [UInt32] = [6, 32, 64, 100]
        
        for count in counts {
            let aliceRawBytes = try aliceEstablished.bytesRaw(info: info, count: count)
            let bobRawBytes = try bobEstablished.bytesRaw(info: info, count: count)
            
            guard aliceRawBytes == bobRawBytes else {
                print("✗ Raw bytes don't match for count \(count)")
                return false
            }
            
            guard aliceRawBytes.count == count else {
                print("✗ Expected \(count) bytes, got \(aliceRawBytes.count)")
                return false
            }
            
            print("✓ Raw bytes generation successful for count \(count)")
        }
        
        // Test error case: try to generate too many bytes (should fail)
        do {
            let _ = try aliceEstablished.bytesRaw(info: info, count: 10000)
            print("✗ Should have failed for too many bytes")
            return false
        } catch {
            print("✓ Correctly failed for excessive byte count: \(error)")
        }
        
        return true
        
    } catch {
        print("✗ SAS raw bytes generation failed: \(error)")
        return false
    }
}

func testSasMacCalculationAndVerification() -> Bool {
    print("Testing SAS MAC calculation and verification...")
    
    do {
        let alice = Sas()
        let bob = Sas()
        
        // Get both public keys first
        let alicePublicKey = try alice.publicKey()
        let bobPublicKey = try bob.publicKey()
        
        let aliceEstablished = try alice.diffieHellman(theirPublicKey: bobPublicKey)
        let bobEstablished = try bob.diffieHellman(theirPublicKey: alicePublicKey)
        
        // Test MAC calculation
        let input = "TEST_IDENTITY_KEY"
        let info = "MAC_TEST_INFO"
        
        let aliceMac = aliceEstablished.calculateMac(input: input, info: info)
        let bobMac = bobEstablished.calculateMac(input: input, info: info)
        
        // MACs should be identical for same input
        let aliceMacBase64 = aliceMac.toBase64()
        let bobMacBase64 = bobMac.toBase64()
        
        guard aliceMacBase64 == bobMacBase64 else {
            print("✗ MAC base64 strings don't match")
            return false
        }
        
        let aliceMacBytes = aliceMac.asBytes()
        let bobMacBytes = bobMac.asBytes()
        
        guard aliceMacBytes == bobMacBytes else {
            print("✗ MAC bytes don't match")
            return false
        }
        
        print("✓ MAC calculation successful, MACs match")
        print("   MAC base64: \(aliceMacBase64)")
        
        // Test MAC verification
        try aliceEstablished.verifyMac(input: input, info: info, tag: bobMac)
        try bobEstablished.verifyMac(input: input, info: info, tag: aliceMac)
        
        print("✓ MAC verification successful")
        
        // Test MAC verification failure with wrong input
        do {
            try aliceEstablished.verifyMac(input: "WRONG_INPUT", info: info, tag: bobMac)
            print("✗ Should have failed MAC verification with wrong input")
            return false
        } catch {
            print("✓ Correctly failed MAC verification with wrong input")
        }
        
        // Test MAC verification failure with wrong info
        do {
            try aliceEstablished.verifyMac(input: input, info: "WRONG_INFO", tag: bobMac)
            print("✗ Should have failed MAC verification with wrong info")
            return false
        } catch {
            print("✓ Correctly failed MAC verification with wrong info")
        }
        
        return true
        
    } catch {
        print("✗ SAS MAC calculation and verification failed: \(error)")
        return false
    }
}

func testSasPublicKeyAccess() -> Bool {
    print("Testing SAS public key access...")
    
    do {
        let alice = Sas()
        let bob = Sas()
        
        let aliceOriginalKey = try alice.publicKey()
        let bobOriginalKey = try bob.publicKey()
        
        let aliceEstablished = try alice.diffieHellman(theirPublicKey: bobOriginalKey)
        let bobEstablished = try bob.diffieHellman(theirPublicKey: aliceOriginalKey)
        
        // Test accessing public keys from established sessions
        let aliceOurKey = aliceEstablished.ourPublicKey()
        let aliceTheirKey = aliceEstablished.theirPublicKey()
        
        let bobOurKey = bobEstablished.ourPublicKey()
        let bobTheirKey = bobEstablished.theirPublicKey()
        
        // Verify the key relationships
        guard aliceOurKey.toBase64() == aliceOriginalKey.toBase64() else {
            print("✗ Alice's our_public_key doesn't match original")
            return false
        }
        
        guard bobOurKey.toBase64() == bobOriginalKey.toBase64() else {
            print("✗ Bob's our_public_key doesn't match original")
            return false
        }
        
        guard aliceTheirKey.toBase64() == bobOriginalKey.toBase64() else {
            print("✗ Alice's their_public_key doesn't match Bob's original")
            return false
        }
        
        guard bobTheirKey.toBase64() == aliceOriginalKey.toBase64() else {
            print("✗ Bob's their_public_key doesn't match Alice's original")
            return false
        }
        
        print("✓ Public key access successful")
        print("   Alice's key: \(aliceOriginalKey.toBase64())")
        print("   Bob's key: \(bobOriginalKey.toBase64())")
        
        return true
        
    } catch {
        print("✗ SAS public key access failed: \(error)")
        return false
    }
}

func testSasDifferentInfoStrings() -> Bool {
    print("Testing SAS with different info strings...")
    
    do {
        let alice = Sas()
        let bob = Sas()
        
        // Get both public keys first
        let alicePublicKey = try alice.publicKey()
        let bobPublicKey = try bob.publicKey()
        
        let aliceEstablished = try alice.diffieHellman(theirPublicKey: bobPublicKey)
        let bobEstablished = try bob.diffieHellman(theirPublicKey: alicePublicKey)
        
        // Test same info produces same results
        let info1 = "INFO_STRING_A"
        let aliceBytes1 = aliceEstablished.bytes(info: info1)
        let bobBytes1 = bobEstablished.bytes(info: info1)
        
        guard aliceBytes1.asBytes() == bobBytes1.asBytes() else {
            print("✗ Same info should produce same SAS bytes")
            return false
        }
        
        // Test different info produces different results
        let info2 = "INFO_STRING_B"
        let aliceBytes2 = aliceEstablished.bytes(info: info2)
        
        guard aliceBytes1.asBytes() != aliceBytes2.asBytes() else {
            print("✗ Different info should produce different SAS bytes")
            return false
        }
        
        print("✓ Different info strings produce different SAS bytes as expected")
        
        return true
        
    } catch {
        print("✗ SAS different info strings test failed: \(error)")
        return false
    }
}

func runSasTests() -> Bool {
    print("=== Running SAS Tests ===")
    
    let tests: [(String, () -> Bool)] = [
        ("Basic Flow", testSasBasicFlow),
        ("Raw Public Key", testSasWithRawPublicKey),
        ("Raw Bytes Generation", testSasRawBytesGeneration),
        ("MAC Calculation and Verification", testSasMacCalculationAndVerification),
        ("Public Key Access", testSasPublicKeyAccess),
    ("Different Info Strings", testSasDifferentInfoStrings),
    ("MAC Constructors", testSasMacConstructors),
    ("Invalid Base64 MAC", testSasInvalidBase64Mac)
    ]
    
    var passed = 0
    var failed = 0
    
    for (name, test) in tests {
        print("\n--- \(name) ---")
        if test() {
            passed += 1
            print("✓ \(name) PASSED")
        } else {
            failed += 1
            print("✗ \(name) FAILED")
        }
    }
    
    print("\n=== SAS Test Results ===")
    print("Passed: \(passed)")
    print("Failed: \(failed)")
    print("Total: \(passed + failed)")
    
    return failed == 0
}

func testSasMacConstructors() -> Bool {
    print("Testing SAS Mac constructors (fromBase64/fromSlice)...")
    do {
        let alice = Sas()
        let bob = Sas()

        let alicePk = try alice.publicKey()
        let bobPk = try bob.publicKey()

        let aliceEstablished = try alice.diffieHellman(theirPublicKey: bobPk)
        let bobEstablished = try bob.diffieHellman(theirPublicKey: alicePk)

        let input = "CONSTRUCTOR_TEST_KEY"
        let info = "CONSTRUCTOR_TEST_INFO"

        let mac = aliceEstablished.calculateMac(input: input, info: info)
        let base64 = mac.toBase64()
        let bytes = mac.asBytes()

        // fromBase64
        let macFromBase64 = try Mac.fromBase64(mac: base64)
        guard macFromBase64.toBase64() == base64 else {
            print("✗ Mac.fromBase64 round-trip failed")
            return false
        }

        // fromSlice
        let macFromSlice = Mac.fromSlice(bytes: bytes)
        guard macFromSlice.asBytes() == bytes else {
            print("✗ Mac.fromSlice round-trip failed")
            return false
        }

        // Cross-compare with Bob
        let bobMac = bobEstablished.calculateMac(input: input, info: info)
        guard bobMac.toBase64() == base64 else {
            print("✗ Bob's MAC doesn't match Alice's")
            return false
        }

        print("✓ Mac constructors behave correctly")
        return true
    } catch {
        print("✗ SAS Mac constructors test failed: \(error)")
        return false
    }
}

func testSasInvalidBase64Mac() -> Bool {
    print("Testing SAS invalid-base64 MAC for libolm compatibility...")
    do {
        let alice = Sas()
        let bob = Sas()

        let alicePk = try alice.publicKey()
        let bobPk = try bob.publicKey()

        let aliceEstablished = try alice.diffieHellman(theirPublicKey: bobPk)
        let bobEstablished = try bob.diffieHellman(theirPublicKey: alicePk)

        let input = "INVALID_BASE64_TEST"
        let info = "INVALID_BASE64_INFO"

        let aInvalid = aliceEstablished.calculateMacInvalidBase64(input: input, info: info)
        let bInvalid = bobEstablished.calculateMacInvalidBase64(input: input, info: info)

        // They should be identical
        guard aInvalid == bInvalid else {
            print("✗ Invalid-base64 MAC strings don't match")
            return false
        }

        // And they typically shouldn't decode with standard base64 decoder
        do {
            _ = try base64Decode(input: aInvalid)
            print("⚠️ Unexpected: invalid-base64 MAC decoded successfully; continuing")
        } catch {
            print("✓ invalid-base64 MAC fails to decode with standard base64, as expected")
        }

        print("✓ Invalid-base64 MAC compatibility path works")
        return true
    } catch {
        print("✗ SAS invalid-base64 MAC test failed: \(error)")
        return false
    }
}
