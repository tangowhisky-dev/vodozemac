# Vodozemac Build Scripts Documentation

## Prerequisites

### Rust Toolchain Setup

1. **Install Rust**
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source $HOME/.cargo/env
   ```

2. **Install UniFFI CLI**
   ```bash
   cargo install uniffi_bindgen --version 0.29
   ```

3. **Verify Installation**
   ```bash
   rustc --version  # Should be 1.85+
   uniffi-bindgen --version  # Should be 0.29.x
   ```

### Target Platform Installation

#### iOS Targets
```bash
rustup target add aarch64-apple-ios          # iOS device (arm64)
rustup target add x86_64-apple-ios           # iOS simulator (Intel)
rustup target add aarch64-apple-ios-sim      # iOS simulator (Apple Silicon)
```

#### Android Targets
```bash
rustup target add aarch64-linux-android      # ARM64
rustup target add armv7-linux-androideabi    # ARMv7
rustup target add x86_64-linux-android       # x86_64 emulator
rustup target add i686-linux-android         # x86 emulator (optional)
```

### UniFFI CLI Verification

Ensure UniFFI is correctly installed and in PATH:
```bash
which uniffi-bindgen
/Users/tango16/.cargo/bin/uniffi-bindgen

uniffi-bindgen --help
```

## iOS Build Scripts

### Basic iOS Build

Create `scripts/build_ios.sh`:

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build/ios"

echo "Building vodozemac for iOS..."

# Clean previous builds
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cd "$PROJECT_ROOT/bindings/vodozemac_uniffi"

# Build for iOS device (ARM64)
echo "Building for iOS device (arm64)..."
cargo build --target aarch64-apple-ios --release

# Build for iOS simulator (x86_64)
echo "Building for iOS simulator (x86_64)..."
cargo build --target x86_64-apple-ios --release

# Build for iOS simulator (ARM64 - Apple Silicon Macs)
echo "Building for iOS simulator (arm64)..."
cargo build --target aarch64-apple-ios-sim --release

# Create universal binary for simulators
echo "Creating simulator universal binary..."
lipo -create \
    target/x86_64-apple-ios/release/libvodozemac_uniffi.a \
    target/aarch64-apple-ios-sim/release/libvodozemac_uniffi.a \
    -output "$BUILD_DIR/libvodozemac_uniffi_sim.a"

# Copy device binary
cp target/aarch64-apple-ios/release/libvodozemac_uniffi.a "$BUILD_DIR/libvodozemac_uniffi_device.a"

# Generate Swift bindings
echo "Generating Swift bindings..."
cd "$PROJECT_ROOT/bindings"
uniffi-bindgen generate \
  --language swift \
  --out-dir "$BUILD_DIR/swift" \
  --library vodozemac_uniffi/target/aarch64-apple-ios/release/libvodozemac_uniffi.a

echo "iOS build complete!"
echo "Device library: $BUILD_DIR/libvodozemac_uniffi_device.a"
echo "Simulator library: $BUILD_DIR/libvodozemac_uniffi_sim.a"
echo "Swift bindings: $BUILD_DIR/swift/"
```

### Advanced iOS Build with XCFramework

Create `scripts/build_xcframework.sh`:

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build/xcframework"
FRAMEWORK_NAME="Vodozemac"

echo "Building XCFramework for iOS..."

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cd "$PROJECT_ROOT/bindings/vodozemac_uniffi"

# Build all iOS targets
cargo build --target aarch64-apple-ios --release
cargo build --target x86_64-apple-ios --release
cargo build --target aarch64-apple-ios-sim --release

# Create framework structure for device
DEVICE_FRAMEWORK="$BUILD_DIR/ios-arm64/$FRAMEWORK_NAME.framework"
mkdir -p "$DEVICE_FRAMEWORK/Headers"
mkdir -p "$DEVICE_FRAMEWORK/Modules"

# Create framework structure for simulator
SIM_FRAMEWORK="$BUILD_DIR/ios-arm64_x86_64-simulator/$FRAMEWORK_NAME.framework"
mkdir -p "$SIM_FRAMEWORK/Headers"
mkdir -p "$SIM_FRAMEWORK/Modules"

# Create simulator universal binary
lipo -create \
    target/x86_64-apple-ios/release/libvodozemac_uniffi.a \
    target/aarch64-apple-ios-sim/release/libvodozemac_uniffi.a \
    -output "$SIM_FRAMEWORK/$FRAMEWORK_NAME"

