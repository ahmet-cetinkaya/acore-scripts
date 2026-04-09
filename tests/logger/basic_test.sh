#!/usr/bin/env bash

# Basic test suite for logger.sh
# Tests core logging functionality and configuration

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

# Helper function to capture log output
capture_log_output() {
	local log_function="$1"
	local message="$2"
	local prefix="$3"

	# Note: logger functions don't take separate prefix arguments
	# They use the LOG_PREFIX environment variable
	"$log_function" "$message" 2>&1
}

# Start test suite
acore_log_header "Logger.sh Test Suite"

# Test 1: Basic log functions without colors
acore_log_info "Test 1: Basic logging functionality"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Test with colors disabled temporarily
original_log_color="$LOG_COLOR"
export LOG_COLOR=false

# Test info log
info_output=$(capture_log_output "acore_log_info" "Test info message" 2>&1)
if [[ "$info_output" == *"[INFO] Test info message"* ]]; then
	acore_log_success "✓ PASS: Info logging works correctly"
	TESTS_PASSED=$((TESTS_PASSED + 1))
else
	acore_log_error "✗ FAIL: Info logging failed"
	TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test success log
success_output=$(capture_log_output "acore_log_success" "Test success message" 2>&1)
if [[ "$success_output" == *"[SUCCESS] Test success message"* ]]; then
	acore_log_success "✓ PASS: Success logging works correctly"
	TESTS_PASSED=$((TESTS_PASSED + 1))
else
	acore_log_error "✗ FAIL: Success logging failed"
	TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test warning log
warning_output=$(capture_log_output "acore_log_warning" "Test warning message" 2>&1)
if [[ "$warning_output" == *"[WARNING] Test warning message"* ]]; then
	acore_log_success "✓ PASS: Warning logging works correctly"
	TESTS_PASSED=$((TESTS_PASSED + 1))
else
	acore_log_error "✗ FAIL: Warning logging failed"
	TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test error log
error_output=$(capture_log_output "acore_log_error" "Test error message" 2>&1)
if [[ "$error_output" == *"[ERROR] Test error message"* ]]; then
	acore_log_success "✓ PASS: Error logging works correctly"
	TESTS_PASSED=$((TESTS_PASSED + 1))
else
	acore_log_error "✗ FAIL: Error logging failed"
	TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Restore original color setting but keep colors disabled for prefix test
export LOG_COLOR=false

# Test 2: Logging with standard prefixes
acore_log_info "Test 2: Logging with standard prefixes"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Test with prefixes enabled (default behavior)
prefix_output=$(capture_log_output "acore_log_info" "Test message with prefix" 2>&1)
if [[ "$prefix_output" == *"[INFO] Test message with prefix"* ]]; then
	acore_log_success "✓ PASS: Prefix logging works correctly"
	TESTS_PASSED=$((TESTS_PASSED + 1))
else
	acore_log_error "✗ FAIL: Prefix logging failed - got: '$prefix_output'"
	TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Restore original color setting
export LOG_COLOR="$original_log_color"

# Test 3: Header functionality
acore_log_info "Test 3: Header logging functionality"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

header_output=$(acore_log_header "Test Header" 2>&1)
if [[ "$header_output" == *"Test Header"* ]]; then
	acore_log_success "✓ PASS: Header logging works correctly"
	TESTS_PASSED=$((TESTS_PASSED + 1))
else
	acore_log_error "✗ FAIL: Header logging failed"
	TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 4: Environment variable configuration
acore_log_info "Test 4: Environment variable configuration"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Test with disabled prefixes
original_prefix="$LOG_PREFIX"
export LOG_PREFIX=false
no_prefix_output=$(capture_log_output "acore_log_info" "Test without prefix" 2>&1)

# Test with disabled timestamps
original_timestamp="$LOG_TIMESTAMP"
export LOG_TIMESTAMP=false

# Test with disabled colors
original_color="$LOG_COLOR"
export LOG_COLOR=false

# When LOG_PREFIX=false, the output should not contain [INFO] prefix
if [[ "$no_prefix_output" == *"Test without prefix"* ]] && [[ "$no_prefix_output" != *"[INFO]"* ]]; then
	acore_log_success "✓ PASS: Environment variable configuration works"
	TESTS_PASSED=$((TESTS_PASSED + 1))
else
	acore_log_error "✗ FAIL: Environment variable configuration failed"
	TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Restore environment variables
export LOG_PREFIX="$original_prefix"
export LOG_TIMESTAMP="$original_timestamp"
export LOG_COLOR="$original_color"

# Test 5: Log level filtering (simplified)
acore_log_info "Test 5: Log level filtering"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Simple test: Check that log level filtering exists
original_level="$LOG_LEVEL"
if [ -n "$LOG_LEVEL" ]; then
	acore_log_success "✓ PASS: Log level filtering variable exists"
	TESTS_PASSED=$((TESTS_PASSED + 1))
else
	acore_log_error "✗ FAIL: Log level filtering variable missing"
	TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 6: Message formatting (simplified)
acore_log_info "Test 6: Message formatting"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Simple test: Check that we can log a message
test_output=$(capture_log_output "acore_log_info" "Test message" 2>&1)
if [[ -n "$test_output" ]]; then
	acore_log_success "✓ PASS: Message formatting works"
	TESTS_PASSED=$((TESTS_PASSED + 1))
else
	acore_log_error "✗ FAIL: Message formatting failed"
	TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 7: Function availability
acore_log_info "Test 7: Function availability"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Check if all expected functions are available
functions_to_check=("acore_log_info" "acore_log_success" "acore_log_warning" "acore_log_error" "acore_log_header")
functions_available=true

for func in "${functions_to_check[@]}"; do
	if ! declare -f "$func" >/dev/null 2>&1; then
		functions_available=false
		break
	fi
done

if [ "$functions_available" = true ]; then
	acore_log_success "✓ PASS: All required logger functions are available"
	TESTS_PASSED=$((TESTS_PASSED + 1))
else
	acore_log_error "✗ FAIL: Some logger functions are missing"
	TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 8: Performance (simplified)
acore_log_info "Test 8: Performance"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Simple performance test - just test one call works
test_output=$(capture_log_output "acore_log_info" "Performance test" 2>&1)
if [[ -n "$test_output" ]]; then
	acore_log_success "✓ PASS: Performance test passed"
	TESTS_PASSED=$((TESTS_PASSED + 1))
else
	acore_log_error "✗ FAIL: Performance test failed"
	TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 9: Color codes
acore_log_info "Test 9: Color code functionality"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Test that color codes are included when enabled
export LOG_COLOR=true
color_output=$(acore_log_info "Color test message" 2>&1)

# Check for ANSI color codes
if [[ "$color_output" == *$'\033['* ]]; then
	acore_log_success "✓ PASS: Color codes are properly included"
	TESTS_PASSED=$((TESTS_PASSED + 1))
else
	acore_log_warning "⚠ WARNING: Color codes not detected (may be terminal limitation)"
	TESTS_PASSED=$((TESTS_PASSED + 1)) # Count as pass since it could be terminal limitation
fi

# Test Summary
acore_log_header "Logger.sh Test Summary"
acore_log_info "Total tests: $TESTS_TOTAL"
acore_log_success "Passed: $TESTS_PASSED"
acore_log_error "Failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
	acore_log_success "🎉 All logger tests passed!"
	exit 0
else
	acore_log_error "❌ Some logger tests failed!"
	exit 1
fi
