use std::collections::HashMap;

use vodozemac::{
    ecies::{CheckCode, Ecies, EstablishedEcies},
    megolm::{ExportedSessionKey, GroupSession, InboundGroupSession, MegolmMessage, SessionOrdering},
    olm::{Account, IdentityKeys, InboundCreationResult, OlmMessage, Session, SessionConfig},
    sas::{EstablishedSas, Mac, Sas, SasBytes},
    types::{Curve25519PublicKey, Curve25519SecretKey, Ed25519PublicKey, Ed25519Signature, KeyId},
    Curve25519KeyPair, Ed25519KeyPair,
};

// Re-export the uniffi-generated code
uniffi::include_scaffolding!("vodozemac");

// Version constant
pub const VERSION: &str = env!("CARGO_PKG_VERSION");

// Error wrapper types for UniFFI compatibility
#[derive(Debug, thiserror::Error)]
pub enum VodozemacError {
    #[error("Pickle error: {msg}")]
    PickleError { msg: String },
    #[error("Decode error: {msg}")]
    DecodeError { msg: String },
    #[error("LibOlm pickle error: {msg}")]
    LibolmPickleError { msg: String },
    #[error("Session creation error: {msg}")]
    SessionCreationError { msg: String },
    #[error("Invalid signature")]
    InvalidSignature,
    #[error("Invalid MAC")]
    InvalidMac,
    #[error("Invalid key")]
    InvalidKey,
    #[error("Invalid base64")]
    InvalidBase64,
}

impl From<vodozemac::PickleError> for VodozemacError {
    fn from(err: vodozemac::PickleError) -> Self {
        VodozemacError::PickleError { msg: err.to_string() }
    }
}

impl From<vodozemac::DecodeError> for VodozemacError {
    fn from(err: vodozemac::DecodeError) -> Self {
        VodozemacError::DecodeError { msg: err.to_string() }
    }
}

impl From<vodozemac::LibolmPickleError> for VodozemacError {
    fn from(err: vodozemac::LibolmPickleError) -> Self {
        VodozemacError::LibolmPickleError { msg: err.to_string() }
    }
}

impl From<vodozemac::SessionCreationError> for VodozemacError {
    fn from(err: vodozemac::SessionCreationError) -> Self {
        VodozemacError::SessionCreationError { msg: err.to_string() }
    }
}

// Wrapper types for UniFFI compatibility

#[derive(uniffi::Record)]
pub struct IdentityKeysWrapper {
    pub curve25519: Vec<u8>,
    pub ed25519: Vec<u8>,
}

impl From<IdentityKeys> for IdentityKeysWrapper {
    fn from(keys: IdentityKeys) -> Self {
        Self {
            curve25519: keys.curve25519.to_bytes().to_vec(),
            ed25519: keys.ed25519.to_bytes().to_vec(),
        }
    }
}

#[derive(uniffi::Record)]
pub struct Curve25519PublicKeyWrapper {
    pub key: Vec<u8>,
}

impl From<Curve25519PublicKey> for Curve25519PublicKeyWrapper {
    fn from(key: Curve25519PublicKey) -> Self {
        Self { key: key.to_bytes().to_vec() }
    }
}

impl TryFrom<Curve25519PublicKeyWrapper> for Curve25519PublicKey {
    type Error = VodozemacError;
    
    fn try_from(wrapper: Curve25519PublicKeyWrapper) -> Result<Self, Self::Error> {
        let array: [u8; 32] = wrapper.key.try_into()
            .map_err(|_| VodozemacError::InvalidKey)?;
        Ok(Curve25519PublicKey::from(array))
    }
}

#[derive(uniffi::Record)]
pub struct Ed25519PublicKeyWrapper {
    pub key: Vec<u8>,
}

impl From<Ed25519PublicKey> for Ed25519PublicKeyWrapper {
    fn from(key: Ed25519PublicKey) -> Self {
        Self { key: key.to_bytes().to_vec() }
    }
}

impl TryFrom<Ed25519PublicKeyWrapper> for Ed25519PublicKey {
    type Error = VodozemacError;
    
    fn try_from(wrapper: Ed25519PublicKeyWrapper) -> Result<Self, Self::Error> {
        let array: [u8; 32] = wrapper.key.try_into()
            .map_err(|_| VodozemacError::InvalidKey)?;
        Ok(Ed25519PublicKey::from(array))
    }
}

#[derive(uniffi::Record)]
pub struct Ed25519SignatureWrapper {
    pub signature: Vec<u8>,
}

impl From<Ed25519Signature> for Ed25519SignatureWrapper {
    fn from(sig: Ed25519Signature) -> Self {
        Self { signature: sig.to_bytes().to_vec() }
    }
}