# Copy device binary
cp target/aarch64-apple-ios/release/libvodozemac_uniffi.a "$DEVICE_FRAMEWORK/$FRAMEWORK_NAME"

# Generate bindings and copy headers
cd "$PROJECT_ROOT/bindings"
uniffi-bindgen generate \
  --language swift \
  --out-dir "$BUILD_DIR/swift" \
  --library vodozemac_uniffi/target/aarch64-apple-ios/release/libvodozemac_uniffi.a

# Copy headers to frameworks
cp "$BUILD_DIR/swift/vodozemacFFI.h" "$DEVICE_FRAMEWORK/Headers/"
cp "$BUILD_DIR/swift/vodozemacFFI.h" "$SIM_FRAMEWORK/Headers/"

# Create module maps
cat > "$DEVICE_FRAMEWORK/Modules/module.modulemap" << EOF
framework module $FRAMEWORK_NAME {
    header "vodozemacFFI.h"
    export *
}
EOF

cp "$DEVICE_FRAMEWORK/Modules/module.modulemap" "$SIM_FRAMEWORK/Modules/"

# Create Info.plist files
cat > "$DEVICE_FRAMEWORK/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>org.matrix.vodozemac</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>MinimumOSVersion</key>
    <string>13.0</string>
</dict>
</plist>
EOF

cp "$DEVICE_FRAMEWORK/Info.plist" "$SIM_FRAMEWORK/"

# Create XCFramework
xcodebuild -create-xcframework \
    -framework "$DEVICE_FRAMEWORK" \
    -framework "$SIM_FRAMEWORK" \
    -output "$BUILD_DIR/$FRAMEWORK_NAME.xcframework"

echo "XCFramework created: $BUILD_DIR/$FRAMEWORK_NAME.xcframework"
```

### Xcode Build Phase Integration

Add this Run Script phase to your Xcode project:

```bash
# Build script for Xcode integration
VODOZEMAC_ROOT="${SRCROOT}/../vodozemac"

if [ "$CONFIGURATION" = "Debug" ]; then
    RUST_BUILD_TYPE="debug"
else
    RUST_BUILD_TYPE="release"
fi

cd "$VODOZEMAC_ROOT/bindings/vodozemac_uniffi"

if [ "$ARCHS" = "arm64" ] && [ "$PLATFORM_NAME" = "iphoneos" ]; then
    cargo build --target aarch64-apple-ios --release
    cp "target/aarch64-apple-ios/release/libvodozemac_uniffi.a" "$CONFIGURATION_BUILD_DIR/"
elif [ "$PLATFORM_NAME" = "iphonesimulator" ]; then
    if [ "$ARCHS" = "arm64" ]; then
        cargo build --target aarch64-apple-ios-sim --release
        cp "target/aarch64-apple-ios-sim/release/libvodozemac_uniffi.a" "$CONFIGURATION_BUILD_DIR/"
    else
        cargo build --target x86_64-apple-ios --release
        cp "target/x86_64-apple-ios/release/libvodozemac_uniffi.a" "$CONFIGURATION_BUILD_DIR/"
    fi
