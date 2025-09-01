/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//! UniFFI bindings for vodozemac
//! 
//! This crate provides language bindings for the vodozemac cryptographic library
//! using Mozilla's UniFFI tool.

use vodozemac::{base64_decode as vz_base64_decode, base64_encode as vz_base64_encode, VERSION as VZ_VERSION};

// Wrapper error types that UniFFI can handle

#[derive(Debug, thiserror::Error)]
pub enum VodozemacError {
    #[error("Base64 decode error: {0}")]
    Base64Decode(String),
    #[error("ProtoBuf decode error: {0}")]  
    ProtoBufDecode(String),
    #[error("Decode error: {0}")]
    Decode(String),
    #[error("Dehydrated device error: {0}")]
    DehydratedDevice(String),
    #[error("Key error: {0}")]
    Key(String),
    #[error("LibOlm pickle error: {0}")]
    LibolmPickle(String),
    #[error("Pickle error: {0}")]
    Pickle(String),
    #[error("Signature error: {0}")]
    Signature(String),
    #[error("ECIES error: {0}")]
    Ecies(String),
    #[error("Megolm decryption error: {0}")]
    MegolmDecryption(String),
    #[error("Olm decryption error: {0}")]
    OlmDecryption(String),
    #[error("Session creation error: {0}")]
    SessionCreation(String),
    #[error("Session key decode error: {0}")]
    SessionKeyDecode(String),
    #[error("SAS error: {0}")]
    Sas(String),
}

// Enums
#[derive(Debug, Clone, PartialEq)]
pub enum MessageType {
    Normal,
    PreKey,
}

impl From<&vodozemac::olm::OlmMessage> for MessageType {
    fn from(msg: &vodozemac::olm::OlmMessage) -> Self {
        match msg {
            vodozemac::olm::OlmMessage::Normal(_) => MessageType::Normal,
            vodozemac::olm::OlmMessage::PreKey(_) => MessageType::PreKey,
        }
    }
}

#[derive(Debug, Clone, PartialEq)]
pub enum SessionOrdering {
    Equal,
    Better,
    Worse,
    Unconnected,
}

impl From<vodozemac::megolm::SessionOrdering> for SessionOrdering {
    fn from(ordering: vodozemac::megolm::SessionOrdering) -> Self {
        match ordering {
            vodozemac::megolm::SessionOrdering::Equal => SessionOrdering::Equal,
            vodozemac::megolm::SessionOrdering::Better => SessionOrdering::Better,
            vodozemac::megolm::SessionOrdering::Worse => SessionOrdering::Worse,
            vodozemac::megolm::SessionOrdering::Unconnected => SessionOrdering::Unconnected,
        }
    }
}

/// Decode a base64 string into bytes with proper error handling
fn base64_decode(input: String) -> Result<Vec<u8>, VodozemacError> {
    vz_base64_decode(&input).map_err(|e| VodozemacError::Base64Decode(e.to_string()))
}

/// Encode bytes as a base64 string  
fn base64_encode(input: Vec<u8>) -> String {
    vz_base64_encode(&input)
}

/// Get the version of vodozemac that is being used
fn get_version() -> String {
    VZ_VERSION.to_string()
}

// Wrapper implementations for cryptographic types

// Wrapper implementations for cryptographic types
// 
// IMPORTANT: These use procedural macros (#[uniffi::export]) instead of UDL interfaces
// to avoid UniFFI checksum mismatches. See UNIFFI_EXPANSION_GUIDE.md for details.

/// Key ID wrapper for UniFFI
/// 
/// Pattern: Simple object with constructor and method
#[derive(uniffi::Object)]
pub struct KeyId(pub vodozemac::KeyId);

#[uniffi::export]
impl KeyId {
    /// Create a KeyId from a u64 value  
    /// 
    /// Pattern: Simple constructor returning Arc<Self>
    #[uniffi::constructor]
    pub fn from_u64(value: u64) -> std::sync::Arc<Self> {
        // We need to manually construct a KeyId since the constructor is private
        // Looking at the KeyId test, we can create it by manually constructing it
        let key_id = unsafe { std::mem::transmute(value) };
        std::sync::Arc::new(Self(key_id))
    }

