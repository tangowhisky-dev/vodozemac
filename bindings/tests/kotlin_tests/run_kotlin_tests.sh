#!/bin/bash
set -e

echo "🔧 Kotlin Test Runner for Vodozemac Bindings"
echo "=============================================="

# Set paths
KOTLIN_TESTS_DIR="/Users/tango16/code/vodozemac/bindings/tests/kotlin_tests"
BINDINGS_DIR="/Users/tango16/code/vodozemac/bindings/generated/kotlin"
TEST_VECTORS_PATH="/Users/tango16/code/vodozemac/bindings/tests/test_vectors.json"

echo "📁 Setting up test environment..."

# Create build directory
mkdir -p "$KOTLIN_TESTS_DIR/build/classes"
mkdir -p "$KOTLIN_TESTS_DIR/build/resources"

# Copy test vectors
echo "📋 Copying test vectors..."
cp "$TEST_VECTORS_PATH" "$KOTLIN_TESTS_DIR/build/resources/"

# Set library path for JNA
export JAVA_LIBRARY_PATH="$BINDINGS_DIR"
echo "🔗 Library path: $JAVA_LIBRARY_PATH"

# Download required JARs if not present
echo "📦 Downloading required libraries..."
LIBS_DIR="$KOTLIN_TESTS_DIR/libs"
mkdir -p "$LIBS_DIR"

# JNA
if [ ! -f "$LIBS_DIR/jna-5.13.0.jar" ]; then
    curl -L "https://repo1.maven.org/maven2/net/java/dev/jna/jna/5.13.0/jna-5.13.0.jar" -o "$LIBS_DIR/jna-5.13.0.jar"
fi

# JUnit
if [ ! -f "$LIBS_DIR/junit-4.13.2.jar" ]; then
    curl -L "https://repo1.maven.org/maven2/junit/junit/4.13.2/junit-4.13.2.jar" -o "$LIBS_DIR/junit-4.13.2.jar"
fi

# Hamcrest (required by JUnit)
if [ ! -f "$LIBS_DIR/hamcrest-core-1.3.jar" ]; then
    curl -L "https://repo1.maven.org/maven2/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar" -o "$LIBS_DIR/hamcrest-core-1.3.jar"
fi

# Kotlin serialization
if [ ! -f "$LIBS_DIR/kotlinx-serialization-json-jvm-1.6.0.jar" ]; then
    curl -L "https://repo1.maven.org/maven2/org/jetbrains/kotlinx/kotlinx-serialization-json-jvm/1.6.0/kotlinx-serialization-json-jvm-1.6.0.jar" -o "$LIBS_DIR/kotlinx-serialization-json-jvm-1.6.0.jar"
fi

# Kotlin serialization core
if [ ! -f "$LIBS_DIR/kotlinx-serialization-core-jvm-1.6.0.jar" ]; then
    curl -L "https://repo1.maven.org/maven2/org/jetbrains/kotlinx/kotlinx-serialization-core-jvm/1.6.0/kotlinx-serialization-core-jvm-1.6.0.jar" -o "$LIBS_DIR/kotlinx-serialization-core-jvm-1.6.0.jar"
fi

# Build classpath
CLASSPATH="$LIBS_DIR/jna-5.13.0.jar:$LIBS_DIR/junit-4.13.2.jar:$LIBS_DIR/hamcrest-core-1.3.jar:$LIBS_DIR/kotlinx-serialization-json-jvm-1.6.0.jar:$LIBS_DIR/kotlinx-serialization-core-jvm-1.6.0.jar:$KOTLIN_TESTS_DIR/build/classes:$KOTLIN_TESTS_DIR/build/resources"

echo "🔨 Compiling Kotlin sources..."

# Compile generated bindings
kotlinc -cp "$CLASSPATH" "$BINDINGS_DIR/uniffi/vodozemac/vodozemac.kt" -d "$KOTLIN_TESTS_DIR/build/classes"

# Compile test sources
kotlinc -cp "$CLASSPATH" "$KOTLIN_TESTS_DIR/src/test/kotlin/"*.kt -d "$KOTLIN_TESTS_DIR/build/classes"

echo "▶️ Running tests..."

# Run tests
java -cp "$CLASSPATH" -Djava.library.path="$JAVA_LIBRARY_PATH" \
    org.junit.runner.JUnitCore \
    org.matrix.vodozemac.test.VodozemacComprehensiveTest

echo ""
echo "✅ All tests completed!"