impl TryFrom<Ed25519SignatureWrapper> for Ed25519Signature {
    type Error = VodozemacError;
    
    fn try_from(wrapper: Ed25519SignatureWrapper) -> Result<Self, Self::Error> {
        let array: [u8; 64] = wrapper.signature.try_into()
            .map_err(|_| VodozemacError::InvalidSignature)?;
        Ok(Ed25519Signature::from(array))
    }
}

#[derive(uniffi::Record)]
pub struct SasBytesWrapper {
    pub bytes: Vec<u8>,
}

impl From<SasBytes> for SasBytesWrapper {
    fn from(sas_bytes: SasBytes) -> Self {
        Self { bytes: sas_bytes.to_vec() }
    }
}

#[derive(uniffi::Record)]
pub struct MacWrapper {
    pub mac: Vec<u8>,
}

impl From<Mac> for MacWrapper {
    fn from(mac: Mac) -> Self {
        Self { mac: mac.to_base64() }
    }
}

#[derive(uniffi::Record)]
pub struct CheckCodeWrapper {
    pub check_code: Vec<u8>,
}

impl From<CheckCode> for CheckCodeWrapper {
    fn from(check_code: CheckCode) -> Self {
        Self { check_code: check_code.to_bytes().to_vec() }
    }
}

#[derive(uniffi::Record)]
pub struct ExportedSessionKeyWrapper {
    pub key: String,
}

impl From<ExportedSessionKey> for ExportedSessionKeyWrapper {
    fn from(key: ExportedSessionKey) -> Self {
        Self { key: key.to_base64() }
    }
}

impl TryFrom<String> for ExportedSessionKey {
    type Error = VodozemacError;
    
    fn try_from(key: String) -> Result<Self, Self::Error> {
        ExportedSessionKey::from_base64(&key)
            .map_err(|_| VodozemacError::InvalidBase64)
    }
}

#[derive(uniffi::Record)]
pub struct InboundCreationResultWrapper {
    pub session: InboundGroupSessionWrapper,
    pub plaintext: String,
}

#[derive(uniffi::Record)]
pub struct DecryptedMessageWrapper {
    pub plaintext: String,
    pub message_index: u32,
}

// Main wrapper structs for UniFFI interfaces

#[derive(uniffi::Object)]
pub struct AccountWrapper {
    inner: Account,
}

#[uniffi::export]
impl AccountWrapper {
    #[uniffi::constructor]
    pub fn new() -> Self {
        Self { inner: Account::new() }
    }

    #[uniffi::constructor]
    pub fn from_pickle(pickle: String, passphrase: String) -> Result<Self, VodozemacError> {
        let account = Account::from_pickle(pickle, passphrase.as_bytes())?;
        Ok(Self { inner: account })
    }

    #[uniffi::constructor]
    pub fn from_libolm_pickle(pickle: String, passphrase: String) -> Result<Self, VodozemacError> {
        let account = Account::from_libolm_pickle(&pickle, &passphrase)?;
        Ok(Self { inner: account })
    }

    pub fn identity_keys(&self) -> IdentityKeysWrapper {
        self.inner.identity_keys().into()
    }

    pub fn ed25519_key(&self) -> Ed25519PublicKeyWrapper {
        self.inner.ed25519_key().into()
    }

    pub fn curve25519_key(&self) -> Curve25519PublicKeyWrapper {
        self.inner.curve25519_key().into()
    }

    pub fn sign(&self, message: String) -> Ed25519SignatureWrapper {
        self.inner.sign(&message).into()
    }

    pub fn one_time_keys(&self) -> HashMap<String, Curve25519PublicKeyWrapper> {
        self.inner.one_time_keys()
            .iter()
            .map(|(k, v)| (k.to_base64(), (*v).into()))
            .collect()
    }

    pub fn fallback_key(&self) -> HashMap<String, Curve25519PublicKeyWrapper> {
        [(
            self.inner.fallback_key().key_id().to_base64(),
            self.inner.fallback_key().public_key().into()
        )].into_iter().collect()
    }

    pub fn generate_one_time_keys(&mut self, count: u32) {
        self.inner.generate_one_time_keys(count as usize);
    }

    pub fn generate_fallback_key(&mut self) {
        self.inner.generate_fallback_key();
    }

    pub fn mark_keys_as_published(&mut self) {
        self.inner.mark_keys_as_published();
    }

    pub fn max_number_of_one_time_keys(&self) -> u32 {
        self.inner.max_number_of_one_time_keys() as u32
    }

    pub fn pickle(&self, passphrase: String) -> String {
        self.inner.pickle(passphrase.as_bytes())
    }