    /// Convert the KeyId to a base64 string
    /// 
    /// Pattern: Simple method returning primitive type
    pub fn to_base64(&self) -> String {
        self.0.to_base64()
    }
}

impl From<vodozemac::KeyId> for KeyId {
    fn from(key_id: vodozemac::KeyId) -> Self {
        Self(key_id)
    }
}

/// Wrapper around vodozemac::Curve25519PublicKey
/// 
/// Pattern: Complex object with multiple constructors, error handling, and various return types
#[derive(uniffi::Object)]
pub struct Curve25519PublicKey(vodozemac::Curve25519PublicKey);

#[uniffi::export]
impl Curve25519PublicKey {
    /// Create a Curve25519PublicKey from a base64 string
    /// 
    /// Pattern: Fallible constructor with error handling
    #[uniffi::constructor]
    pub fn from_base64(input: String) -> Result<std::sync::Arc<Self>, VodozemacError> {
        let key = vodozemac::Curve25519PublicKey::from_base64(&input)
            .map_err(|e| VodozemacError::Key(e.to_string()))?;
        Ok(std::sync::Arc::new(Self(key)))
    }

    /// Create a Curve25519PublicKey from a slice of bytes
    /// 
    /// Pattern: Fallible constructor with error handling
    #[uniffi::constructor]
    pub fn from_slice(bytes: Vec<u8>) -> Result<std::sync::Arc<Self>, VodozemacError> {
        let key = vodozemac::Curve25519PublicKey::from_slice(&bytes)
            .map_err(|e| VodozemacError::Key(e.to_string()))?;
        Ok(std::sync::Arc::new(Self(key)))
    }

    /// Create a Curve25519PublicKey from exactly 32 bytes
    /// 
    /// Pattern: Infallible constructor (panics on invalid input)
    #[uniffi::constructor]
    pub fn from_bytes(bytes: Vec<u8>) -> std::sync::Arc<Self> {
        if bytes.len() != 32 {
            panic!("Curve25519PublicKey requires exactly 32 bytes");
        }
        let mut array = [0u8; 32];
        array.copy_from_slice(&bytes);
        std::sync::Arc::new(Self(vodozemac::Curve25519PublicKey::from_bytes(array)))
    }

    /// Convert the public key to bytes
    /// 
    /// Pattern: Method returning Vec<u8> (mapped to Swift Data)
    pub fn to_bytes(&self) -> Vec<u8> {
        self.0.to_bytes().to_vec()
    }

    /// View the public key as bytes
    /// 
    /// Pattern: Method returning Vec<u8> (mapped to Swift Data)
    pub fn as_bytes(&self) -> Vec<u8> {
        self.0.as_bytes().to_vec()
    }

    /// Convert the public key to a vector of bytes
    /// 
    /// Pattern: Method returning Vec<u8> (mapped to Swift Data)
    pub fn to_vec(&self) -> Vec<u8> {
        self.0.to_vec()
    }

    /// Convert the public key to a base64 string
    /// 
    /// Pattern: Method returning primitive type (String)
    pub fn to_base64(&self) -> String {
        self.0.to_base64()
    }
}

impl From<vodozemac::Curve25519PublicKey> for Curve25519PublicKey {
    fn from(key: vodozemac::Curve25519PublicKey) -> Self {
        Self(key)
    }
}

impl From<&vodozemac::Curve25519PublicKey> for Curve25519PublicKey {
    fn from(key: &vodozemac::Curve25519PublicKey) -> Self {
        Self(*key)
    }
}

/// Wrapper around vodozemac::Curve25519SecretKey
/// 
/// Pattern: Object that returns other objects (demonstrates Arc<OtherObject> pattern)
#[derive(uniffi::Object)]
pub struct Curve25519SecretKey(vodozemac::Curve25519SecretKey);

