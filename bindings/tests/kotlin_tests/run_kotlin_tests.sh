#!/bin/bash
set -e

echo "🔧 Kotlin Test Runner for Vodozemac Bindings"
echo "==========# Check and copy native libraries (dylib files)
echo "📋 Copying native libraries to test resources..."
mkdir -p "$KOTLIN_TESTS_DIR/src/main/resources"

# If force refresh, remove existing libraries
if [ "$FORCE_REFRESH" = true ]; then
    echo "  🧹 Removing existing library files for refresh..."
    rm -f "$KOTLIN_TESTS_DIR/src/main/resources/"*.dylib 2>/dev/null || true
fi

# Copy all dylib files from generated/kotlin directory
DYLIB_COUNT=0
if [ -d "$GENERATED_DIR" ]; then
    for dylib_file in "$GENERATED_DIR"/*.dylib; do
        if [ -f "$dylib_file" ]; then
            echo "  📦 Copying $(basename "$dylib_file")..."
            cp "$dylib_file" "$KOTLIN_TESTS_DIR/src/main/resources/"
            DYLIB_COUNT=$((DYLIB_COUNT + 1))
        fi
    done======================"

# Parse command line arguments
FORCE_REFRESH=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --force-refresh|-f)
            FORCE_REFRESH=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --force-refresh, -f    Force refresh of all libraries and bindings"
            echo "  --help, -h            Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

if [ "$FORCE_REFRESH" = true ]; then
    echo "🔄 Force refresh mode enabled - will update all libraries and bindings"
fi

# Determine script location and project paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KOTLIN_TESTS_DIR="$SCRIPT_DIR"
BINDINGS_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"
GENERATED_DIR="$BINDINGS_ROOT/generated/kotlin"
TEST_VECTORS_PATH="$BINDINGS_ROOT/tests/test_vectors.json"

echo "📁 Project paths:"
echo "  Kotlin tests: $KOTLIN_TESTS_DIR"
echo "  Generated bindings: $GENERATED_DIR"
echo "  Test vectors: $TEST_VECTORS_PATH"

# Check if Gradle wrapper exists, otherwise use system gradle
if [ -f "$KOTLIN_TESTS_DIR/gradlew" ]; then
    GRADLE_CMD="./gradlew"
    echo "🔧 Using Gradle wrapper"
else
    GRADLE_CMD="gradle"
    echo "🔧 Using system Gradle"
fi

# Verify required files exist
echo "🔍 Verifying prerequisites..."
if [ ! -d "$GENERATED_DIR" ]; then
    echo "❌ Error: Generated Kotlin bindings not found at $GENERATED_DIR"
    echo "Please run generate_bindings.sh first to generate Kotlin bindings"
    exit 1
fi

if [ ! -f "$TEST_VECTORS_PATH" ]; then
    echo "❌ Error: Test vectors not found at $TEST_VECTORS_PATH"
    exit 1
fi

# Check if bindings are copied to test structure
if [ ! -d "$KOTLIN_TESTS_DIR/src/main/kotlin/uniffi" ] || [ "$FORCE_REFRESH" = true ]; then
    echo "📋 Copying generated Kotlin bindings to test structure..."
    mkdir -p "$KOTLIN_TESTS_DIR/src/main/kotlin"
    rm -rf "$KOTLIN_TESTS_DIR/src/main/kotlin/uniffi" 2>/dev/null || true
    cp -r "$GENERATED_DIR/uniffi" "$KOTLIN_TESTS_DIR/src/main/kotlin/"
    echo "✅ Kotlin bindings updated in test structure"
else
    echo "✅ Kotlin bindings found in test structure"
fi

# Check if test vectors are copied to test resources
if [ ! -f "$KOTLIN_TESTS_DIR/src/test/resources/test_vectors.json" ] || [ "$FORCE_REFRESH" = true ]; then
    echo "📋 Copying test vectors to test resources..."
    mkdir -p "$KOTLIN_TESTS_DIR/src/test/resources"
    cp "$TEST_VECTORS_PATH" "$KOTLIN_TESTS_DIR/src/test/resources/"
    echo "✅ Test vectors updated in test resources"
else
    echo "✅ Test vectors found in test resources"
fi

# Check and copy native libraries (dylib files)
echo "📋 Copying native libraries to test resources..."
mkdir -p "$KOTLIN_TESTS_DIR/src/main/resources"

# Copy all dylib files from generated/kotlin directory
DYLIB_COUNT=0
if [ -d "$GENERATED_DIR" ]; then
    for dylib_file in "$GENERATED_DIR"/*.dylib; do
        if [ -f "$dylib_file" ]; then
            echo "  � Copying $(basename "$dylib_file")..."
            cp "$dylib_file" "$KOTLIN_TESTS_DIR/src/main/resources/"
            DYLIB_COUNT=$((DYLIB_COUNT + 1))
        fi
    done
    
    if [ $DYLIB_COUNT -gt 0 ]; then
        echo "✅ Successfully copied $DYLIB_COUNT native library files"
        echo "  📍 Libraries available in: $KOTLIN_TESTS_DIR/src/main/resources/"
        ls -la "$KOTLIN_TESTS_DIR/src/main/resources/"*.dylib 2>/dev/null || true
        
        # Ensure libraries have proper permissions
        chmod 755 "$KOTLIN_TESTS_DIR/src/main/resources/"*.dylib 2>/dev/null || true
        
        # Verify library architecture compatibility
        echo "  🔍 Verifying library architecture..."
        for lib in "$KOTLIN_TESTS_DIR/src/main/resources/"*.dylib; do
            if [ -f "$lib" ]; then
                echo "    $(basename "$lib"): $(file "$lib" | cut -d: -f2-)"
            fi
        done
    else
        echo "⚠️  No dylib files found in $GENERATED_DIR"
        echo "Please ensure generate_bindings.sh has been run to create the native libraries"
    fi
else
    echo "❌ Generated directory not found: $GENERATED_DIR"
    exit 1
fi

# Change to kotlin tests directory
cd "$KOTLIN_TESTS_DIR"

# Clean and build
echo "🧹 Cleaning previous build..."
$GRADLE_CMD clean

echo "🔨 Building Kotlin tests..."
$GRADLE_CMD build --info

# Run tests
echo "🧪 Running Kotlin tests..."
echo ""
echo "Running all test suites:"
echo "  - VodozemacAPITest (API functionality)"
echo "  - VodozemacComprehensiveTest (test vectors)"
echo "  - BasicLoadTest (library loading)"
echo ""

$GRADLE_CMD test --info

# Display test results
echo ""
echo "📊 Test Results Summary:"
echo "========================"

# Check if test results exist and display them
TEST_RESULTS_DIR="$KOTLIN_TESTS_DIR/build/test-results/test"
if [ -d "$TEST_RESULTS_DIR" ]; then
    echo "📁 Test results available at: $TEST_RESULTS_DIR"
    
    # Count test results from XML files
    if command -v xmllint >/dev/null 2>&1; then
        total_tests=0
        failed_tests=0
        for xml_file in "$TEST_RESULTS_DIR"/*.xml; do
            if [ -f "$xml_file" ]; then
                tests=$(xmllint --xpath "//testsuite/@tests" "$xml_file" 2>/dev/null | grep -o 'tests="[0-9]*"' | grep -o '[0-9]*' || echo "0")
                failures=$(xmllint --xpath "//testsuite/@failures" "$xml_file" 2>/dev/null | grep -o 'failures="[0-9]*"' | grep -o '[0-9]*' || echo "0")
                total_tests=$((total_tests + tests))
                failed_tests=$((failed_tests + failures))
            fi
        done
        
        if [ $total_tests -gt 0 ]; then
            passed_tests=$((total_tests - failed_tests))
            echo "✅ Tests passed: $passed_tests/$total_tests"
            if [ $failed_tests -gt 0 ]; then
                echo "❌ Tests failed: $failed_tests"
                echo ""
                echo "🔍 For detailed failure information, check:"
                echo "  $KOTLIN_TESTS_DIR/build/reports/tests/test/index.html"
            fi
        fi
    else
        echo "📋 Test results XML files are available for detailed analysis"
    fi
    
    # Show HTML report if available
    HTML_REPORT="$KOTLIN_TESTS_DIR/build/reports/tests/test/index.html"
    if [ -f "$HTML_REPORT" ]; then
        echo "📊 HTML test report: file://$HTML_REPORT"
    fi
else
    echo "⚠️  Test results directory not found"
fi

echo ""
echo "🎉 Kotlin test execution completed!"
echo "For more detailed output, run: $GRADLE_CMD test --info --stacktrace"
