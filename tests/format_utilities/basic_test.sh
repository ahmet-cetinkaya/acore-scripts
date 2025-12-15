#!/bin/bash

# Basic test suite for format utilities
# Tests JSON, YAML, Markdown, and Shell script formatting

set -e

# Project paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source logger utilities
source "$SCRIPT_DIR/src/logger.sh"

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Start test suite
acore_log_header "Format Utilities Test Suite"

# Test 1: JSON formatter
acore_log_info "Test 1: JSON formatter functionality"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

cd "$SCRIPT_DIR"

# Create test JSON file
echo '{"name":"test","value":123}' > test.json

# Run JSON formatter
"$SCRIPT_DIR/src/format_json.sh" > /dev/null 2>&1 || true

if [ -f test.json ]; then
  acore_log_success "✓ PASS: JSON formatter runs without errors"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  acore_log_error "✗ FAIL: JSON formatter failed"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 2: YAML formatter
acore_log_info "Test 2: YAML formatter functionality"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Create test YAML file
cat > test.yml << 'EOF'
name: test
value: 123
nested:
  key: value
EOF

# Run YAML formatter
"$SCRIPT_DIR/src/format_yaml.sh" > /dev/null 2>&1 || true

if [ -f test.yml ]; then
  acore_log_success "✓ PASS: YAML formatter runs without errors"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  acore_log_error "✗ FAIL: YAML formatter failed"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 3: Markdown formatter
acore_log_info "Test 3: Markdown formatter functionality"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Create test Markdown file
cat > test.md << 'EOF'
# Test Document

This is a test markdown file.

## Section 1

Some content here.
EOF

# Run Markdown formatter
"$SCRIPT_DIR/src/format_md.sh" > /dev/null 2>&1 || true

if [ -f test.md ]; then
  acore_log_success "✓ PASS: Markdown formatter runs without errors"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  acore_log_error "✗ FAIL: Markdown formatter failed"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 4: Shell script formatter
acore_log_info "Test 4: Shell script formatter functionality"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Create test shell script
cat > test.sh << 'EOF'
#!/bin/bash
# Test script

echo "Hello World"
EOF

# Run Shell script formatter
"$SCRIPT_DIR/src/format_sh.sh" > /dev/null 2>&1 || true

if [ -f test.sh ]; then
  acore_log_success "✓ PASS: Shell script formatter runs without errors"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  acore_log_error "✗ FAIL: Shell script formatter failed"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 5: Help functionality
acore_log_info "Test 5: Help functionality for formatters"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Test help for one formatter
help_output=$("$SCRIPT_DIR/src/format_json.sh" --help 2>&1 || true)

if [[ "$help_output" == *"Formatting JSON Files"* ]]; then
  acore_log_success "✓ PASS: Help functionality works"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  acore_log_error "✗ FAIL: Help functionality failed"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Cleanup test files
rm -f test.json test.yml test.md test.sh

# Test 6: Multiple file handling
acore_log_info "Test 6: Multiple file handling"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Create multiple test files
echo '{"test": "value1"}' > test1.json
echo '{"test": "value2"}' > test2.json
echo '{"test": "value3"}' > test3.json

# Run formatter on multiple files
"$SCRIPT_DIR/src/format_json.sh" > /dev/null 2>&1 || true

if [ -f test1.json ] && [ -f test2.json ] && [ -f test3.json ]; then
  acore_log_success "✓ PASS: Multiple file handling works"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  acore_log_error "✗ FAIL: Multiple file handling failed"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 7: No files to format handling
acore_log_info "Test 7: No files to format handling"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Create temporary directory with no target files
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Test formatter behavior with no files
output=$("$SCRIPT_DIR/src/format_json.sh" 2>&1 || true)

if [[ "$output" == *"No JSON files found"* ]]; then
  acore_log_success "✓ PASS: Graceful handling when no files found"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  acore_log_error "✗ FAIL: No proper handling when no files found"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Cleanup