#[uniffi::export]
impl Curve25519SecretKey {
    /// Generate a new random Curve25519SecretKey
    /// 
    /// Pattern: Simple constructor with no parameters
    #[uniffi::constructor]
    pub fn new() -> std::sync::Arc<Self> {
        std::sync::Arc::new(Self(vodozemac::Curve25519SecretKey::new()))
    }

    /// Create a Curve25519SecretKey from exactly 32 bytes
    /// 
    /// Pattern: Constructor with validation (panics on invalid input)
    #[uniffi::constructor]
    pub fn from_slice(bytes: Vec<u8>) -> std::sync::Arc<Self> {
        if bytes.len() != 32 {
            panic!("Curve25519SecretKey requires exactly 32 bytes");
        }
        let mut array = [0u8; 32];
        array.copy_from_slice(&bytes);
        std::sync::Arc::new(Self(vodozemac::Curve25519SecretKey::from_slice(&array)))
    }

    /// Convert the secret key to bytes
    /// 
    /// Pattern: Method returning Vec<u8>
    pub fn to_bytes(&self) -> Vec<u8> {
        self.0.to_bytes().to_vec()
    }

    /// Get the public key that corresponds to this secret key
    /// 
    /// Pattern: Method returning Arc<AnotherObject> - CRITICAL for UniFFI
    pub fn public_key(&self) -> std::sync::Arc<Curve25519PublicKey> {
        std::sync::Arc::new(Curve25519PublicKey(vodozemac::Curve25519PublicKey::from(&self.0)))
    }
}

impl From<vodozemac::Curve25519SecretKey> for Curve25519SecretKey {
    fn from(key: vodozemac::Curve25519SecretKey) -> Self {
        Self(key)
    }
}

// Ed25519 Cryptographic Types
//
// Pattern: Following the procedural macro approach that eliminates checksum mismatches

/// Wrapper around vodozemac::Ed25519Keypair
/// 
/// Ed25519 keypair containing both public and secret keys for digital signatures
#[derive(uniffi::Object)]
pub struct Ed25519Keypair(vodozemac::Ed25519Keypair);

#[uniffi::export]
impl Ed25519Keypair {
    /// Generate a new random Ed25519 keypair
    /// 
    /// Pattern: Simple constructor with no parameters
    #[uniffi::constructor]
    pub fn new() -> std::sync::Arc<Self> {
        std::sync::Arc::new(Self(vodozemac::Ed25519Keypair::new()))
    }

    /// Get the public key from this keypair
    /// 
    /// Pattern: Method returning Arc<AnotherObject>
    pub fn public_key(&self) -> std::sync::Arc<Ed25519PublicKey> {
        std::sync::Arc::new(Ed25519PublicKey(self.0.public_key()))
    }

    /// Sign a message with the secret key from this keypair
    /// 
    /// Pattern: Method taking bytes and returning Arc<AnotherObject>
    pub fn sign(&self, message: Vec<u8>) -> std::sync::Arc<Ed25519Signature> {
        let signature = self.0.sign(&message);
        std::sync::Arc::new(Ed25519Signature(signature))
    }
}

impl From<vodozemac::Ed25519Keypair> for Ed25519Keypair {
    fn from(keypair: vodozemac::Ed25519Keypair) -> Self {
        Self(keypair)
    }
}

/// Wrapper around vodozemac::Ed25519PublicKey
/// 
/// Ed25519 public key used to verify digital signatures
#[derive(uniffi::Object)]
pub struct Ed25519PublicKey(vodozemac::Ed25519PublicKey);

#[uniffi::export]
impl Ed25519PublicKey {
    /// Create an Ed25519PublicKey from a slice of bytes
    /// 
    /// Pattern: Fallible constructor with error handling
    #[uniffi::constructor]
    pub fn from_slice(bytes: Vec<u8>) -> Result<std::sync::Arc<Self>, VodozemacError> {
        if bytes.len() != 32 {
            return Err(VodozemacError::Key("Ed25519PublicKey requires exactly 32 bytes".to_string()));
        }
        let mut array = [0u8; 32];
        array.copy_from_slice(&bytes);
        let key = vodozemac::Ed25519PublicKey::from_slice(&array)
            .map_err(|e| VodozemacError::Key(e.to_string()))?;
        Ok(std::sync::Arc::new(Self(key)))
    }

