# Makefile for Vodozemac UniFFI Bindings
# 
# Common commands for building and testing the vodozemac Swift bindings

# Instead of hardcoding a user‐specific path:
# UNIFFI_CLI = /Users/tango16/.cargo/bin/uniffi-bindgen

# Dynamically find uniffi-bindgen in PATH (unless overridden) and fail fast if missing
UNIFFI_CLI ?= $(shell command -v uniffi-bindgen 2>/dev/null)

ifeq ($(UNIFFI_CLI),)
$(error "uniffi-bindgen not found in PATH. Install via `cargo install uniffi_bindgen` or set UNIFFI_CLI=/path/to/uniffi-bindgen")
endif
LIBRARY_DEBUG = ../target/debug/libvodozemac_bindings.dylib
LIBRARY_RELEASE = ../target/release/libvodozemac_bindings.dylib
GENERATED_DIR = ./generated/swift

.PHONY: all clean build generate test swift-test help

# Default target
all: generate

# Show help
help:
	@echo "Vodozemac UniFFI Bindings - Available Commands:"
	@echo ""
	@echo "  make build          - Build the Rust library (debug)"
	@echo "  make build-release  - Build the Rust library (release)"
	@echo "  make generate       - Generate Swift bindings (debug)"
	@echo "  make generate-release - Generate Swift bindings (release)"
	@echo "  make test           - Run Rust tests"
	@echo "  make swift-test     - Run Swift test script"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make rebuild        - Clean, build, and generate"
	@echo "  make verify         - Full verification (build + generate + test)"
	@echo ""

# Build the Rust library (debug)
build:
	@echo "🔨 Building vodozemac bindings (debug)..."
	cargo build

# Build the Rust library (release)
build-release:
	@echo "🔨 Building vodozemac bindings (release)..."
	cargo build --release

# Generate Swift bindings (debug)
generate: build
	@echo "🏗️  Generating Swift bindings (debug)..."
	mkdir -p $(GENERATED_DIR)
	$(UNIFFI_CLI) generate --library $(LIBRARY_DEBUG) --language swift --out-dir $(GENERATED_DIR)
	@echo "🔧 Updating contract version from 30 to 29..."
	sed -i '' 's/let bindings_contract_version = 30/let bindings_contract_version = 29/g' $(GENERATED_DIR)/vodozemac.swift
	@echo "✅ Swift bindings generated in $(GENERATED_DIR)"

# Generate Swift bindings (release)
generate-release: build-release
	@echo "🏗️  Generating Swift bindings (release)..."
	mkdir -p $(GENERATED_DIR)
	$(UNIFFI_CLI) generate --library $(LIBRARY_RELEASE) --language swift --out-dir $(GENERATED_DIR)
	@echo "🔧 Updating contract version from 30 to 29..."
	sed -i '' 's/let bindings_contract_version = 30/let bindings_contract_version = 29/g' $(GENERATED_DIR)/vodozemac.swift

# Run Swift test script (requires bindings to be generated)
swift-test: generate
	@echo "🧪 Running Swift integration test..."
	cd $(GENERATED_DIR) && swift -I . -L ../../target/debug -Xlinker -rpath -Xlinker ../../target/debug -lvodozemac_bindings ../test_bindings.swift

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	cargo clean
	rm -rf ./generated
	@echo "✅ Clean complete"

# Rebuild everything
rebuild: clean generate
	@echo "🔄 Rebuild complete"

# Full verification
verify: build generate test swift-test
	@echo "✅ Full verification complete!"
	@echo ""
	@echo "📋 Summary:"
	@echo "  - Rust library built successfully"
	@echo "  - Swift bindings generated"  
	@echo "  - Rust tests passed"
	@echo "  - Swift integration test passed"
	@echo ""
	@echo "🚀 Ready for Xcode integration!"

# Show generated files
show-generated:
	@echo "📁 Generated files:"
	@ls -la $(GENERATED_DIR) 2>/dev/null || echo "No generated files found. Run 'make generate' first."

# Check UniFFI CLI version
check-uniffi:
	@echo "🔍 UniFFI CLI Information:"
	@echo "Path: $(UNIFFI_CLI)"
	@$(UNIFFI_CLI) --version 2>/dev/null || echo "UniFFI CLI not found at $(UNIFFI_CLI)"

# Development target - watch for changes and regenerate
watch:
	@echo "👀 Watching for changes... (Press Ctrl+C to stop)"
	@echo "This requires 'entr' to be installed: brew install entr"
	find src/ -name "*.rs" | entr make generate
