#!/bin/bash
set -e

echo "Building UniFFI crate..."
cd vodozemac_uniffi
cargo build --release
cd ..

echo "Generating Swift bindings..."
/Users/tango16/.cargo/bin/uniffi-bindgen generate vodozemac.udl \
  --language swift \
  --out-dir swift/ \
  --lib-file vodozemac_uniffi/target/release/libvodozemac_uniffi.a

echo "Generating Kotlin bindings..."  
/Users/tango16/.cargo/bin/uniffi-bindgen generate vodozemac.udl \
  --language kotlin \
  --out-dir kotlin/ \
  --lib-file vodozemac_uniffi/target/release/libvodozemac_uniffi.so

echo "Bindings generated successfully!"
echo "Swift bindings are in: swift/"
echo "Kotlin bindings are in: kotlin/"