    /// Create an Ed25519PublicKey from a base64 string
    /// 
    /// Pattern: Fallible constructor with error handling
    #[uniffi::constructor]
    pub fn from_base64(input: String) -> Result<std::sync::Arc<Self>, VodozemacError> {
        let key = vodozemac::Ed25519PublicKey::from_base64(&input)
            .map_err(|e| VodozemacError::Key(e.to_string()))?;
        Ok(std::sync::Arc::new(Self(key)))
    }

    /// View this public key as a byte array
    /// 
    /// Pattern: Method returning Vec<u8>
    pub fn as_bytes(&self) -> Vec<u8> {
        self.0.as_bytes().to_vec()
    }

    /// Convert the public key to a base64 string
    /// 
    /// Pattern: Method returning primitive type (String)
    pub fn to_base64(&self) -> String {
        self.0.to_base64()
    }

    /// Verify that the provided signature for a message was signed by this key
    /// 
    /// Pattern: Method with complex parameters, returns Result
    pub fn verify(&self, message: Vec<u8>, signature: std::sync::Arc<Ed25519Signature>) -> Result<(), VodozemacError> {
        self.0.verify(&message, &signature.0)
            .map_err(|e| VodozemacError::Signature(e.to_string()))
    }
}

impl From<vodozemac::Ed25519PublicKey> for Ed25519PublicKey {
    fn from(key: vodozemac::Ed25519PublicKey) -> Self {
        Self(key)
    }
}

/// Wrapper around vodozemac::Ed25519SecretKey
/// 
/// Ed25519 secret key used to create digital signatures
#[derive(uniffi::Object)]
pub struct Ed25519SecretKey(vodozemac::Ed25519SecretKey);

#[uniffi::export]
impl Ed25519SecretKey {
    /// Generate a new random Ed25519 secret key
    /// 
    /// Pattern: Simple constructor with no parameters
    #[uniffi::constructor]
    pub fn new() -> std::sync::Arc<Self> {
        std::sync::Arc::new(Self(vodozemac::Ed25519SecretKey::new()))
    }

    /// Create an Ed25519SecretKey from a slice of bytes
    /// 
    /// Pattern: Constructor with validation
    #[uniffi::constructor]
    pub fn from_slice(bytes: Vec<u8>) -> Result<std::sync::Arc<Self>, VodozemacError> {
        if bytes.len() != 32 {
            return Err(VodozemacError::Key("Ed25519SecretKey requires exactly 32 bytes".to_string()));
        }
        let mut array = [0u8; 32];
        array.copy_from_slice(&bytes);
        let key = vodozemac::Ed25519SecretKey::from_slice(&array);
        Ok(std::sync::Arc::new(Self(key)))
    }

    /// Create an Ed25519SecretKey from a base64 string
    /// 
    /// Pattern: Fallible constructor with error handling  
    #[uniffi::constructor]
    pub fn from_base64(input: String) -> Result<std::sync::Arc<Self>, VodozemacError> {
        let key = vodozemac::Ed25519SecretKey::from_base64(&input)
            .map_err(|e| VodozemacError::Key(e.to_string()))?;
        Ok(std::sync::Arc::new(Self(key)))
    }

    /// Get the byte representation of the secret key
    /// 
    /// Pattern: Method returning Vec<u8> (Box<[u8; 32]> is converted to Vec<u8>)
    pub fn to_bytes(&self) -> Vec<u8> {
        self.0.to_bytes().to_vec()
    }

    /// Convert the secret key to a base64 encoded string
    /// 
    /// Pattern: Method returning primitive type (String)
    pub fn to_base64(&self) -> String {
        self.0.to_base64()
    }