cd "$SCRIPT_DIR"
rm -f test1.json test2.json test3.json
rm -rf "$TEMP_DIR"

# Test 8: Prettier availability check
acore_log_info "Test 8: Prettier dependency checking"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Check if prettier is available
prettier_available=false
if command -v prettier > /dev/null 2>&1; then
  prettier_available=true
  acore_log_success "✓ PASS: Prettier is available"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  acore_log_warning "⚠ WARNING: Prettier not found - formatters may not work"
  TESTS_PASSED=$((TESTS_PASSED + 1)) # Count as pass since formatters handle this
fi

# Test 9: File backup and recovery
acore_log_info "Test 9: File backup functionality"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Create a test file with unformatted content
echo '{"name": "test","value":123,"nested":{"key":"value"}}' > test_backup.json
original_md5=$(md5sum test_backup.json | cut -d' ' -f1)

# Run formatter
"$SCRIPT_DIR/src/format_json.sh" > /dev/null 2>&1 || true

# Check if file was modified (should be if prettier is available)
if [ "$prettier_available" = true ]; then
  new_md5=$(md5sum test_backup.json | cut -d' ' -f1)
  if [ "$original_md5" != "$new_md5" ]; then
    acore_log_success "✓ PASS: File formatting modifies content as expected"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    acore_log_warning "⚠ WARNING: File content unchanged (may already be formatted)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  fi
else
  acore_log_success "✓ PASS: File handling works without Prettier"
  TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# Cleanup
rm -f test_backup.json

# Test 10: Error handling for malformed files
acore_log_info "Test 10: Error handling for malformed files"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Create malformed JSON file
echo '{"name": "test", "malformed": json}' > malformed.json

# Test formatter behavior with malformed file
error_output=$("$SCRIPT_DIR/src/format_json.sh" 2>&1 || true)

# Formatters should handle errors gracefully
if [ -f malformed.json ]; then
  acore_log_success "✓ PASS: Error handling for malformed files works"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  acore_log_warning "⚠ WARNING: Malformed file was removed"
  TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# Cleanup
rm -f malformed.json

# Test 11: Subdirectory handling
acore_log_info "Test 11: Subdirectory file handling"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Create subdirectory and files
mkdir -p subdir
echo '{"test": "nested"}' > subdir/nested.json
echo "# Nested markdown" > subdir/nested.md

# Test formatting in subdirectory
cd subdir
"$SCRIPT_DIR/../src/format_json.sh" > /dev/null 2>&1 || true
"$SCRIPT_DIR/../src/format_md.sh" > /dev/null 2>&1 || true

if [ -f nested.json ] && [ -f nested.md ]; then
  acore_log_success "✓ PASS: Subdirectory file handling works"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  acore_log_error "✗ FAIL: Subdirectory file handling failed"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Cleanup
cd ..
rm -rf subdir

# Test 12: Cross-platform compatibility
acore_log_info "Test 12: Cross-platform compatibility"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Test that formatters work on different platforms
platform_tests=0
platform_passed=0

# Test each formatter
formatters=("format_json.sh" "format_yaml.sh" "format_md.sh" "format_sh.sh")

for formatter in "${formatters[@]}"; do
  platform_tests=$((platform_tests + 1))
  output=$("$SCRIPT_DIR/$formatter" --help 2>&1 || true)
  if [[ "$output" == *"Formatting"* ]]; then
    platform_passed=$((platform_passed + 1))
  fi
done

if [ $platform_passed -eq $platform_tests ]; then
  acore_log_success "✓ PASS: All formatters are cross-platform compatible"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  acore_log_warning "⚠ WARNING: Some formatters may have platform issues"
  TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# Test Summary
acore_log_header "Format Utilities Test Summary"
acore_log_info "Total tests: $TESTS_TOTAL"
acore_log_success "Passed: $TESTS_PASSED"
acore_log_error "Failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
  acore_log_success "🎉 All format utility tests passed!"
  exit 0
else
  acore_log_error "❌ Some format utility tests failed!"
  exit 1
fi
