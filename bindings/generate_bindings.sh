#!/bin/bash
set -e

echo "Cleaning cargo build..."
cargo clean

echo "Building crate..."
cargo build

echo "Cleaning generated directory..."
rm -f generated/*

echo "Generating Swift bindings..."
uniffi-bindgen generate --library ../target/debug/libvodozemac_bindings.dylib --language swift --out-dir generated

echo "Updating contract version from 30 to 29..."
sed -i '' 's/let bindings_contract_version = 30/let bindings_contract_version = 29/g' generated/vodozemac.swift

echo "Bindings generated successfully!"
echo "Swift bindings are in: generated/"
