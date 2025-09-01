import Foundation

func testEciesBasicChannelEstablishment() -> Bool {
    print("Testing ECIES basic channel establishment...")
    
    do {
        // Test basic ECIES creation
        let alice = Ecies()
        let bob = Ecies()
        
        // Test public key extraction
        let alicePublicKey = try alice.publicKey()
        let bobPublicKey = try bob.publicKey()
        
        print("✓ ECIES sessions created successfully")
        print("✓ Public keys extracted successfully")
        
        // Test outbound channel establishment
        let plaintext = "Hello from Alice!".data(using: .utf8)!
        
        let outboundResult = try alice.establishOutboundChannel(
            theirPublicKey: bobPublicKey, 
            initialPlaintext: plaintext
        )
        
        let aliceChannel = outboundResult.ecies()
        let initialMessage = outboundResult.message()
        
        print("✓ Outbound channel established successfully")
        
        // Test inbound channel establishment
        let inboundResult = try bob.establishInboundChannel(message: initialMessage)
        let bobChannel = inboundResult.ecies()
        let decryptedMessage = inboundResult.message()
        
        print("✓ Inbound channel established successfully")
        
        // Verify the initial message was decrypted correctly
        guard Data(decryptedMessage) == plaintext else {
            print("✗ Initial message decryption failed")
            return false
        }
        
        print("✓ Initial message decrypted correctly")
        
        // Test check code verification
        let aliceCheckCode = aliceChannel.checkCode()
        let bobCheckCode = bobChannel.checkCode()
        
        guard aliceCheckCode.asBytes() == bobCheckCode.asBytes() else {
            print("✗ Check codes don't match")
            return false
        }
        
        print("✓ Check codes match: \(aliceCheckCode.toDigit())")
        
        return true
        
    } catch {
        print("✗ ECIES basic channel establishment failed: \(error)")
        return false
    }
}

func testEciesEncryptionDecryption() -> Bool {
    print("Testing ECIES encryption/decryption...")
    
    do {
        // Establish channel first
        let alice = Ecies()
        let bob = Ecies()
        
        let initialData = "Initial message".data(using: .utf8)!
        
        let outboundResult = try alice.establishOutboundChannel(
            theirPublicKey: try bob.publicKey(),
            initialPlaintext: initialData
        )
        
        let inboundResult = try bob.establishInboundChannel(message: outboundResult.message())
        
        let aliceChannel = outboundResult.ecies()
        let bobChannel = inboundResult.ecies()
        
        // Test Alice sending to Bob
        let aliceMessage = "Hello from Alice!".data(using: .utf8)!
        
        let encryptedMessage = try aliceChannel.encrypt(plaintext: aliceMessage)
        let decryptedByBob = try bobChannel.decrypt(message: encryptedMessage)
        
        guard Data(decryptedByBob) == aliceMessage else {
            print("✗ Alice->Bob decryption failed")
            return false
        }
        
        print("✓ Alice->Bob encryption/decryption successful")
        
        // Test Bob sending to Alice
        let bobMessage = "Hello from Bob!".data(using: .utf8)!
        
        let bobEncryptedMessage = try bobChannel.encrypt(plaintext: bobMessage)
        let decryptedByAlice = try aliceChannel.decrypt(message: bobEncryptedMessage)
        
        guard Data(decryptedByAlice) == bobMessage else {
            print("✗ Bob->Alice decryption failed")
            return false
        }
        
        print("✓ Bob->Alice encryption/decryption successful")
        
        // Test message encoding/decoding
        let encodedMessage = encryptedMessage.encode()
        let decodedMessage = try Message.decode(message: encodedMessage)
        
        let reDecrypted = try bobChannel.decrypt(message: decodedMessage)
        guard Data(reDecrypted) == aliceMessage else {
            print("✗ Message encoding/decoding failed")
            return false
        }
        
        print("✓ Message encoding/decoding successful")
        
        return true
        
    } catch {
        print("✗ ECIES encryption/decryption failed: \(error)")
        return false
    }
}

