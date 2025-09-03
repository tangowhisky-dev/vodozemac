#!/bin/bash
set -e

echo "Cleaning cargo build..."
cargo clean

echo "Building crate..."
cargo build

echo "Cleaning generated directory..."
rm -rf generated/swift
mkdir -p generated/swift

echo "Generating Swift bindings..."
uniffi-bindgen generate --library ../target/debug/libvodozemac_bindings.dylib --language swift --out-dir generated/swift

echo "Updating contract version from 30 to 29..."
sed -i '' 's/let bindings_contract_version = 30/let bindings_contract_version = 29/g' generated/swift/vodozemac.swift

echo "Bindings generated successfully!"
echo "Swift bindings are in: generated/swift/"