    pub fn create_outbound_session(
        &self,
        identity_key: Curve25519PublicKeyWrapper,
        one_time_key: Curve25519PublicKeyWrapper,
    ) -> Result<SessionWrapper, VodozemacError> {
        let identity = identity_key.try_into()?;
        let otk = one_time_key.try_into()?;
        let session = self.inner.create_outbound_session(SessionConfig::version_1(), identity, otk);
        Ok(SessionWrapper { inner: session })
    }

    pub fn create_inbound_session(
        &mut self,
        identity_key: Curve25519PublicKeyWrapper,
        message: String,
    ) -> Result<InboundCreationResultWrapper, VodozemacError> {
        let identity = identity_key.try_into()?;
        let olm_message = OlmMessage::from_base64(&message)?;
        let result = self.inner.create_inbound_session(identity, &olm_message)?;
        
        Ok(InboundCreationResultWrapper {
            session: SessionWrapper { inner: result.session }.into(),
            plaintext: result.plaintext,
        })
    }
}

#[derive(uniffi::Object)]
pub struct SessionWrapper {
    inner: Session,
}

#[uniffi::export]
impl SessionWrapper {
    #[uniffi::constructor]
    pub fn from_pickle(pickle: String, passphrase: String) -> Result<Self, VodozemacError> {
        let session = Session::from_pickle(pickle, passphrase.as_bytes())?;
        Ok(Self { inner: session })
    }

    #[uniffi::constructor]
    pub fn from_libolm_pickle(pickle: String, passphrase: String) -> Result<Self, VodozemacError> {
        let session = Session::from_libolm_pickle(&pickle, &passphrase)?;
        Ok(Self { inner: session })
    }

    pub fn session_id(&self) -> String {
        self.inner.session_id()
    }

    pub fn session_matches(&self, message: String) -> Result<bool, VodozemacError> {
        let olm_message = OlmMessage::from_base64(&message)?;
        Ok(self.inner.session_matches(&olm_message).is_some())
    }

    pub fn encrypt(&mut self, plaintext: String) -> String {
        self.inner.encrypt(&plaintext).to_base64()
    }

    pub fn decrypt(&mut self, message: String) -> Result<String, VodozemacError> {
        let olm_message = OlmMessage::from_base64(&message)?;
        Ok(self.inner.decrypt(&olm_message)?)
    }

    pub fn pickle(&self, passphrase: String) -> String {
        self.inner.pickle(passphrase.as_bytes())
    }
}

#[derive(uniffi::Object)]
pub struct GroupSessionWrapper {
    inner: GroupSession,
}

#[uniffi::export]
impl GroupSessionWrapper {
    #[uniffi::constructor]
    pub fn new() -> Self {
        Self { inner: GroupSession::new() }
    }

    #[uniffi::constructor]
    pub fn from_pickle(pickle: String, passphrase: String) -> Result<Self, VodozemacError> {
        let session = GroupSession::from_pickle(pickle, passphrase.as_bytes())?;
        Ok(Self { inner: session })
    }

    pub fn session_id(&self) -> String {
        self.inner.session_id()
    }

    pub fn session_key(&self) -> ExportedSessionKeyWrapper {
        self.inner.session_key().into()
    }

    pub fn message_index(&self) -> u32 {
        self.inner.message_index()
    }

    pub fn encrypt(&mut self, plaintext: String) -> String {
        self.inner.encrypt(&plaintext).to_base64()
    }

    pub fn pickle(&self, passphrase: String) -> String {
        self.inner.pickle(passphrase.as_bytes())
    }
}

#[derive(uniffi::Object)]
pub struct InboundGroupSessionWrapper {
    inner: InboundGroupSession,
}

#[uniffi::export]
impl InboundGroupSessionWrapper {
    #[uniffi::constructor]
    pub fn new(session_key: String, session_config: SessionOrdering) -> Result<Self, VodozemacError> {
        let key = ExportedSessionKey::try_from(session_key)?;
        let session = InboundGroupSession::new(&key, session_config);
        Ok(Self { inner: session })
    }

    #[uniffi::constructor]
    pub fn from_pickle(pickle: String, passphrase: String) -> Result<Self, VodozemacError> {
        let session = InboundGroupSession::from_pickle(pickle, passphrase.as_bytes())?;
        Ok(Self { inner: session })
    }

    #[uniffi::constructor]
    pub fn import(session_key: String) -> Result<Self, VodozemacError> {
        let key = ExportedSessionKey::try_from(session_key)?;
        let session = InboundGroupSession::import(&key);
        Ok(Self { inner: session })
    }

    pub fn session_id(&self) -> String {
        self.inner.session_id()
    }

    pub fn first_known_index(&self) -> u32 {
        self.inner.first_known_index()
    }