func testEciesWithCustomInfo() -> Bool {
    print("Testing ECIES with custom application info...")
    
    do {
        let customInfo = "CUSTOM_APP_INFO"
        let alice = Ecies.withInfo(info: customInfo)
        let bob = Ecies.withInfo(info: customInfo)
        
        let plaintext = "Custom info test".data(using: .utf8)!
        
        let outboundResult = try alice.establishOutboundChannel(
            theirPublicKey: try bob.publicKey(),
            initialPlaintext: plaintext
        )
        
        let inboundResult = try bob.establishInboundChannel(message: outboundResult.message())
        
        guard Data(inboundResult.message()) == plaintext else {
            print("✗ Custom info channel failed")
            return false
        }
        
        // Verify check codes still work
        let aliceCheck = outboundResult.ecies().checkCode()
        let bobCheck = inboundResult.ecies().checkCode()
        
        guard aliceCheck.asBytes() == bobCheck.asBytes() else {
            print("✗ Custom info check codes don't match")
            return false
        }
        
        print("✓ Custom application info successful")
        return true
        
    } catch {
        print("✗ ECIES custom info test failed: \(error)")
        return false
    }
}

func testEciesInitialMessageSerialization() -> Bool {
    print("Testing ECIES InitialMessage serialization...")
    
    do {
        let alice = Ecies()
        let bob = Ecies()
        
        let plaintext = "Serialization test".data(using: .utf8)!
        
        let outboundResult = try alice.establishOutboundChannel(
            theirPublicKey: try bob.publicKey(),
            initialPlaintext: plaintext
        )
        
        let initialMessage = outboundResult.message()
        
        // Test encoding/decoding
        let encoded = initialMessage.encode()
        let decoded = try InitialMessage.decode(message: encoded)
        
        // Verify the decoded message works
        let inboundResult = try bob.establishInboundChannel(message: decoded)
        
        guard Data(inboundResult.message()) == plaintext else {
            print("✗ Decoded InitialMessage failed to decrypt")
            return false
        }
        
        // Check that public keys match
        let originalKey = initialMessage.publicKey()
        let decodedKey = decoded.publicKey()
        
        guard originalKey.toBase64() == decodedKey.toBase64() else {
            print("✗ Public keys don't match after serialization")
            return false
        }
        
        print("✓ InitialMessage serialization successful")
        return true
        
    } catch {
        print("✗ InitialMessage serialization failed: \(error)")
        return false
    }
}

func testEciesCheckCodeProperties() -> Bool {
    print("Testing ECIES CheckCode properties...")
    
    do {
        let alice = Ecies()
        let bob = Ecies()
        
        let plaintext = "Check code test".data(using: .utf8)!
        
        let outboundResult = try alice.establishOutboundChannel(
            theirPublicKey: try bob.publicKey(),
            initialPlaintext: plaintext
        )
        
        let inboundResult = try bob.establishInboundChannel(message: outboundResult.message())
        
        let checkCode = outboundResult.ecies().checkCode()
        
        // Test check code properties
        let bytes = checkCode.asBytes()
        let digit = checkCode.toDigit()
        
        // Verify digit is in valid range (0-99)
        guard digit <= 99 else {
            print("✗ Check code digit out of range: \(digit)")
            return false
        }
        
        // Verify bytes conversion to digit  
        guard bytes.count == 2 else {
            print("✗ Check code bytes should have length 2")
            return false
        }
        let expectedDigit = (bytes[0] % 10) * 10 + (bytes[1] % 10)
        guard digit == expectedDigit else {
            print("✗ Check code digit calculation incorrect: \(digit) vs \(expectedDigit)")
            return false
        }
        
        print("✓ CheckCode properties work correctly (digit: \(String(format: "%02d", digit)))")
        return true
        
    } catch {
        print("✗ CheckCode properties test failed: \(error)")
        return false
    }
}

func runEciesTests() -> Bool {
    print("=== Running ECIES Tests ===")
    
    let tests: [(String, () -> Bool)] = [
        ("Basic Channel Establishment", testEciesBasicChannelEstablishment),
        ("Encryption/Decryption", testEciesEncryptionDecryption),
        ("Custom Application Info", testEciesWithCustomInfo),
        ("InitialMessage Serialization", testEciesInitialMessageSerialization),
        ("CheckCode Properties", testEciesCheckCodeProperties)
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
    
    print("\n=== ECIES Test Results ===")
    print("Passed: \(passed)")
    print("Failed: \(failed)")
    print("Total: \(passed + failed)")
    
    return failed == 0
}
