/* This Source Code Form is subject to the terms of timpl From<vodozemac::ecies::MessageDecodeError> for VodozemacError {
    fn from(error: vodozemac::ecies::MessageDecodeError) -> Self {
        VodozemacError::Decode(error.to_string())
    }
}

// Error conversions for SAS types
impl From<vodozemac::sas::SasError> for VodozemacError {
    fn from(error: vodozemac::sas::SasError) -> Self {
        VodozemacError::Sas(error.to_string())
    }
}

impl From<vodozemac::sas::InvalidCount> for VodozemacError {
    fn from(error: vodozemac::sas::InvalidCount) -> Self {
        VodozemacError::Sas(error.to_string())
    }
}

impl From<vodozemac::KeyError> for VodozemacError {
    fn from(error: vodozemac::KeyError) -> Self {
        VodozemacError::Key(error.to_string())
    }
}

impl From<vodozemac::Base64DecodeError> for VodozemacError {
    fn from(error: vodozemac::Base64DecodeError) -> Self {
        VodozemacError::Base64Decode(error.to_string())
    }
}

impl From<base64::DecodeError> for VodozemacError {
    fn from(error: base64::DecodeError) -> Self {
        VodozemacError::Base64Decode(format!("Base64 decode error: {}", error))
    }
}

// Error conversions for OLM types
impl From<vodozemac::olm::SessionCreationError> for VodozemacError {
    fn from(error: vodozemac::olm::SessionCreationError) -> Self {
        VodozemacError::SessionCreation(error.to_string())
    }
}

impl From<vodozemac::olm::DecryptionError> for VodozemacError {
    fn from(error: vodozemac::olm::DecryptionError) -> Self {
        VodozemacError::OlmDecryption(error.to_string())
    }
}

impl From<vodozemac::DecodeError> for VodozemacError {
    fn from(error: vodozemac::DecodeError) -> Self {
        VodozemacError::Decode(error.to_string())
    }
}

impl From<vodozemac::LibolmPickleError> for VodozemacError {
    fn from(error: vodozemac::LibolmPickleError) -> Self {
        VodozemacError::LibolmPickle(error.to_string())
    }
}

impl From<vodozemac::DehydratedDeviceError> for VodozemacError {
    fn from(error: vodozemac::DehydratedDeviceError) -> Self {
        VodozemacError::DehydratedDevice(error.to_string())
    }
}

impl From<vodozemac::PickleError> for VodozemacError {
    fn from(error: vodozemac::PickleError) -> Self {
        VodozemacError::Pickle(error.to_string())
    }
}

// Enumslla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//! UniFFI bindings for vodozemac
//! 
//! This crate provides language bindings for the vodozemac cryptographic library
//! using Mozilla's UniFFI tool.

use vodozemac::{base64_decode as vz_base64_decode, base64_encode as vz_base64_encode, VERSION as VZ_VERSION};
use std::sync::Arc;

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

// Error conversions for ECIES types
impl From<vodozemac::ecies::Error> for VodozemacError {
    fn from(error: vodozemac::ecies::Error) -> Self {
        VodozemacError::Ecies(error.to_string())
    }
}

impl From<vodozemac::ecies::MessageDecodeError> for VodozemacError {
    fn from(error: vodozemac::ecies::MessageDecodeError) -> Self {
        VodozemacError::Decode(error.to_string())
    }
}

// Error conversions for SAS types
impl From<vodozemac::KeyError> for VodozemacError {
    fn from(error: vodozemac::KeyError) -> Self {
        VodozemacError::Key(error.to_string())
    }
}

impl From<vodozemac::sas::SasError> for VodozemacError {
    fn from(error: vodozemac::sas::SasError) -> Self {
        VodozemacError::Sas(error.to_string())
    }
}

impl From<vodozemac::sas::InvalidCount> for VodozemacError {
    fn from(error: vodozemac::sas::InvalidCount) -> Self {
        VodozemacError::Sas(error.to_string())
    }
}

// Error conversions for Megolm types
impl From<vodozemac::megolm::DecryptionError> for VodozemacError {
    fn from(error: vodozemac::megolm::DecryptionError) -> Self {
        VodozemacError::MegolmDecryption(error.to_string())
    }
}

impl From<vodozemac::megolm::SessionKeyDecodeError> for VodozemacError {
    fn from(error: vodozemac::megolm::SessionKeyDecodeError) -> Self {
        VodozemacError::SessionKeyDecode(error.to_string())
    }
}

impl From<vodozemac::PickleError> for VodozemacError {
    fn from(error: vodozemac::PickleError) -> Self {
        VodozemacError::Pickle(error.to_string())
    }
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
#[derive(uniffi::Object, Clone, PartialEq, Eq, Hash)]
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
#[derive(uniffi::Object, Clone)]
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

/// A check code that can be used to confirm that two EstablishedEcies
/// objects share the same secret. This is supposed to be shared out-of-band to
/// protect against active MITM attacks.
#[derive(uniffi::Object, Debug, Clone, PartialEq, Eq)]
pub struct CheckCode {
    inner: vodozemac::ecies::CheckCode,
}

#[uniffi::export]
impl CheckCode {
    /// Convert the check code to a Vec of two bytes.
    /// UniFFI doesn't support fixed arrays, so we return a Vec.
    pub fn as_bytes(&self) -> Vec<u8> {
        self.inner.as_bytes().to_vec()
    }

    /// Convert the check code to two base-10 numbers.
    /// The number should be displayed with a leading 0 in case the first digit is a 0.
    pub fn to_digit(&self) -> u8 {
        self.inner.to_digit()
    }
}

/// An encrypted message an EstablishedEcies channel has sent.
#[derive(uniffi::Object, Debug)]
pub struct Message {
    inner: vodozemac::ecies::Message,
}

#[uniffi::export]
impl Message {
    /// Encode the message as a string.
    /// The ciphertext bytes will be encoded using unpadded base64.
    pub fn encode(&self) -> String {
        self.inner.encode()
    }

    /// Attempt to decode a base64 string into a Message.
    #[uniffi::constructor]
    pub fn decode(message: &str) -> Result<Arc<Self>, VodozemacError> {
        let inner = vodozemac::ecies::Message::decode(message)?;
        Ok(Arc::new(Self { inner }))
    }

    /// Get the ciphertext bytes.
    pub fn ciphertext(&self) -> Vec<u8> {
        self.inner.ciphertext.clone()
    }
}

/// The initial message, sent by the ECIES channel establisher.
/// This message embeds the public key of the message creator allowing the other
/// side to establish a channel using this message.
#[derive(uniffi::Object, Debug)]
pub struct InitialMessage {
    inner: vodozemac::ecies::InitialMessage,
}

#[uniffi::export]
impl InitialMessage {
    /// Get the ephemeral public key that was used to establish the ECIES channel.
    pub fn public_key(&self) -> Arc<Curve25519PublicKey> {
        Arc::new(Curve25519PublicKey::from(self.inner.public_key))
    }

    /// Get the ciphertext of the initial message.
    pub fn ciphertext(&self) -> Vec<u8> {
        self.inner.ciphertext.clone()
    }

    /// Encode the message as a string.
    /// The string will contain the base64-encoded Curve25519 public key and the
    /// ciphertext of the message separated by a `|`.
    pub fn encode(&self) -> String {
        self.inner.encode()
    }

    /// Attempt to decode a string into an InitialMessage.
    #[uniffi::constructor]
    pub fn decode(message: &str) -> Result<Arc<Self>, VodozemacError> {
        let inner = vodozemac::ecies::InitialMessage::decode(message)?;
        Ok(Arc::new(Self { inner }))
    }
}

/// The result of an inbound ECIES channel establishment.
#[derive(uniffi::Object, Debug)]
pub struct InboundCreationResult {
    /// The established ECIES channel.
    ecies: Arc<EstablishedEcies>,
    /// The plaintext of the initial message.
    message: Vec<u8>,
}

#[uniffi::export]
impl InboundCreationResult {
    /// Get the established ECIES channel.
    pub fn ecies(&self) -> Arc<EstablishedEcies> {
        self.ecies.clone()
    }

    /// Get the plaintext of the initial message.
    pub fn message(&self) -> Vec<u8> {
        self.message.clone()
    }
}

/// The result of an outbound ECIES channel establishment.
#[derive(uniffi::Object, Debug)]
pub struct OutboundCreationResult {
    /// The established ECIES channel.
    ecies: Arc<EstablishedEcies>,
    /// The initial message.
    message: Arc<InitialMessage>,
}

#[uniffi::export]
impl OutboundCreationResult {
    /// Get the established ECIES channel.
    pub fn ecies(&self) -> Arc<EstablishedEcies> {
        self.ecies.clone()
    }

    /// Get the initial message.
    pub fn message(&self) -> Arc<InitialMessage> {
        self.message.clone()
    }
}

/// An unestablished ECIES session.
#[derive(uniffi::Object)]
pub struct Ecies {
    inner: std::sync::RwLock<Option<vodozemac::ecies::Ecies>>,
}

#[uniffi::export]
impl Ecies {
    /// Create a new, random, unestablished ECIES session.
    /// This method will use the `MATRIX_QR_CODE_LOGIN` info.
    #[uniffi::constructor]
    pub fn new() -> Arc<Self> {
        let inner = vodozemac::ecies::Ecies::new();
        Arc::new(Self {
            inner: std::sync::RwLock::new(Some(inner)),
        })
    }

    /// Create a new, random, unestablished ECIES session with the given application info.
    #[uniffi::constructor]
    pub fn with_info(info: &str) -> Arc<Self> {
        let inner = vodozemac::ecies::Ecies::with_info(info);
        Arc::new(Self {
            inner: std::sync::RwLock::new(Some(inner)),
        })
    }

    /// Get our Curve25519PublicKey.
    /// This public key needs to be sent to the other side to establish an ECIES channel.
    pub fn public_key(&self) -> Result<Arc<Curve25519PublicKey>, VodozemacError> {
        let inner_guard = self.inner.read().unwrap();
        match inner_guard.as_ref() {
            Some(ecies) => {
                let public_key = ecies.public_key();
                Ok(Arc::new(Curve25519PublicKey::from(public_key)))
            }
            None => Err(VodozemacError::Key(
                "ECIES session has been consumed".to_string(),
            )),
        }
    }

    /// Create an EstablishedEcies session using the other side's Curve25519
    /// public key and an initial plaintext.
    pub fn establish_outbound_channel(
        &self,
        their_public_key: Arc<Curve25519PublicKey>,
        initial_plaintext: Vec<u8>,
    ) -> Result<Arc<OutboundCreationResult>, VodozemacError> {
        let ecies = self.inner.write().unwrap().take().ok_or_else(|| VodozemacError::Key(
            "ECIES session has already been consumed".to_string(),
        ))?;

        let result = ecies.establish_outbound_channel(their_public_key.0, &initial_plaintext)?;

        let established_ecies = Arc::new(EstablishedEcies {
            inner: std::sync::Mutex::new(result.ecies),
        });

        let initial_message = Arc::new(InitialMessage {
            inner: result.message,
        });

        Ok(Arc::new(OutboundCreationResult {
            ecies: established_ecies,
            message: initial_message,
        }))
    }

    /// Create an EstablishedEcies from an InitialMessage encrypted by the other side.
    pub fn establish_inbound_channel(
        &self,
        message: Arc<InitialMessage>,
    ) -> Result<Arc<InboundCreationResult>, VodozemacError> {
        let ecies = self.inner.write().unwrap().take().ok_or_else(|| VodozemacError::Key(
            "ECIES session has already been consumed".to_string(),
        ))?;

        let result = ecies.establish_inbound_channel(&message.inner)?;

        let established_ecies = Arc::new(EstablishedEcies {
            inner: std::sync::Mutex::new(result.ecies),
        });

        Ok(Arc::new(InboundCreationResult {
            ecies: established_ecies,
            message: result.message,
        }))
    }
}

/// An established ECIES session.
/// This session can be used to encrypt and decrypt messages between the two
/// sides of the channel.
#[derive(uniffi::Object, Debug)]
pub struct EstablishedEcies {
    inner: std::sync::Mutex<vodozemac::ecies::EstablishedEcies>,
}

#[uniffi::export]
impl EstablishedEcies {
    /// Get our Curve25519PublicKey.
    /// This public key needs to be sent to the other side so that it can
    /// complete the ECIES channel establishment.
    pub fn public_key(&self) -> Arc<Curve25519PublicKey> {
        let inner = self.inner.lock().unwrap();
        Arc::new(Curve25519PublicKey::from(inner.public_key()))
    }

    /// Get the CheckCode which uniquely identifies this EstablishedEcies session.
    /// This check code can be used to check that both sides of the session are
    /// indeed using the same shared secret.
    pub fn check_code(&self) -> Arc<CheckCode> {
        let inner = self.inner.lock().unwrap();
        Arc::new(CheckCode {
            inner: inner.check_code().clone(),
        })
    }

    /// Encrypt the given plaintext using this EstablishedEcies session.
    pub fn encrypt(&self, plaintext: Vec<u8>) -> Result<Arc<Message>, VodozemacError> {
        let mut inner = self.inner.lock().unwrap();
        let message = inner.encrypt(&plaintext);
        Ok(Arc::new(Message { inner: message }))
    }

    /// Decrypt the given message using this EstablishedEcies session.
    pub fn decrypt(&self, message: Arc<Message>) -> Result<Vec<u8>, VodozemacError> {
        let mut inner = self.inner.lock().unwrap();
        let plaintext = inner.decrypt(&message.inner)?;
        Ok(plaintext)
    }
}

// =============================================================================
// SAS (Short Authentication String) Structs
// =============================================================================

/// Error type for the case when we try to generate too many SAS bytes.
#[derive(uniffi::Object)]
pub struct InvalidCount {
    inner: vodozemac::sas::InvalidCount,
}

#[uniffi::export]
impl InvalidCount {
    /// Get the error message.
    pub fn message(&self) -> String {
        self.inner.to_string()
    }
}

/// The output type for the SAS MAC calculation.
#[derive(uniffi::Object)]
pub struct Mac {
    inner: vodozemac::sas::Mac,
}

#[uniffi::export]
impl Mac {
    /// Get the MAC as base64-encoded string.
    pub fn to_base64(&self) -> String {
        self.inner.to_base64()
    }

    /// Get the raw bytes of the MAC.
    pub fn as_bytes(&self) -> Vec<u8> {
        self.inner.as_bytes().to_vec()
    }
}

/// Bytes generated from a shared secret that can be used as the short auth string.
#[derive(uniffi::Object)]
pub struct SasBytes {
    inner: vodozemac::sas::SasBytes,
}

#[uniffi::export]
impl SasBytes {
    /// Get the seven emoji indices that can be presented to users to perform
    /// the key verification.
    /// 
    /// The table that maps the index to an emoji can be found in the spec.
    pub fn emoji_indices(&self) -> Vec<u8> {
        self.inner.emoji_indices().to_vec()
    }

    /// Get the three decimal numbers that can be presented to users to perform
    /// the key verification.
    pub fn decimals(&self) -> Vec<u16> {
        let (first, second, third) = self.inner.decimals();
        vec![first, second, third]
    }

    /// Get the raw bytes of the short auth string.
    pub fn as_bytes(&self) -> Vec<u8> {
        self.inner.as_bytes().to_vec()
    }
}

/// A struct representing a short auth string verification object.
#[derive(uniffi::Object)]
pub struct Sas {
    inner: std::sync::RwLock<Option<vodozemac::sas::Sas>>,
}

#[uniffi::export]
impl Sas {
    /// Create a new SAS verification object.
    #[uniffi::constructor]
    pub fn new() -> Arc<Sas> {
        Arc::new(Sas {
            inner: std::sync::RwLock::new(Some(vodozemac::sas::Sas::new())),
        })
    }

    /// Get the public key that can be used to establish a shared secret.
    pub fn public_key(&self) -> Result<Arc<Curve25519PublicKey>, VodozemacError> {
        let inner = self.inner.read().unwrap();
        let sas = inner.as_ref().ok_or_else(|| {
            VodozemacError::Sas("SAS session already consumed".to_string())
        })?;
        Ok(Arc::new(Curve25519PublicKey(sas.public_key())))
    }

    /// Establish a SAS secret by performing a DH handshake with another public key.
    /// 
    /// Returns an EstablishedSas object which can be used to generate SasBytes.
    pub fn diffie_hellman(
        &self, 
        their_public_key: Arc<Curve25519PublicKey>
    ) -> Result<Arc<EstablishedSas>, VodozemacError> {
        let mut inner = self.inner.write().unwrap();
        let sas = inner.take().ok_or_else(|| {
            VodozemacError::Sas("SAS session already consumed".to_string())
        })?;
        
        let established = sas.diffie_hellman(their_public_key.0)?;
        Ok(Arc::new(EstablishedSas { inner: established }))
    }

    /// Establish a SAS secret by performing a DH handshake with another public key
    /// in "raw", base64-encoded form.
    pub fn diffie_hellman_with_raw(
        &self, 
        other_public_key: String
    ) -> Result<Arc<EstablishedSas>, VodozemacError> {
        let mut inner = self.inner.write().unwrap();
        let sas = inner.take().ok_or_else(|| {
            VodozemacError::Sas("SAS session already consumed".to_string())
        })?;
        
        let established = sas.diffie_hellman_with_raw(&other_public_key)?;
        Ok(Arc::new(EstablishedSas { inner: established }))
    }
}

/// A struct representing a short auth string verification object where the
/// shared secret has been established.
#[derive(uniffi::Object)]
pub struct EstablishedSas {
    inner: vodozemac::sas::EstablishedSas,
}

#[uniffi::export]
impl EstablishedSas {
    /// Generate SasBytes using HKDF with the shared secret as the input key material.
    /// 
    /// The info string should be agreed upon beforehand, both parties need to
    /// use the same info string.
    pub fn bytes(&self, info: String) -> Arc<SasBytes> {
        let sas_bytes = self.inner.bytes(&info);
        Arc::new(SasBytes { inner: sas_bytes })
    }

    /// Generate the given number of bytes using HKDF with the shared secret
    /// as the input key material.
    /// 
    /// The info string should be agreed upon beforehand, both parties need to
    /// use the same info string.
    /// 
    /// The number of bytes we can generate is limited, we can generate up to
    /// 32 * 255 bytes. This function will return an error if the given count is
    /// larger than the limit.
    pub fn bytes_raw(&self, info: String, count: u32) -> Result<Vec<u8>, VodozemacError> {
        let bytes = self.inner.bytes_raw(&info, count as usize)?;
        Ok(bytes)
    }

    /// Calculate a MAC for the given input using the info string as additional data.
    /// 
    /// This should be used to calculate a MAC of the ed25519 identity key of an Account.
    /// The MAC is returned as a base64 encoded string.
    pub fn calculate_mac(&self, input: String, info: String) -> Arc<Mac> {
        let mac = self.inner.calculate_mac(&input, &info);
        Arc::new(Mac { inner: mac })
    }

    /// Calculate a MAC for the given input using the info string as additional
    /// data, the MAC is returned as an invalid base64 encoded string.
    /// 
    /// **Warning**: This method should never be used unless you require libolm
    /// compatibility. Libolm used to incorrectly encode their MAC because the
    /// input buffer was reused as the output buffer.
    pub fn calculate_mac_invalid_base64(&self, input: String, info: String) -> String {
        self.inner.calculate_mac_invalid_base64(&input, &info)
    }

    /// Verify a MAC that was previously created using the calculate_mac method.
    /// 
    /// Users should calculate a MAC and send it to the other side, they should
    /// then verify each other's MAC using this method.
    pub fn verify_mac(
        &self,
        input: String,
        info: String,
        tag: Arc<Mac>
    ) -> Result<(), VodozemacError> {
        self.inner.verify_mac(&input, &info, &tag.inner)?;
        Ok(())
    }

    /// Get the public key that was created by us, that was used to establish
    /// the shared secret.
    pub fn our_public_key(&self) -> Arc<Curve25519PublicKey> {
        Arc::new(Curve25519PublicKey(self.inner.our_public_key()))
    }

    /// Get the public key that was created by the other party, that was used to
    /// establish the shared secret.
    pub fn their_public_key(&self) -> Arc<Curve25519PublicKey> {
        Arc::new(Curve25519PublicKey(self.inner.their_public_key()))
    }
}

// ===== OLM (Olm) CRYPTOGRAPHIC STRUCTS =====

/// An Olm Account manages all cryptographic keys used on a device.
#[derive(uniffi::Object)]
pub struct Account {
    inner: std::sync::RwLock<vodozemac::olm::Account>,
}

#[uniffi::export]
impl Account {
    /// Create a new Account with fresh identity and one-time keys.
    #[uniffi::constructor]
    pub fn new() -> Arc<Account> {
        Arc::new(Account {
            inner: std::sync::RwLock::new(vodozemac::olm::Account::new()),
        })
    }

    /// Get the IdentityKeys of this Account
    pub fn identity_keys(&self) -> Arc<IdentityKeys> {
        let inner = self.inner.read().unwrap();
        Arc::new(IdentityKeys { inner: inner.identity_keys() })
    }

    /// Get a copy of the account's public Ed25519 key
    pub fn ed25519_key(&self) -> Arc<Ed25519PublicKey> {
        let inner = self.inner.read().unwrap();
        Arc::new(Ed25519PublicKey(inner.ed25519_key()))
    }

    /// Get a copy of the account's public Curve25519 key
    pub fn curve25519_key(&self) -> Arc<Curve25519PublicKey> {
        let inner = self.inner.read().unwrap();
        Arc::new(Curve25519PublicKey(inner.curve25519_key()))
    }

    /// Sign the given message using our Ed25519 identity key.
    pub fn sign(&self, message: Vec<u8>) -> Arc<Ed25519Signature> {
        let inner = self.inner.read().unwrap();
        Arc::new(Ed25519Signature(inner.sign(message)))
    }

    /// Get the maximum number of one-time keys the client should keep on the server.
    pub fn max_number_of_one_time_keys(&self) -> u64 {
        let inner = self.inner.read().unwrap();
        inner.max_number_of_one_time_keys() as u64
    }

    /// Create a Session with the given identity key and one-time key.
    pub fn create_outbound_session(
        &self, 
        session_config: Arc<SessionConfig>,
        identity_key: Arc<Curve25519PublicKey>,
        one_time_key: Arc<Curve25519PublicKey>
    ) -> Arc<Session> {
        let inner = self.inner.read().unwrap();
        let session = inner.create_outbound_session(
            session_config.inner,
            identity_key.0,
            one_time_key.0,
        );
        Arc::new(Session { inner: std::sync::RwLock::new(session) })
    }

    /// Create a Session from the given PreKeyMessage message and identity key
    pub fn create_inbound_session(
        &self,
        their_identity_key: Arc<Curve25519PublicKey>,
        pre_key_message: Arc<PreKeyMessage>
    ) -> Result<Arc<OlmInboundCreationResult>, VodozemacError> {
        let mut inner = self.inner.write().unwrap();
        let result = inner.create_inbound_session(their_identity_key.0, &pre_key_message.inner)
            .map_err(|e| VodozemacError::SessionCreation(e.to_string()))?;
        
        Ok(Arc::new(OlmInboundCreationResult {
            session: Arc::new(Session { inner: std::sync::RwLock::new(result.session) }),
            plaintext: result.plaintext,
        }))
    }

    /// Generates the supplied number of one time keys.
    pub fn generate_one_time_keys(&self, count: u64) -> Arc<OneTimeKeyGenerationResult> {
        let mut inner = self.inner.write().unwrap();
        let result = inner.generate_one_time_keys(count as usize);
        
        Arc::new(OneTimeKeyGenerationResult {
            generated: result.created.into_iter().map(|key| Curve25519PublicKey(key)).collect(),
            discarded: result.removed.into_iter().map(|key| Curve25519PublicKey(key)).collect(),
        })
    }

    /// Get the number of one-time keys we have stored locally.
    pub fn stored_one_time_key_count(&self) -> u64 {
        let inner = self.inner.read().unwrap();
        inner.stored_one_time_key_count() as u64
    }

    /// Get the currently unpublished one-time keys.
    pub fn one_time_keys(&self) -> Vec<Arc<OneTimeKeyPair>> {
        let inner = self.inner.read().unwrap();
        inner.one_time_keys()
            .into_iter()
            .map(|(k, v)| Arc::new(OneTimeKeyPair { 
                key_id: Arc::new(KeyId(k)),
                key: Arc::new(Curve25519PublicKey(v))
            }))
            .collect()
    }

    /// Generate a single new fallback key.
    pub fn generate_fallback_key(&self) -> Option<Arc<Curve25519PublicKey>> {
        let mut inner = self.inner.write().unwrap();
        inner.generate_fallback_key().map(|key| Arc::new(Curve25519PublicKey(key)))
    }

    /// Get the currently unpublished fallback key.
    // Commented out due to Swift KeyId Hashable issues
    // pub fn fallback_key(&self) -> std::collections::HashMap<Arc<KeyId>, Arc<Curve25519PublicKey>> {
    //     let inner = self.inner.read().unwrap();
    //     inner.fallback_key()
    //         .into_iter()
    //         .map(|(k, v)| (Arc::new(KeyId(k)), Arc::new(Curve25519PublicKey(v))))
    //         .collect()
    // }

    /// The Account stores at most two private parts of the fallback key.
    pub fn forget_fallback_key(&self) -> bool {
        let mut inner = self.inner.write().unwrap();
        inner.forget_fallback_key()
    }

    /// Mark all currently unpublished one-time and fallback keys as published.
    pub fn mark_keys_as_published(&self) {
        let mut inner = self.inner.write().unwrap();
        inner.mark_keys_as_published();
    }

    /// Convert the account into a struct which implements serde::Serialize and serde::Deserialize.
    pub fn pickle(&self) -> Arc<AccountPickle> {
        let inner = self.inner.read().unwrap();
        Arc::new(AccountPickle { inner: inner.pickle() })
    }

    /// Restore an Account from a previously saved AccountPickle.
    #[uniffi::constructor]
    pub fn from_pickle(pickle: Arc<AccountPickle>) -> Result<Arc<Account>, VodozemacError> {
        // Extract the inner value from Arc - this consumes the Arc
        let account_pickle = Arc::try_unwrap(pickle).map_err(|_| VodozemacError::Key("Cannot access pickle - still referenced elsewhere".to_string()))?.inner;
        let account = vodozemac::olm::Account::from(account_pickle);
        Ok(Arc::new(Account {
            inner: std::sync::RwLock::new(account),
        }))
    }

    /// Create an Account object by unpickling an account pickle in libolm legacy pickle format.
    #[uniffi::constructor]
    pub fn from_libolm_pickle(pickle: String, pickle_key: Vec<u8>) -> Result<Arc<Account>, VodozemacError> {
        let account = vodozemac::olm::Account::from_libolm_pickle(&pickle, &pickle_key)
            .map_err(|e| VodozemacError::LibolmPickle(e.to_string()))?;
        Ok(Arc::new(Account {
            inner: std::sync::RwLock::new(account),
        }))
    }

    /// Pickle an Account into a libolm pickle format.
    pub fn to_libolm_pickle(&self, pickle_key: Vec<u8>) -> Result<String, VodozemacError> {
        let inner = self.inner.read().unwrap();
        inner.to_libolm_pickle(&pickle_key)
            .map_err(|e| VodozemacError::LibolmPickle(e.to_string()))
    }

    /// Create a dehydrated device from the account.
    pub fn to_dehydrated_device(&self, key: Vec<u8>) -> Result<DehydratedDeviceResult, VodozemacError> {
        if key.len() != 32 {
            return Err(VodozemacError::Key("Key must be exactly 32 bytes".to_string()));
        }
        
        let key_array: [u8; 32] = key.try_into().map_err(|_| VodozemacError::Key("Invalid key size".to_string()))?;
        let inner = self.inner.read().unwrap();
        let result = inner.to_dehydrated_device(&key_array)
            .map_err(|e| VodozemacError::DehydratedDevice(e.to_string()))?;
        
        Ok(DehydratedDeviceResult {
            ciphertext: result.ciphertext,
            nonce: result.nonce,
        })
    }

    /// Create an Account object from a dehydrated device.
    #[uniffi::constructor]
    pub fn from_dehydrated_device(ciphertext: String, nonce: String, key: Vec<u8>) -> Result<Arc<Account>, VodozemacError> {
        if key.len() != 32 {
            return Err(VodozemacError::Key("Key must be exactly 32 bytes".to_string()));
        }
        
        let key_array: [u8; 32] = key.try_into().map_err(|_| VodozemacError::Key("Invalid key size".to_string()))?;
        let account = vodozemac::olm::Account::from_dehydrated_device(&ciphertext, &nonce, &key_array)
            .map_err(|e| VodozemacError::DehydratedDevice(e.to_string()))?;
        Ok(Arc::new(Account {
            inner: std::sync::RwLock::new(account),
        }))
    }
}

/// A struct representing the pickled Account.
#[derive(uniffi::Object)]
pub struct AccountPickle {
    pub(crate) inner: vodozemac::olm::AccountPickle,
}

#[uniffi::export]
impl AccountPickle {
    /// Serialize and encrypt the pickle using the given key.
    pub fn encrypt(self: Arc<Self>, pickle_key: Vec<u8>) -> Result<String, VodozemacError> {
        if pickle_key.len() != 32 {
            return Err(VodozemacError::Key("Pickle key must be exactly 32 bytes".to_string()));
        }
        
        let key_array: [u8; 32] = pickle_key.try_into().map_err(|_| VodozemacError::Key("Invalid key size".to_string()))?;
        // Extract the inner value from Arc - this consumes the Arc
        let pickle = Arc::try_unwrap(self).map_err(|_| VodozemacError::Key("Cannot access pickle - still referenced elsewhere".to_string()))?.inner;
        Ok(pickle.encrypt(&key_array))
    }

    /// Obtain a pickle from a ciphertext by decrypting and deserializing using the given key.
    #[uniffi::constructor]
    pub fn from_encrypted(ciphertext: String, pickle_key: Vec<u8>) -> Result<Arc<AccountPickle>, VodozemacError> {
        if pickle_key.len() != 32 {
            return Err(VodozemacError::Key("Pickle key must be exactly 32 bytes".to_string()));
        }
        
        let key_array: [u8; 32] = pickle_key.try_into().map_err(|_| VodozemacError::Key("Invalid key size".to_string()))?;
        let pickle = vodozemac::olm::AccountPickle::from_encrypted(&ciphertext, &key_array)
            .map_err(|e| VodozemacError::Pickle(e.to_string()))?;
        Ok(Arc::new(AccountPickle { inner: pickle }))
    }
}

/// The two main identity keys of an Account.
#[derive(uniffi::Object)]
pub struct IdentityKeys {
    inner: vodozemac::olm::IdentityKeys,
}

#[uniffi::export]
impl IdentityKeys {
    /// The Ed25519 identity key, used for signing.
    pub fn ed25519(&self) -> Arc<Ed25519PublicKey> {
        Arc::new(Ed25519PublicKey(self.inner.ed25519))
    }

    /// The Curve25519 identity key, used for Diffie-Hellman operations.
    pub fn curve25519(&self) -> Arc<Curve25519PublicKey> {
        Arc::new(Curve25519PublicKey(self.inner.curve25519))
    }
}

/// A one-time key pair containing an ID and the key itself.
#[derive(uniffi::Object)]
pub struct OneTimeKeyPair {
    key_id: Arc<KeyId>,
    key: Arc<Curve25519PublicKey>,
}

#[uniffi::export]
impl OneTimeKeyPair {
    /// Get the key ID.
    pub fn key_id(&self) -> Arc<KeyId> {
        self.key_id.clone()
    }

    /// Get the public key.
    pub fn key(&self) -> Arc<Curve25519PublicKey> {
        self.key.clone()
    }
}

/// The result when creating an inbound Olm session.
#[derive(uniffi::Object)]
pub struct OlmInboundCreationResult {
    session: Arc<Session>,
    plaintext: Vec<u8>,
}

#[uniffi::export]
impl OlmInboundCreationResult {
    /// Get the created session.
    pub fn session(&self) -> Arc<Session> {
        self.session.clone()
    }

    /// Get the decrypted plaintext of the message.
    pub fn plaintext(&self) -> Vec<u8> {
        self.plaintext.clone()
    }
}

/// Result of generating one-time keys.
#[derive(uniffi::Object)]
pub struct OneTimeKeyGenerationResult {
    generated: Vec<Curve25519PublicKey>,
    discarded: Vec<Curve25519PublicKey>,
}

#[uniffi::export]
impl OneTimeKeyGenerationResult {
    /// Get the generated keys.
    pub fn generated(&self) -> Vec<Arc<Curve25519PublicKey>> {
        self.generated.iter()
            .map(|key| Arc::new(key.clone()))
            .collect()
    }

    /// Get the discarded keys.
    pub fn discarded(&self) -> Vec<Arc<Curve25519PublicKey>> {
        self.discarded.iter()
            .map(|key| Arc::new(key.clone()))
            .collect()
    }
}

/// Result from dehydrated device creation.
#[derive(uniffi::Record)]
pub struct DehydratedDeviceResult {
    pub ciphertext: String,
    pub nonce: String,
}

/// An encrypted Olm message.
#[derive(uniffi::Object)]
pub struct OlmMessage {
    inner: vodozemac::olm::OlmMessage,
}

#[uniffi::export]
impl OlmMessage {
    /// Get the type of this message.
    pub fn message_type(&self) -> MessageType {
        match &self.inner {
            vodozemac::olm::OlmMessage::Normal(_) => MessageType::Normal,
            vodozemac::olm::OlmMessage::PreKey(_) => MessageType::PreKey,
        }
    }

    /// Try to decode the given string as an OlmMessage.
    #[uniffi::constructor]
    pub fn from_base64(message: String) -> Result<Arc<OlmMessage>, VodozemacError> {
        let decoded = vodozemac::base64_decode(&message)
            .map_err(|e| VodozemacError::Base64Decode(e.to_string()))?;
        
        // Try to decode as PreKey first (type 0), then as Normal (type 1)
        let olm_message = vodozemac::olm::OlmMessage::from_parts(0, &decoded)
            .or_else(|_| vodozemac::olm::OlmMessage::from_parts(1, &decoded))
            .map_err(|e| VodozemacError::Decode(e.to_string()))?;
            
        Ok(Arc::new(OlmMessage { inner: olm_message }))
    }

    /// Encode the OlmMessage as a base64 string.
    pub fn to_base64(&self) -> String {
        let (_, bytes) = self.inner.to_parts();
        vodozemac::base64_encode(bytes)
    }
}

/// An encrypted Olm message.
#[derive(uniffi::Object)]
pub struct OlmNormalMessage {
    inner: vodozemac::olm::Message,
}

#[uniffi::export]
impl OlmNormalMessage {
    /// The ratchet key that was used to encrypt this message.
    pub fn ratchet_key(&self) -> Arc<Curve25519PublicKey> {
        Arc::new(Curve25519PublicKey(self.inner.ratchet_key()))
    }

    /// The index of the chain that was used when the message was encrypted.
    pub fn chain_index(&self) -> u64 {
        self.inner.chain_index()
    }

    /// The actual ciphertext of the message.
    pub fn ciphertext(&self) -> Vec<u8> {
        self.inner.ciphertext().to_vec()
    }

    /// The version of the Olm message.
    pub fn version(&self) -> u8 {
        self.inner.version()
    }

    /// Has the MAC been truncated in this Olm message.
    pub fn mac_truncated(&self) -> bool {
        self.inner.mac_truncated()
    }

    /// Try to decode the given byte slice as an Olm Message.
    #[uniffi::constructor]
    pub fn from_bytes(bytes: Vec<u8>) -> Result<Arc<OlmNormalMessage>, VodozemacError> {
        let message = vodozemac::olm::Message::from_bytes(&bytes)
            .map_err(|e| VodozemacError::Decode(e.to_string()))?;
        Ok(Arc::new(OlmNormalMessage { inner: message }))
    }

    /// Encode the Message as an array of bytes.
    pub fn to_bytes(&self) -> Vec<u8> {
        self.inner.to_bytes()
    }

    /// Try to decode the given string as an Olm Message.
    #[uniffi::constructor]
    pub fn from_base64(message: String) -> Result<Arc<OlmNormalMessage>, VodozemacError> {
        let message = vodozemac::olm::Message::from_base64(&message)
            .map_err(|e| VodozemacError::Decode(e.to_string()))?;
        Ok(Arc::new(OlmNormalMessage { inner: message }))
    }

    /// Encode the Message as a string.
    pub fn to_base64(&self) -> String {
        self.inner.to_base64()
    }
}

/// An encrypted Olm pre-key message.
#[derive(uniffi::Object)]
pub struct PreKeyMessage {
    inner: vodozemac::olm::PreKeyMessage,
}

#[uniffi::export]
impl PreKeyMessage {
    /// The one-time key that was used by the receiver of the message.
    pub fn one_time_key(&self) -> Arc<Curve25519PublicKey> {
        Arc::new(Curve25519PublicKey(self.inner.one_time_key()))
    }

    /// The base key that was created just in time by the sender of the message.
    pub fn base_key(&self) -> Arc<Curve25519PublicKey> {
        Arc::new(Curve25519PublicKey(self.inner.base_key()))
    }

    /// The long term identity key of the sender of the message.
    pub fn identity_key(&self) -> Arc<Curve25519PublicKey> {
        Arc::new(Curve25519PublicKey(self.inner.identity_key()))
    }

    /// The collection of all keys required for establishing an Olm Session.
    pub fn session_keys(&self) -> Arc<SessionKeys> {
        Arc::new(SessionKeys { inner: self.inner.session_keys() })
    }

    /// Returns the globally unique session ID, in base64-encoded form.
    pub fn session_id(&self) -> String {
        self.inner.session_id()
    }

    /// The actual message that contains the ciphertext.
    pub fn message(&self) -> Arc<OlmNormalMessage> {
        Arc::new(OlmNormalMessage { inner: self.inner.message().clone() })
    }

    /// Try to decode the given byte slice as an Olm PreKeyMessage.
    #[uniffi::constructor]
    pub fn from_bytes(message: Vec<u8>) -> Result<Arc<PreKeyMessage>, VodozemacError> {
        let pre_key_message = vodozemac::olm::PreKeyMessage::from_bytes(&message)
            .map_err(|e| VodozemacError::Decode(e.to_string()))?;
        Ok(Arc::new(PreKeyMessage { inner: pre_key_message }))
    }

    /// Try to decode the given string as an Olm PreKeyMessage.
    #[uniffi::constructor]
    pub fn from_base64(message: String) -> Result<Arc<PreKeyMessage>, VodozemacError> {
        let pre_key_message = vodozemac::olm::PreKeyMessage::from_base64(&message)
            .map_err(|e| VodozemacError::Decode(e.to_string()))?;
        Ok(Arc::new(PreKeyMessage { inner: pre_key_message }))
    }

    /// Encode the PreKeyMessage as an array of bytes.
    pub fn to_bytes(&self) -> Vec<u8> {
        self.inner.to_bytes()
    }

    /// Encode the PreKeyMessage as a string.
    pub fn to_base64(&self) -> String {
        self.inner.to_base64()
    }
}

/// The public part of a ratchet key pair.
#[derive(uniffi::Object)]
pub struct RatchetPublicKey {
    inner: vodozemac::olm::RatchetPublicKey,
}

#[uniffi::export]
impl RatchetPublicKey {
    /// Convert the RatchetPublicKey to a base64 encoded string.
    pub fn to_base64(&self) -> String {
        self.inner.as_ref().to_base64()
    }

    /// Try to create a RatchetPublicKey from the given base64 encoded string.
    #[uniffi::constructor]
    pub fn from_base64(key: String) -> Result<Arc<RatchetPublicKey>, VodozemacError> {
        let curve_key = vodozemac::Curve25519PublicKey::from_base64(&key)
            .map_err(|e| VodozemacError::Key(e.to_string()))?;
        let bytes = curve_key.to_bytes();
        let mut array = [0u8; 32];
        array.copy_from_slice(&bytes);
        let ratchet_key = vodozemac::olm::RatchetPublicKey::from(array);
        Ok(Arc::new(RatchetPublicKey { inner: ratchet_key }))
    }
}

/// An Olm session represents one end of an encrypted communication channel.
#[derive(uniffi::Object)]
pub struct Session {
    inner: std::sync::RwLock<vodozemac::olm::Session>,
}

#[uniffi::export]
impl Session {
    /// Returns the globally unique session ID, in base64-encoded form.
    pub fn session_id(&self) -> String {
        let inner = self.inner.read().unwrap();
        inner.session_id()
    }

    /// Have we ever received and decrypted a message from the other side?
    pub fn has_received_message(&self) -> bool {
        let inner = self.inner.read().unwrap();
        inner.has_received_message()
    }

    /// Encrypt the plaintext and construct an OlmMessage.
    pub fn encrypt(&self, plaintext: Vec<u8>) -> Arc<OlmMessage> {
        let mut inner = self.inner.write().unwrap();
        let olm_message = inner.encrypt(plaintext);
        Arc::new(OlmMessage { inner: olm_message })
    }

    /// Get the keys associated with this session.
    pub fn session_keys(&self) -> Arc<SessionKeys> {
        let inner = self.inner.read().unwrap();
        Arc::new(SessionKeys { inner: inner.session_keys() })
    }

    /// Get the SessionConfig that this Session is configured to use.
    pub fn session_config(&self) -> Arc<SessionConfig> {
        let inner = self.inner.read().unwrap();
        Arc::new(SessionConfig { inner: inner.session_config() })
    }

    /// Try to decrypt an Olm message.
    pub fn decrypt(&self, message: Arc<OlmMessage>) -> Result<Vec<u8>, VodozemacError> {
        let mut inner = self.inner.write().unwrap();
        inner.decrypt(&message.inner)
            .map_err(|e| VodozemacError::OlmDecryption(e.to_string()))
    }

    /// Convert the session into a struct which implements serde::Serialize and serde::Deserialize.
    pub fn pickle(&self) -> Arc<SessionPickle> {
        let inner = self.inner.read().unwrap();
        Arc::new(SessionPickle { inner: inner.pickle() })
    }

    /// Restore a Session from a previously saved SessionPickle.
    #[uniffi::constructor]
    pub fn from_pickle(pickle: Arc<SessionPickle>) -> Result<Arc<Session>, VodozemacError> {
        // Extract the inner value from Arc - this consumes the Arc
        let session_pickle = Arc::try_unwrap(pickle).map_err(|_| VodozemacError::Key("Cannot access pickle - still referenced elsewhere".to_string()))?.inner;
        let session = vodozemac::olm::Session::from_pickle(session_pickle);
        Ok(Arc::new(Session {
            inner: std::sync::RwLock::new(session),
        }))
    }

    /// Create a Session object by unpickling a session pickle in libolm legacy pickle format.
    #[uniffi::constructor]
    pub fn from_libolm_pickle(pickle: String, pickle_key: Vec<u8>) -> Result<Arc<Session>, VodozemacError> {
        let session = vodozemac::olm::Session::from_libolm_pickle(&pickle, &pickle_key)
            .map_err(|e| VodozemacError::LibolmPickle(e.to_string()))?;
        Ok(Arc::new(Session {
            inner: std::sync::RwLock::new(session),
        }))
    }
}

/// Session configuration for Olm sessions.
#[derive(uniffi::Object)]
pub struct SessionConfig {
    inner: vodozemac::olm::SessionConfig,
}

#[uniffi::export]
impl SessionConfig {
    /// Create a SessionConfig for Olm version 1.
    #[uniffi::constructor]
    pub fn version_1() -> Arc<SessionConfig> {
        Arc::new(SessionConfig {
            inner: vodozemac::olm::SessionConfig::version_1(),
        })
    }

    /// Create a SessionConfig for Olm version 2.
    #[uniffi::constructor]
    pub fn version_2() -> Arc<SessionConfig> {
        Arc::new(SessionConfig {
            inner: vodozemac::olm::SessionConfig::version_2(),
        })
    }

    /// Create a default SessionConfig.
    #[uniffi::constructor]
    pub fn default() -> Arc<SessionConfig> {
        Arc::new(SessionConfig {
            inner: vodozemac::olm::SessionConfig::default(),
        })
    }
}

/// Session keys for an Olm session.
#[derive(uniffi::Object)]
pub struct SessionKeys {
    inner: vodozemac::olm::SessionKeys,
}

#[uniffi::export]
impl SessionKeys {
    /// The identity key, a long-lived Ed25519 key.
    pub fn identity_key(&self) -> Arc<Curve25519PublicKey> {
        Arc::new(Curve25519PublicKey(self.inner.identity_key))
    }

    /// The base key, a single-use Curve25519 key.
    pub fn base_key(&self) -> Arc<Curve25519PublicKey> {
        Arc::new(Curve25519PublicKey(self.inner.base_key))
    }

    /// The one time key, a single-use Curve25519 key.
    pub fn one_time_key(&self) -> Arc<Curve25519PublicKey> {
        Arc::new(Curve25519PublicKey(self.inner.one_time_key))
    }

    /// Returns the globally unique session ID, in base64-encoded form.
    pub fn session_id(&self) -> String {
        self.inner.session_id()
    }
}

/// A struct representing the pickled Session.
#[derive(uniffi::Object)]
pub struct SessionPickle {
    inner: vodozemac::olm::SessionPickle,
}

#[uniffi::export]
impl SessionPickle {
    /// Serialize and encrypt the pickle using the given key.
    pub fn encrypt(self: Arc<Self>, pickle_key: Vec<u8>) -> Result<String, VodozemacError> {
        if pickle_key.len() != 32 {
            return Err(VodozemacError::Key("Pickle key must be exactly 32 bytes".to_string()));
        }
        
        let key_array: [u8; 32] = pickle_key.try_into().map_err(|_| VodozemacError::Key("Invalid key size".to_string()))?;
        // Extract the inner value from Arc - this consumes the Arc
        let pickle = Arc::try_unwrap(self).map_err(|_| VodozemacError::Key("Cannot access pickle - still referenced elsewhere".to_string()))?.inner;
        Ok(pickle.encrypt(&key_array))
    }

    /// Obtain a pickle from a ciphertext by decrypting and deserializing using the given key.
    #[uniffi::constructor]
    pub fn from_encrypted(ciphertext: String, pickle_key: Vec<u8>) -> Result<Arc<SessionPickle>, VodozemacError> {
        if pickle_key.len() != 32 {
            return Err(VodozemacError::Key("Pickle key must be exactly 32 bytes".to_string()));
        }
        
        let key_array: [u8; 32] = pickle_key.try_into().map_err(|_| VodozemacError::Key("Invalid key size".to_string()))?;
        let pickle = vodozemac::olm::SessionPickle::from_encrypted(&ciphertext, &key_array)
            .map_err(|e| VodozemacError::Pickle(e.to_string()))?;
        Ok(Arc::new(SessionPickle { inner: pickle }))
    }
}

// ========================================================================
// Megolm Module Bindings
// ========================================================================

/// Configuration options for Megolm sessions
/// 
/// This determines the version and encryption parameters used for the session
#[derive(uniffi::Object)]
pub struct MegolmSessionConfig {
    inner: vodozemac::megolm::SessionConfig,
}

#[uniffi::export]
impl MegolmSessionConfig {
    /// Create a Version 1 session configuration
    /// 
    /// Version 1 uses truncated MAC for better compatibility with older clients
    #[uniffi::constructor]
    pub fn version_1() -> Arc<Self> {
        Arc::new(Self {
            inner: vodozemac::megolm::SessionConfig::version_1(),
        })
    }

    /// Create a Version 2 session configuration  
    /// 
    /// Version 2 uses full MAC for better security
    #[uniffi::constructor]
    pub fn version_2() -> Arc<Self> {
        Arc::new(Self {
            inner: vodozemac::megolm::SessionConfig::version_2(),
        })
    }
}

impl From<vodozemac::megolm::SessionConfig> for MegolmSessionConfig {
    fn from(config: vodozemac::megolm::SessionConfig) -> Self {
        Self { inner: config }
    }
}

/// A message successfully decrypted by an InboundGroupSession
/// 
/// Contains the decrypted plaintext and the message index to prevent replay attacks
#[derive(uniffi::Object)]
pub struct DecryptedMessage {
    inner: vodozemac::megolm::DecryptedMessage,
}

#[uniffi::export]
impl DecryptedMessage {
    /// Get the decrypted plaintext bytes
    pub fn plaintext(&self) -> Vec<u8> {
        self.inner.plaintext.clone()
    }

    /// Get the message index used to encrypt this message
    /// 
    /// Each plaintext message should be encrypted with a unique message index per session
    pub fn message_index(&self) -> u32 {
        self.inner.message_index
    }
}

impl From<vodozemac::megolm::DecryptedMessage> for DecryptedMessage {
    fn from(message: vodozemac::megolm::DecryptedMessage) -> Self {
        Self { inner: message }
    }
}

/// An exported session key that can be used to create an InboundGroupSession
/// 
/// This is used to share session keys between clients for group messaging
#[derive(uniffi::Object)]
pub struct ExportedSessionKey {
    inner: vodozemac::megolm::ExportedSessionKey,
}

#[uniffi::export]
impl ExportedSessionKey {
    /// Create an ExportedSessionKey from a base64 string
    #[uniffi::constructor]
    pub fn from_base64(input: String) -> Result<Arc<Self>, VodozemacError> {
        let key = vodozemac::megolm::ExportedSessionKey::from_base64(&input)?;
        Ok(Arc::new(Self { inner: key }))
    }

    /// Create an ExportedSessionKey from bytes
    #[uniffi::constructor]
    pub fn from_bytes(bytes: Vec<u8>) -> Result<Arc<Self>, VodozemacError> {
        let key = vodozemac::megolm::ExportedSessionKey::from_bytes(&bytes)?;
        Ok(Arc::new(Self { inner: key }))
    }

    /// Convert the exported session key to a base64 string
    pub fn to_base64(&self) -> String {
        self.inner.to_base64()
    }

    /// Convert the exported session key to bytes
    pub fn to_bytes(&self) -> Vec<u8> {
        self.inner.to_bytes()
    }
}

impl From<vodozemac::megolm::ExportedSessionKey> for ExportedSessionKey {
    fn from(key: vodozemac::megolm::ExportedSessionKey) -> Self {
        Self { inner: key }
    }
}

/// A Megolm group session for sending encrypted messages
/// 
/// Represents a single sending participant in an encrypted group communication context
#[derive(uniffi::Object)]
pub struct GroupSession {
    inner: std::sync::Mutex<vodozemac::megolm::GroupSession>,
}

#[uniffi::export]
impl GroupSession {
    /// Create a new group session with the default configuration (Version 2)
    #[uniffi::constructor]
    pub fn new() -> Arc<Self> {
        Arc::new(Self {
            inner: std::sync::Mutex::new(vodozemac::megolm::GroupSession::new(vodozemac::megolm::SessionConfig::version_2())),
        })
    }

    /// Create a new group session with a specific configuration
    #[uniffi::constructor]
    pub fn with_config(config: Arc<MegolmSessionConfig>) -> Arc<Self> {
        Arc::new(Self {
            inner: std::sync::Mutex::new(vodozemac::megolm::GroupSession::new(config.inner)),
        })
    }

    /// Create a group session from a pickle  
    #[uniffi::constructor]
    pub fn from_pickle(pickle: Arc<GroupSessionPickle>) -> Result<Arc<Self>, VodozemacError> {
        // Extract the inner value from Arc - this consumes the Arc
        let session_pickle = Arc::try_unwrap(pickle).map_err(|_| VodozemacError::Key("Failed to unwrap GroupSessionPickle".to_string()))?.inner;
        let session = vodozemac::megolm::GroupSession::from_pickle(session_pickle);
        Ok(Arc::new(Self {
            inner: std::sync::Mutex::new(session),
        }))
    }

    /// Encrypt a plaintext message
    pub fn encrypt(&self, plaintext: Vec<u8>) -> Arc<MegolmMessage> {
        let mut session = self.inner.lock().unwrap();
        let message = session.encrypt(&plaintext);
        Arc::new(MegolmMessage { inner: message })
    }

    /// Get the current message index
    pub fn message_index(&self) -> u32 {
        let session = self.inner.lock().unwrap();
        session.message_index()
    }

    /// Get the session key that can be shared with other participants
    pub fn session_key(&self) -> Arc<SessionKey> {
        let session = self.inner.lock().unwrap();
        let key = session.session_key();
        Arc::new(SessionKey { inner: key })
    }

    /// Create a pickle from this group session
    pub fn pickle(&self) -> Arc<GroupSessionPickle> {
        let session = self.inner.lock().unwrap();
        let pickle = session.pickle();
        Arc::new(GroupSessionPickle { inner: pickle })
    }

    /// Get the session ID
    pub fn session_id(&self) -> String {
        let session = self.inner.lock().unwrap();
        session.session_id()
    }
}

impl From<vodozemac::megolm::GroupSession> for GroupSession {
    fn from(session: vodozemac::megolm::GroupSession) -> Self {
        Self { inner: std::sync::Mutex::new(session) }
    }
}

/// A pickled group session that can be stored and later restored
#[derive(uniffi::Object)]
pub struct GroupSessionPickle {
    inner: vodozemac::megolm::GroupSessionPickle,
}

#[uniffi::export]
impl GroupSessionPickle {
    /// Create an encrypted pickle from this group session pickle
    /// 
    /// Note: This consumes the pickle as the encryption method takes ownership
    pub fn encrypt(self: Arc<Self>, pickle_key: Vec<u8>) -> Result<String, VodozemacError> {
        if pickle_key.len() != 32 {
            return Err(VodozemacError::Key("Pickle key must be exactly 32 bytes".to_string()));
        }
        
        let key_array: [u8; 32] = pickle_key.try_into().map_err(|_| VodozemacError::Key("Invalid key size".to_string()))?;
        let inner_pickle = Arc::try_unwrap(self)
            .map_err(|_| VodozemacError::Key("Failed to unwrap GroupSessionPickle".to_string()))?
            .inner;
        let encrypted = inner_pickle.encrypt(&key_array);
        Ok(encrypted)
    }

    /// Create a group session pickle by decrypting an encrypted pickle
    #[uniffi::constructor]
    pub fn from_encrypted(ciphertext: String, pickle_key: Vec<u8>) -> Result<Arc<Self>, VodozemacError> {
        if pickle_key.len() != 32 {
            return Err(VodozemacError::Key("Pickle key must be exactly 32 bytes".to_string()));
        }
        
        let key_array: [u8; 32] = pickle_key.try_into().map_err(|_| VodozemacError::Key("Invalid key size".to_string()))?;
        let pickle = vodozemac::megolm::GroupSessionPickle::from_encrypted(&ciphertext, &key_array)?;
        Ok(Arc::new(Self { inner: pickle }))
    }
}

impl From<vodozemac::megolm::GroupSessionPickle> for GroupSessionPickle {
    fn from(pickle: vodozemac::megolm::GroupSessionPickle) -> Self {
        Self { inner: pickle }
    }
}

/// A Megolm inbound group session for receiving encrypted messages  
/// 
/// Represents a single receiving participant in an encrypted group communication
#[derive(uniffi::Object)]
pub struct InboundGroupSession {
    inner: std::sync::Mutex<vodozemac::megolm::InboundGroupSession>,
}

#[uniffi::export]
impl InboundGroupSession {
    /// Create an inbound group session from a session key
    #[uniffi::constructor]
    pub fn new(session_key: Arc<SessionKey>, config: Arc<MegolmSessionConfig>) -> Arc<Self> {
        let session = vodozemac::megolm::InboundGroupSession::new(&session_key.inner, config.inner);
        Arc::new(Self {
            inner: std::sync::Mutex::new(session),
        })
    }

    /// Import an inbound group session from an exported session key
    #[uniffi::constructor]
    pub fn import(exported_key: Arc<ExportedSessionKey>, config: Arc<MegolmSessionConfig>) -> Arc<Self> {
        let session = vodozemac::megolm::InboundGroupSession::import(&exported_key.inner, config.inner);
        Arc::new(Self {
            inner: std::sync::Mutex::new(session),
        })
    }

    /// Create an inbound group session from a pickle
    #[uniffi::constructor]
    pub fn from_pickle(pickle: Arc<InboundGroupSessionPickle>) -> Result<Arc<Self>, VodozemacError> {
        // Extract the inner value from Arc - this consumes the Arc
        let session_pickle = Arc::try_unwrap(pickle).map_err(|_| VodozemacError::Key("Failed to unwrap InboundGroupSessionPickle".to_string()))?.inner;
        let session = vodozemac::megolm::InboundGroupSession::from_pickle(session_pickle);
        Ok(Arc::new(Self {
            inner: std::sync::Mutex::new(session),
        }))
    }

    /// Decrypt a megolm message
    pub fn decrypt(&self, message: Arc<MegolmMessage>) -> Result<Arc<DecryptedMessage>, VodozemacError> {
        let mut session = self.inner.lock().unwrap();
        let decrypted = session.decrypt(&message.inner)?;
        Ok(Arc::new(DecryptedMessage { inner: decrypted }))
    }

    /// Get the session ID
    pub fn session_id(&self) -> String {
        let session = self.inner.lock().unwrap();
        session.session_id()
    }

    /// Get the first known message index
    pub fn first_known_index(&self) -> u32 {
        let session = self.inner.lock().unwrap();
        session.first_known_index()
    }

    /// Export the session at a specific message index
    pub fn export_at(&self, message_index: u32) -> Option<Arc<ExportedSessionKey>> {
        let mut session = self.inner.lock().unwrap();
        session.export_at(message_index).map(|key| Arc::new(ExportedSessionKey { inner: key }))
    }

    /// Compare sessions to determine their relative position in the ratchet
    pub fn compare(&self, other: Arc<InboundGroupSession>) -> SessionOrdering {
        let mut session = self.inner.lock().unwrap();
        let mut other_session = other.inner.lock().unwrap();
        session.compare(&mut *other_session).into()
    }

    /// Create a pickle from this inbound group session
    pub fn pickle(&self) -> Arc<InboundGroupSessionPickle> {
        let session = self.inner.lock().unwrap();
        let pickle = session.pickle();
        Arc::new(InboundGroupSessionPickle { inner: pickle })
    }
}

impl From<vodozemac::megolm::InboundGroupSession> for InboundGroupSession {
    fn from(session: vodozemac::megolm::InboundGroupSession) -> Self {
        Self { inner: std::sync::Mutex::new(session) }
    }
}

/// A pickled inbound group session that can be stored and later restored
#[derive(uniffi::Object)]
pub struct InboundGroupSessionPickle {
    inner: vodozemac::megolm::InboundGroupSessionPickle,
}

#[uniffi::export]
impl InboundGroupSessionPickle {
    /// Create an encrypted pickle from this inbound group session pickle
    /// 
    /// Note: This consumes the pickle as the encryption method takes ownership
    pub fn encrypt(self: Arc<Self>, pickle_key: Vec<u8>) -> Result<String, VodozemacError> {
        if pickle_key.len() != 32 {
            return Err(VodozemacError::Key("Pickle key must be exactly 32 bytes".to_string()));
        }
        
        let key_array: [u8; 32] = pickle_key.try_into().map_err(|_| VodozemacError::Key("Invalid key size".to_string()))?;
        let inner_pickle = Arc::try_unwrap(self)
            .map_err(|_| VodozemacError::Key("Failed to unwrap InboundGroupSessionPickle".to_string()))?
            .inner;
        let encrypted = inner_pickle.encrypt(&key_array);
        Ok(encrypted)
    }

    /// Create an inbound group session pickle by decrypting an encrypted pickle
    #[uniffi::constructor]
    pub fn from_encrypted(ciphertext: String, pickle_key: Vec<u8>) -> Result<Arc<Self>, VodozemacError> {
        if pickle_key.len() != 32 {
            return Err(VodozemacError::Key("Pickle key must be exactly 32 bytes".to_string()));
        }
        
        let key_array: [u8; 32] = pickle_key.try_into().map_err(|_| VodozemacError::Key("Invalid key size".to_string()))?;
        let pickle = vodozemac::megolm::InboundGroupSessionPickle::from_encrypted(&ciphertext, &key_array)?;
        Ok(Arc::new(Self { inner: pickle }))
    }
}

impl From<vodozemac::megolm::InboundGroupSessionPickle> for InboundGroupSessionPickle {
    fn from(pickle: vodozemac::megolm::InboundGroupSessionPickle) -> Self {
        Self { inner: pickle }
    }
}

/// An encrypted Megolm message
/// 
/// Contains the ciphertext, signature, and metadata for a group message
#[derive(uniffi::Object)]
pub struct MegolmMessage {
    inner: vodozemac::megolm::MegolmMessage,
}

#[uniffi::export]
impl MegolmMessage {
    /// Create a MegolmMessage from a base64 string
    #[uniffi::constructor]
    pub fn from_base64(input: String) -> Result<Arc<Self>, VodozemacError> {
        let bytes = base64_decode(input)?;
        let message: vodozemac::megolm::MegolmMessage = bytes.try_into()
            .map_err(|e: vodozemac::DecodeError| VodozemacError::Decode(e.to_string()))?;
        Ok(Arc::new(Self { inner: message }))
    }

    /// Create a MegolmMessage from bytes
    #[uniffi::constructor] 
    pub fn from_bytes(bytes: Vec<u8>) -> Result<Arc<Self>, VodozemacError> {
        let message: vodozemac::megolm::MegolmMessage = bytes.try_into()
            .map_err(|e: vodozemac::DecodeError| VodozemacError::Decode(e.to_string()))?;
        Ok(Arc::new(Self { inner: message }))
    }

    /// Convert the message to a base64 string
    pub fn to_base64(&self) -> String {
        self.inner.to_base64()
    }

    /// Convert the message to bytes
    pub fn to_bytes(&self) -> Vec<u8> {
        self.inner.to_bytes()
    }

    /// Get the message index
    pub fn message_index(&self) -> u32 {
        self.inner.message_index()
    }

    /// Get the ciphertext
    pub fn ciphertext(&self) -> Vec<u8> {
        self.inner.ciphertext().to_vec()
    }
}

impl From<vodozemac::megolm::MegolmMessage> for MegolmMessage {
    fn from(message: vodozemac::megolm::MegolmMessage) -> Self {
        Self { inner: message }
    }
}

/// A session key that can be used to create an InboundGroupSession
/// 
/// Contains the signed session key for authentication
#[derive(uniffi::Object)]
pub struct SessionKey {
    inner: vodozemac::megolm::SessionKey,
}

#[uniffi::export]
impl SessionKey {
    /// Create a SessionKey from a base64 string
    #[uniffi::constructor]
    pub fn from_base64(input: String) -> Result<Arc<Self>, VodozemacError> {
        let key = vodozemac::megolm::SessionKey::from_base64(&input)?;
        Ok(Arc::new(Self { inner: key }))
    }

    /// Create a SessionKey from bytes
    #[uniffi::constructor]
    pub fn from_bytes(bytes: Vec<u8>) -> Result<Arc<Self>, VodozemacError> {
        let key = vodozemac::megolm::SessionKey::from_bytes(&bytes)?;
        Ok(Arc::new(Self { inner: key }))
    }

    /// Convert the session key to a base64 string
    pub fn to_base64(&self) -> String {
        self.inner.to_base64()
    }

    /// Convert the session key to bytes
    pub fn to_bytes(&self) -> Vec<u8> {
        self.inner.to_bytes()
    }
}

impl From<vodozemac::megolm::SessionKey> for SessionKey {
    fn from(key: vodozemac::megolm::SessionKey) -> Self {
        Self { inner: key }
    }
}

uniffi::include_scaffolding!("vodozemac");

#[cfg(test)]
mod test_bindings;