fi
```

## Android Build Scripts

### Basic Android Build

Create `scripts/build_android.sh`:

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build/android"

# Verify Android NDK is available
if [ -z "$ANDROID_NDK_HOME" ]; then
    echo "Error: ANDROID_NDK_HOME is not set"
    exit 1
fi

echo "Building vodozemac for Android..."
echo "Using NDK: $ANDROID_NDK_HOME"

# Set up cross-compilation environment
export PATH="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH"

# Set up compiler environment variables
export CC_aarch64_linux_android="aarch64-linux-android21-clang"
export CC_armv7_linux_androideabi="armv7a-linux-androideabi21-clang" 
export CC_x86_64_linux_android="x86_64-linux-android21-clang"
export CC_i686_linux_android="i686-linux-android21-clang"

# Clean previous builds
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cd "$PROJECT_ROOT/bindings/vodozemac_uniffi"

# Build for each Android architecture
echo "Building for ARM64 (aarch64-linux-android)..."
cargo build --target aarch64-linux-android --release

echo "Building for ARMv7 (armv7-linux-androideabi)..."
cargo build --target armv7-linux-androideabi --release

echo "Building for x86_64 (x86_64-linux-android)..."
cargo build --target x86_64-linux-android --release

echo "Building for i686 (i686-linux-android)..."
cargo build --target i686-linux-android --release

# Create JNI library directory structure
mkdir -p "$BUILD_DIR/jniLibs/arm64-v8a"
mkdir -p "$BUILD_DIR/jniLibs/armeabi-v7a"
mkdir -p "$BUILD_DIR/jniLibs/x86_64"
mkdir -p "$BUILD_DIR/jniLibs/x86"

# Copy libraries to JNI structure
cp target/aarch64-linux-android/release/libvodozemac_uniffi.so "$BUILD_DIR/jniLibs/arm64-v8a/"
cp target/armv7-linux-androideabi/release/libvodozemac_uniffi.so "$BUILD_DIR/jniLibs/armeabi-v7a/"
cp target/x86_64-linux-android/release/libvodozemac_uniffi.so "$BUILD_DIR/jniLibs/x86_64/"
cp target/i686-linux-android/release/libvodozemac_uniffi.so "$BUILD_DIR/jniLibs/x86/"

# Generate Kotlin bindings
echo "Generating Kotlin bindings..."
cd "$PROJECT_ROOT/bindings"
uniffi-bindgen generate \
  --language kotlin \
  --out-dir "$BUILD_DIR/kotlin" \
  --library vodozemac_uniffi/target/aarch64-linux-android/release/libvodozemac_uniffi.so

echo "Android build complete!"
echo "Native libraries: $BUILD_DIR/jniLibs/"
echo "Kotlin bindings: $BUILD_DIR/kotlin/"
```

### Gradle Task Integration

Add to your `build.gradle.kts`:

```kotlin
val buildNativeLibs = task("buildNativeLibs") {
    group = "build"
    description = "Build native libraries for Android"
    
    doLast {
        exec {
            workingDir = rootProject.file("../vodozemac")
            commandLine = listOf("bash", "scripts/build_android.sh")
        }
    }
}

tasks.named("preBuild") {
    dependsOn(buildNativeLibs)
}

// Copy native libraries to correct locations
val copyNativeLibs = task<Copy>("copyNativeLibs") {
    dependsOn(buildNativeLibs)
    
    from("../vodozemac/build/android/jniLibs")
    into("src/main/jniLibs")
}

tasks.named("preBuild") {
    dependsOn(copyNativeLibs)
}
```

### NDK Configuration

Create `gradle.properties`:
```properties
android.useAndroidX=true
android.enableJetifier=true

# NDK configuration
android.ndkPath=/path/to/Android/sdk/ndk/25.2.9519653
android.ndkVersion=25.2.9519653

# Native build optimization
android.enableR8.fullMode=true
android.enableD8.desugaring=true
```

## Development Workflow

### Local Development Setup

1. **Environment Variables**
   ```bash
   # Add to ~/.zshrc or ~/.bash_profile
   export ANDROID_NDK_HOME="/path/to/Android/sdk/ndk/25.2.9519653"
   export PATH="$HOME/.cargo/bin:$PATH"
   
   # iOS development
   export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
   ```

2. **Development Build Script**
   ```bash
   #!/bin/bash
   # scripts/dev_build.sh
   set -e
   
   case "$1" in
       ios)
           echo "Building for iOS development..."
           ./scripts/build_ios.sh
           ;;
       android)
           echo "Building for Android development..."
           ./scripts/build_android.sh
           ;;
       all)
           echo "Building for all platforms..."
           ./scripts/build_ios.sh
           ./scripts/build_android.sh
           ;;
       *)
           echo "Usage: $0 {ios|android|all}"
           exit 1
           ;;
   esac
   ```

### Testing Across Platforms

1. **Run Reference Tests**
   ```bash
   cd bindings/tests/rust_reference
   cargo run > ../test_vectors.json
   ```

2. **Test iOS Bindings**
   ```bash
   cd bindings/tests/swift_tests
   swift test
   ```

3. **Test Android Bindings**
   ```bash
   cd bindings/tests/kotlin_tests
   ./gradlew test
   ```

### Debugging Build Issues

1. **Verbose Rust Building**
   ```bash
   RUST_LOG=debug cargo build --target aarch64-apple-ios --release -v
   ```

