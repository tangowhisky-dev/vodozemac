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

uniffi::include_scaffolding!("vodozemac");

#[cfg(test)]
mod test_bindings;
