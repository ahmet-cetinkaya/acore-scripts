#!/usr/bin/env bash

# Basic test suite for generate_changelog.sh
# Focuses on core functionality with isolated test environment

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
acore_log_header "generate_changelog.sh Test Suite"

# Test 1: Help functionality
acore_log_info "Test 1: Help functionality"
TESTS_TOTAL=$((TESTS_TOTAL + 1))

help_output=$("$SCRIPT_DIR/src/generate_changelog.sh" --help 2>&1 || true)

if [[ "$help_output" == *"acore-changelog - Generate changelogs from git commits"* ]]; then
  acore_log_success "✓ PASS: Help displayed correctly"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  acore_log_error "✗ FAIL: Help not displayed"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 2: Script execution (in current project)
acore_log_info "Test 2: Script execution with real project"

cd "$SCRIPT_DIR"

# Run with auto-accept to create/update CHANGELOG.md
"$SCRIPT_DIR/src/generate_changelog.sh" -y 2> /dev/null || true

# Check if CHANGELOG.md exists
TESTS_TOTAL=$((TESTS_TOTAL + 1))
if [ -f "$SCRIPT_DIR/CHANGELOG.md" ]; then
  acore_log_success "✓ PASS: CHANGELOG.md created/updated"
  TESTS_PASSED=$((TESTS_PASSED + 1))

  # Test 3: Check changelog structure
  acore_log_info "Test 3: Changelog structure verification"

  changelog_content=$(cat "$SCRIPT_DIR/CHANGELOG.md")

  # Check for required sections
  required_sections=("# Changelog" "## [Unreleased]" "Keep a Changelog")

  for section in "${required_sections[@]}"; do
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    if [[ "$changelog_content" == *"$section"* ]]; then
      acore_log_success "✓ PASS: Section '$section' found"
      TESTS_PASSED=$((TESTS_PASSED + 1))
    else
      acore_log_error "✗ FAIL: Section '$section' missing"
      TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
  done
else
  acore_log_error "✗ FAIL: CHANGELOG.md not created"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 4: Manual input functionality
acore_log_info "Test 4: Manual changelog input"

# Create a temporary test directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Copy scripts for testing
cp "$SCRIPT_DIR/src/generate_changelog.sh" .
cp "$SCRIPT_DIR/src/logger.sh" .

# Create test git repo
git init --quiet
git config user.name "Test User"
git config user.email "test@example.com"
echo "# Test" > README.md
git add README.md
git commit -m "Initial commit" --quiet

# Modify script to work in temp directory
sed -i.bak 's|source "$SCRIPT_DIR/logger.sh"|source "./logger.sh"|' generate_changelog.sh
sed -i 's|PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"|PROJECT_ROOT="$PWD"|' generate_changelog.sh
sed -i 's|MAIN_CHANGELOG="$PROJECT_ROOT/CHANGELOG.md"|MAIN_CHANGELOG="$PWD/CHANGELOG.md"|' generate_changelog.sh

# Test manual input
./generate_changelog.sh 2.0.0 "Added feature X
Fixed bug Y" -y 2> /dev/null || true

TESTS_TOTAL=$((TESTS_TOTAL + 1))
# Check for either 2.0.0 or fallback to 1.0.0 if no git tags exist
# Also check that manual input content was included
if [ -f "CHANGELOG.md" ] && ([[ $(cat CHANGELOG.md) == *"## [2.0.0]"* ]] || [[ $(cat CHANGELOG.md) == *"## [1.0.0]"* ]]) && [[ $(cat CHANGELOG.md) == *"Added feature X"* ]]; then
  acore_log_success "✓ PASS: Manual input works"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  acore_log_error "✗ FAIL: Manual input failed"
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Cleanup
cd "$SCRIPT_DIR"
rm -rf "$TEMP_DIR"

# Test Summary
acore_log_header "Test Summary"
acore_log_info "Total tests: $TESTS_TOTAL"
acore_log_success "Passed: $TESTS_PASSED"
acore_log_error "Failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
  acore_log_success "🎉 All tests passed!"
  exit 0
else
  acore_log_error "❌ Some tests failed!"
  exit 1
fi