    /// Get the public key that matches this secret key
    /// 
    /// Pattern: Method returning Arc<AnotherObject>
    pub fn public_key(&self) -> std::sync::Arc<Ed25519PublicKey> {
        std::sync::Arc::new(Ed25519PublicKey(self.0.public_key()))
    }

    /// Sign the given slice of bytes with this secret key
    /// 
    /// Pattern: Method taking bytes and returning Arc<AnotherObject>
    pub fn sign(&self, message: Vec<u8>) -> std::sync::Arc<Ed25519Signature> {
        let signature = self.0.sign(&message);
        std::sync::Arc::new(Ed25519Signature(signature))
    }
}

impl From<vodozemac::Ed25519SecretKey> for Ed25519SecretKey {
    fn from(key: vodozemac::Ed25519SecretKey) -> Self {
        Self(key)
    }
}

/// Wrapper around vodozemac::Ed25519Signature
/// 
/// Ed25519 digital signature that can be used to verify message authenticity
#[derive(uniffi::Object)]
pub struct Ed25519Signature(vodozemac::Ed25519Signature);

#[uniffi::export]
impl Ed25519Signature {
    /// Create an Ed25519Signature from a slice of bytes
    /// 
    /// Pattern: Fallible constructor with error handling
    #[uniffi::constructor]
    pub fn from_slice(bytes: Vec<u8>) -> Result<std::sync::Arc<Self>, VodozemacError> {
        let signature = vodozemac::Ed25519Signature::from_slice(&bytes)
            .map_err(|e| VodozemacError::Signature(e.to_string()))?;
        Ok(std::sync::Arc::new(Self(signature)))
    }

    /// Create an Ed25519Signature from a base64 string
    /// 
    /// Pattern: Fallible constructor with error handling
    #[uniffi::constructor]
    pub fn from_base64(input: String) -> Result<std::sync::Arc<Self>, VodozemacError> {
        let signature = vodozemac::Ed25519Signature::from_base64(&input)
            .map_err(|e| VodozemacError::Signature(e.to_string()))?;
        Ok(std::sync::Arc::new(Self(signature)))
    }

    /// Convert the signature to a base64 encoded string
    /// 
    /// Pattern: Method returning primitive type (String)
    pub fn to_base64(&self) -> String {
        self.0.to_base64()
    }

    /// Convert the signature to a byte array
    /// 
    /// Pattern: Method returning Vec<u8>
    pub fn to_bytes(&self) -> Vec<u8> {
        self.0.to_bytes().to_vec()
    }
}

impl From<vodozemac::Ed25519Signature> for Ed25519Signature {
    fn from(signature: vodozemac::Ed25519Signature) -> Self {
        Self(signature)
    }
}

/// Wrapper around vodozemac::SharedSecret
/// 
/// The result of a Diffie-Hellman key exchange
#[derive(uniffi::Object)]
pub struct SharedSecret(vodozemac::SharedSecret);

#[uniffi::export]
impl SharedSecret {
    /// Convert the shared secret to bytes
    /// 
    /// Pattern: Method returning Vec<u8>
    pub fn to_bytes(&self) -> Vec<u8> {
        self.0.to_bytes().to_vec()
    }

    /// View this shared secret as a byte array
    /// 
    /// Pattern: Method returning Vec<u8>
    pub fn as_bytes(&self) -> Vec<u8> {
        self.0.as_bytes().to_vec()
    }

    /// Check if the key exchange was contributory
    /// 
    /// Returns true if the key exchange was contributory (good),
    /// false otherwise (can be bad for some protocols)
    /// 
    /// Pattern: Method returning primitive type (bool)
    pub fn was_contributory(&self) -> bool {
        self.0.was_contributory()
    }
}

impl From<vodozemac::SharedSecret> for SharedSecret {
    fn from(secret: vodozemac::SharedSecret) -> Self {
        Self(secret)
    }
}

uniffi::include_scaffolding!("vodozemac");

#[cfg(test)]
mod test_bindings;
