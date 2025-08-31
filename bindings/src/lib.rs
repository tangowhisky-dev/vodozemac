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

uniffi::include_scaffolding!("vodozemac");

#[cfg(test)]
mod test_bindings;