    pub fn decrypt(&mut self, message: String) -> Result<DecryptedMessageWrapper, VodozemacError> {
        let megolm_message = MegolmMessage::from_base64(&message)?;
        let result = self.inner.decrypt(&megolm_message)?;
        
        Ok(DecryptedMessageWrapper {
            plaintext: result.plaintext,
            message_index: result.message_index,
        })
    }

    pub fn export_at(&mut self, message_index: u32) -> Option<ExportedSessionKeyWrapper> {
        self.inner.export_at(message_index).map(|k| k.into())
    }

    pub fn pickle(&self, passphrase: String) -> String {
        self.inner.pickle(passphrase.as_bytes())
    }
}

#[derive(uniffi::Object)]
pub struct SasWrapper {
    inner: Sas,
}

#[uniffi::export]
impl SasWrapper {
    #[uniffi::constructor]
    pub fn new() -> Self {
        Self { inner: Sas::new() }
    }

    pub fn public_key(&self) -> Curve25519PublicKeyWrapper {
        self.inner.public_key().into()
    }

    pub fn diffie_hellman(&self, other_key: Curve25519PublicKeyWrapper) -> Result<EstablishedSasWrapper, VodozemacError> {
        let key = other_key.try_into()?;
        let established = self.inner.diffie_hellman(key)?;
        Ok(EstablishedSasWrapper { inner: established })
    }
}

#[derive(uniffi::Object)]
pub struct EstablishedSasWrapper {
    inner: EstablishedSas,
}

#[uniffi::export]
impl EstablishedSasWrapper {
    pub fn bytes(&self, info: String) -> SasBytesWrapper {
        self.inner.bytes(&info).into()
    }

    pub fn calculate_mac(&self, message: String, info: String) -> MacWrapper {
        self.inner.calculate_mac(&message, &info).into()
    }

    pub fn verify_mac(&self, message: String, info: String, tag: MacWrapper) -> Result<(), VodozemacError> {
        let mac_bytes = tag.mac;
        let mac_str = String::from_utf8(mac_bytes).map_err(|_| VodozemacError::InvalidMac)?;
        let mac = Mac::from_base64(&mac_str).map_err(|_| VodozemacError::InvalidMac)?;
        self.inner.verify_mac(&message, &info, &mac)?;
        Ok(())
    }

    pub fn generate_bytes_emoji(&self, sas_bytes: SasBytesWrapper) -> Vec<u32> {
        let bytes_array: [u8; 6] = sas_bytes.bytes.try_into().unwrap_or([0; 6]);
        let sas_bytes = SasBytes::from(bytes_array);
        sas_bytes.emoji_indices()
    }

    pub fn generate_bytes_decimal(&self, sas_bytes: SasBytesWrapper) -> Vec<u16> {
        let bytes_array: [u8; 5] = sas_bytes.bytes.try_into().unwrap_or([0; 5]);
        let sas_bytes = SasBytes::from(bytes_array);
        sas_bytes.decimals()
    }
}

#[derive(uniffi::Object)]
pub struct EciesWrapper {
    inner: Ecies,
}

#[uniffi::export]
impl EciesWrapper {
    #[uniffi::constructor]
    pub fn new() -> Self {
        Self { inner: Ecies::new() }
    }

    pub fn public_key(&self) -> Curve25519PublicKeyWrapper {
        self.inner.public_key().into()
    }

    pub fn diffie_hellman(&self, other_key: Curve25519PublicKeyWrapper) -> Result<EstablishedEciesWrapper, VodozemacError> {
        let key = other_key.try_into()?;
        let established = self.inner.diffie_hellman(key);
        Ok(EstablishedEciesWrapper { inner: established })
    }
}

#[derive(uniffi::Object)]
pub struct EstablishedEciesWrapper {
    inner: EstablishedEcies,
}

#[uniffi::export]
impl EstablishedEciesWrapper {
    pub fn encrypt(&self, plaintext: String) -> String {
        self.inner.encrypt(&plaintext).to_base64()
    }

    pub fn decrypt(&self, message: String) -> Result<String, VodozemacError> {
        let ciphertext = base64_decode(message)?;
        Ok(self.inner.decrypt(&ciphertext)?)
    }

    pub fn check_code(&self) -> CheckCodeWrapper {
        self.inner.check_code().into()
    }
}

// Standalone functions

#[uniffi::export]
pub fn base64_encode(input: Vec<u8>) -> String {
    vodozemac::base64_encode(input)
}

#[uniffi::export]
pub fn base64_decode(input: String) -> Result<Vec<u8>, VodozemacError> {
    vodozemac::base64_decode(input).map_err(|_| VodozemacError::InvalidBase64)
}

#[uniffi::export]
pub fn version() -> String {
    VERSION.to_string()
}