2. **Check Library Dependencies**
   ```bash
   # iOS
   otool -L libvodozemac_uniffi.a
   
   # Android
   readelf -d libvodozemac_uniffi.so
   ```

3. **Verify Target Installation**
   ```bash
   rustup target list --installed
   ```

### Performance Optimization

1. **Release Builds with LTO**
   ```toml
   # In Cargo.toml
   [profile.release]
   lto = true
   codegen-units = 1
   panic = "abort"
   ```

2. **Binary Size Optimization**
   ```bash
   # Strip symbols
   strip target/aarch64-apple-ios/release/libvodozemac_uniffi.a
   
   # Use `wee_alloc` for smaller binaries
   cargo add wee_alloc
   ```

## Continuous Integration

### GitHub Actions Example

Create `.github/workflows/build-bindings.yml`:

```yaml
name: Build UniFFI Bindings

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-ios:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Install Rust
      uses: actions-rs/toolchain@v1
      with:
        toolchain: stable
        target: aarch64-apple-ios
        override: true
        
    - name: Install iOS targets
      run: |
        rustup target add aarch64-apple-ios
        rustup target add x86_64-apple-ios
        rustup target add aarch64-apple-ios-sim
        
    - name: Install UniFFI
      run: cargo install uniffi_bindgen --version 0.29
      
    - name: Build iOS
      run: ./scripts/build_ios.sh
      
    - name: Upload iOS artifacts
      uses: actions/upload-artifact@v4
      with:
        name: ios-bindings
        path: build/ios/

  build-android:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Android NDK
      uses: nttld/setup-ndk@v1
      with:
        ndk-version: r25c
        
    - name: Install Rust
      uses: actions-rs/toolchain@v1
      with:
        toolchain: stable
        override: true
        
    - name: Install Android targets
      run: |
        rustup target add aarch64-linux-android
        rustup target add armv7-linux-androideabi
        rustup target add x86_64-linux-android
        rustup target add i686-linux-android
        
    - name: Install UniFFI
      run: cargo install uniffi_bindgen --version 0.29
      
    - name: Build Android
      run: ./scripts/build_android.sh
      env:
        ANDROID_NDK_HOME: ${{ steps.setup-ndk.outputs.ndk-path }}
        
    - name: Upload Android artifacts
      uses: actions/upload-artifact@v4
      with:
        name: android-bindings
        path: build/android/

  test:
    needs: [build-ios, build-android]
    strategy:
      matrix:
        platform: [ios, android]
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Download artifacts
      uses: actions/download-artifact@v4
      with:
        name: ${{ matrix.platform }}-bindings
        path: build/${{ matrix.platform }}/
        
    - name: Run tests
      run: |
        case "${{ matrix.platform }}" in
          ios)
            cd bindings/tests/swift_tests
            swift test
            ;;
          android)
            cd bindings/tests/kotlin_tests
            ./gradlew test
            ;;
        esac
```

### Build Matrix Configuration

For comprehensive testing across platforms:

```yaml
strategy:
  matrix:
    include:
      - os: macos-latest
        target: aarch64-apple-ios
        platform: ios
      - os: macos-latest  
        target: x86_64-apple-ios
        platform: ios-sim
      - os: ubuntu-latest
        target: aarch64-linux-android
        platform: android-arm64
      - os: ubuntu-latest
        target: armv7-linux-androideabi
        platform: android-arm
      - os: ubuntu-latest
        target: x86_64-linux-android
        platform: android-x64
```

### Artifact Management

Store and version build artifacts:

```yaml
- name: Upload release artifacts
  if: github.event_name == 'release'
  uses: actions/upload-release-asset@v1
  with:
    upload_url: ${{ github.event.release.upload_url }}
    asset_path: build/release/vodozemac-${{ matrix.platform }}.zip
    asset_name: vodozemac-${{ matrix.platform }}.zip
    asset_content_type: application/zip
```

### Release Automation

Automate releases with semantic versioning:

```yaml
- name: Create Release
  if: github.ref == 'refs/heads/main'
  uses: actions/create-release@v1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    tag_name: v${{ steps.version.outputs.version }}
    release_name: Release v${{ steps.version.outputs.version }}
    body: |
      ## Changes
      - UniFFI bindings for iOS and Android
      - Cross-platform test coverage
      - Performance optimizations
    draft: false
    prerelease: false
```
