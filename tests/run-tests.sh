#!/usr/bin/env bash

# Universal test runner for all acore-scripts tests
# Usage: ./tests/run-tests.sh [test-name]

set -e

# Colors and formatting
HEADER_LINE="=================================================================="

# Project paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TESTS_DIR="$SCRIPT_DIR"

# Source logger utilities
source "$PROJECT_ROOT/src/logger.sh"

# Test configuration
FAILED_TESTS=()
TOTAL_TESTS=0
PASSED_TESTS=0

# Function to display usage
show_usage() {
	cat <<'EOF'
acore-scripts Test Runner

USAGE:
    run-tests.sh [TEST_NAME]

ARGUMENTS:
    TEST_NAME    Optional. Run specific test instead of all tests

AVAILABLE TESTS:
    generate_changelog    Run changelog generation tests
    format_utilities      Run format utilities tests (JSON, YAML, MD, SH)
    logger                Run logger utility tests
    git_management        Run git tag management tests
    integration           Run cross-script integration tests
    help                  Show this help message

EXAMPLES:
    run-tests.sh                     # Run all tests
    run-tests.sh generate_changelog  # Run specific test suite
    run-tests.sh format_utilities    # Run format utilities tests
    run-tests.sh logger              # Run logger utility tests
    run-tests.sh git_management      # Run git tag management tests
    run-tests.sh integration         # Run cross-script integration tests
    run-tests.sh help                # Show this help

DESCRIPTION:
    Runs all available test suites for acore-scripts with colored output
    and comprehensive test result reporting.
EOF
}

# Function to run a test suite
run_test_suite() {
	local test_name="$1"
	local test_file="$2"
	local test_description="$3"

	acore_log_header "Running $test_description"

	if [ -f "$test_file" ]; then
		if [ -x "$test_file" ]; then
			if "$test_file"; then
				acore_log_success "$test_description completed successfully"
				PASSED_TESTS=$((PASSED_TESTS + 1))
			else
				acore_log_error "$test_description failed"
				FAILED_TESTS+=("$test_name")
			fi
		else
			acore_log_error "Test file $test_file is not executable"
			FAILED_TESTS+=("$test_name")
		fi
	else
		acore_log_error "Test file $test_file not found"
		FAILED_TESTS+=("$test_name")
	fi

	TOTAL_TESTS=$((TOTAL_TESTS + 1))
	echo # Add spacing between tests
}

# Function to run all available tests
run_all_tests() {
	acore_log_header "acore-scripts Test Suite"
	acore_log_info "Running all available tests..."
	echo

	# Generate Changelog Tests
	if [ -f "$TESTS_DIR/generate_changelog/basic_test.sh" ]; then
		run_test_suite "generate_changelog" "$TESTS_DIR/generate_changelog/basic_test.sh" "Changelog Generation Tests"
	fi

	# Format Utilities Tests
	if [ -f "$TESTS_DIR/format_utilities/basic_test.sh" ]; then
		run_test_suite "format_utilities" "$TESTS_DIR/format_utilities/basic_test.sh" "Format Utilities Tests"
	fi

	# Logger Tests
	if [ -f "$TESTS_DIR/logger/basic_test.sh" ]; then
		run_test_suite "logger" "$TESTS_DIR/logger/basic_test.sh" "Logger Utility Tests"
	fi

	# Git Management Tests
	if [ -f "$TESTS_DIR/git_management/basic_test.sh" ]; then
		run_test_suite "git_management" "$TESTS_DIR/git_management/basic_test.sh" "Git Tag Management Tests"
	fi

	# Integration Tests
	if [ -f "$TESTS_DIR/integration/basic_test.sh" ]; then
		run_test_suite "integration" "$TESTS_DIR/integration/basic_test.sh" "Cross-Script Integration Tests"
	fi
}

# Function to display final test results
show_test_results() {
	acore_log_header "Test Results Summary"

	if [ $TOTAL_TESTS -eq 0 ]; then
		acore_log_warning "No tests were run"
		return
	fi

	acore_log_info "Total test suites: $TOTAL_TESTS"
	acore_log_success "Passed: $PASSED_TESTS"

	if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
		acore_log_error "Failed: ${#FAILED_TESTS[@]}"
		acore_log_error "Failed tests: ${FAILED_TESTS[*]}"
	else
		acore_log_success "All test suites passed! 🎉"
	fi

	echo # Add spacing before exit
}

# Parse arguments
TEST_NAME="$1"

case "$TEST_NAME" in
"help" | "-h" | "--help" | "")
	if [ "$TEST_NAME" = "help" ] || [ "$TEST_NAME" = "-h" ] || [ "$TEST_NAME" = "--help" ]; then
		show_usage
		exit 0
	fi
	;;
"generate_changelog" | "changelog" | "change")
	acore_log_header "Running Changelog Generation Tests Only"
	if [ -f "$TESTS_DIR/generate_changelog/basic_test.sh" ]; then
		run_test_suite "generate_changelog" "$TESTS_DIR/generate_changelog/basic_test.sh" "Changelog Generation Tests"
		show_test_results
	else
		acore_log_error "Changelog test suite not found at: $TESTS_DIR/generate_changelog/basic_test.sh"
		exit 1
	fi
	exit $([ ${#FAILED_TESTS[@]} -eq 0 ] && echo 0 || echo 1)
	;;
"format_utilities" | "format" | "formatting")
	acore_log_header "Running Format Utilities Tests Only"
	if [ -f "$TESTS_DIR/format_utilities/basic_test.sh" ]; then
		run_test_suite "format_utilities" "$TESTS_DIR/format_utilities/basic_test.sh" "Format Utilities Tests"
		show_test_results
	else
		acore_log_error "Format utilities test suite not found at: $TESTS_DIR/format_utilities/basic_test.sh"
		exit 1
	fi
	exit $([ ${#FAILED_TESTS[@]} -eq 0 ] && echo 0 || echo 1)
	;;
"logger")
	acore_log_header "Running Logger Utility Tests Only"
	if [ -f "$TESTS_DIR/logger/basic_test.sh" ]; then
		run_test_suite "logger" "$TESTS_DIR/logger/basic_test.sh" "Logger Utility Tests"
		show_test_results
	else
		acore_log_error "Logger test suite not found at: $TESTS_DIR/logger/basic_test.sh"
		exit 1
	fi
	exit $([ ${#FAILED_TESTS[@]} -eq 0 ] && echo 0 || echo 1)
	;;
"git_management" | "git" | "tag")
	acore_log_header "Running Git Tag Management Tests Only"
	if [ -f "$TESTS_DIR/git_management/basic_test.sh" ]; then
		run_test_suite "git_management" "$TESTS_DIR/git_management/basic_test.sh" "Git Tag Management Tests"
		show_test_results
	else
		acore_log_error "Git management test suite not found at: $TESTS_DIR/git_management/basic_test.sh"
		exit 1
	fi
	exit $([ ${#FAILED_TESTS[@]} -eq 0 ] && echo 0 || echo 1)
	;;
"integration" | "integrated" | "cross")
	acore_log_header "Running Cross-Script Integration Tests Only"
	if [ -f "$TESTS_DIR/integration/basic_test.sh" ]; then
		run_test_suite "integration" "$TESTS_DIR/integration/basic_test.sh" "Cross-Script Integration Tests"
		show_test_results
	else
		acore_log_error "Integration test suite not found at: $TESTS_DIR/integration/basic_test.sh"
		exit 1
	fi
	exit $([ ${#FAILED_TESTS[@]} -eq 0 ] && echo 0 || echo 1)
	;;
*)
	acore_log_error "Unknown test suite: $TEST_NAME"
	acore_log_info "Available test suites: generate_changelog, format_utilities, logger, git_management, integration"
	acore_log_info "Use '$0 help' for more information"
	exit 1
	;;
esac

# Run all tests if no specific test was requested
run_all_tests

# Show final results
show_test_results

# Exit with appropriate code
if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
	exit 0
else
	exit 1
fi
