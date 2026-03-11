#!/usr/bin/env bash

# Simple test runner that copies and modifies the original script for testing

set -e

# Colors for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Project paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR="$TEST_DIR/temp"

# Setup test environment
setup_test_env() {
  echo -e "${BLUE}Setting up test environment...${NC}"

  # Create temporary directory
  rm -rf "$TEMP_DIR"
  mkdir -p "$TEMP_DIR"

  # Copy original script to temp directory and modify it for testing
  cp "$PROJECT_ROOT/src/generate_changelog.sh" "$TEMP_DIR/"
  cp "$PROJECT_ROOT/src/logger.sh" "$TEMP_DIR/"

  # Modify the script to use the current directory for CHANGELOG.md and local logger
  sed -i.bak 's|MAIN_CHANGELOG="$PROJECT_ROOT/CHANGELOG.md"|MAIN_CHANGELOG="$PWD/CHANGELOG.md"|' "$TEMP_DIR/generate_changelog.sh"
  sed -i 's|source "$SCRIPT_DIR/logger.sh"|source "$PWD/logger.sh"|' "$TEMP_DIR/generate_changelog.sh"

  # Create test git repository
  cd "$TEMP_DIR"
  git init --quiet
  git config user.name "Test User"
  git config user.email "test@example.com"

  # Create initial commit
  echo "# Test Project" > README.md
  git add README.md
  git commit -m "Initial commit" --quiet

  # Clear any existing git state that might interfere
  git checkout --orphan test-branch 2> /dev/null || true
  git reset --hard

  echo -e "${GREEN}Test environment setup complete${NC}"
}

# Cleanup test environment
cleanup_test_env() {
  echo -e "${BLUE}Cleaning up test environment...${NC}"
  cd "$PROJECT_ROOT"
  rm -rf "$TEMP_DIR"
  echo -e "${GREEN}Test environment cleaned up${NC}"
}

# Test utility functions
assert_contains() {
  local haystack="$1"
  local needle="$2"
  local test_name="$3"

  TESTS_TOTAL=$((TESTS_TOTAL + 1))

  if [[ "$haystack" == *"$needle"* ]]; then
    echo -e "${GREEN}✓ PASS: $test_name${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗ FAIL: $test_name${NC}"
    echo -e "${RED}  Expected haystack to contain: '$needle'${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_file_exists() {
  local file_path="$1"
  local test_name="$2"

  TESTS_TOTAL=$((TESTS_TOTAL + 1))

  if [ -f "$file_path" ]; then
    echo -e "${GREEN}✓ PASS: $test_name${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗ FAIL: $test_name${NC}"
    echo -e "${RED}  Expected file to exist: '$file_path'${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# Test functions
test_help_functionality() {
  echo -e "\n${YELLOW}Testing help functionality...${NC}"

  cd "$TEMP_DIR"

  local help_output
  help_output=$(./generate_changelog.sh --help 2>&1 || true)

  assert_contains "$help_output" "acore-changelog - Generate changelogs from git commits" "Help header displayed"
  assert_contains "$help_output" "USAGE:" "Usage section present"
  assert_contains "$help_output" "OPTIONS:" "Options section present"
  assert_contains "$help_output" "-y" "Auto-accept option documented"
  assert_contains "$help_output" "--help" "Help option documented"
}

test_basic_functionality() {
  echo -e "\n${YELLOW}Testing basic functionality...${NC}"

  cd "$TEMP_DIR"

  # Add some conventional commits
  git commit --allow-empty -m "feat: add user authentication" --quiet
  git commit --allow-empty -m "fix: resolve login redirect loop" --quiet
  git commit --allow-empty -m "perf: optimize database queries" --quiet

  # Test auto-accept mode
  ./generate_changelog.sh -y

  # Verify CHANGELOG.md was created
  assert_file_exists "$TEMP_DIR/CHANGELOG.md" "CHANGELOG.md created"

  # Verify content structure
  local changelog_content
  changelog_content=$(cat "$TEMP_DIR/CHANGELOG.md")

  assert_contains "$changelog_content" "# Changelog" "Changelog header present"
  assert_contains "$changelog_content" "## [Unreleased]" "Unreleased section present"
  assert_contains "$changelog_content" "### Added" "Added section for feat commits"
  assert_contains "$changelog_content" "### Fixed" "Fixed section for fix commits"
  assert_contains "$changelog_content" "### Changed" "Changed section for perf commits"
}

test_manual_input() {
  echo -e "\n${YELLOW}Testing manual changelog input...${NC}"

  cd "$TEMP_DIR"

  # Remove existing changelog
  rm -f CHANGELOG.md

  # Test manual changelog text
  local manual_text="Added custom feature
Fixed critical bug"

  echo "$manual_text" | ./generate_changelog.sh 1.2.3 -y 2> /dev/null || true

  local changelog_content
  changelog_content=$(cat "$TEMP_DIR/CHANGELOG.md")

  assert_contains "$changelog_content" "## [1.2.3]" "Version section created"
  assert_contains "$changelog_content" "Added custom feature" "Manual text included"
  assert_contains "$changelog_content" "Fixed critical bug" "Manual text included"
}

test_conventional_commit_filtering() {
  echo -e "\n${YELLOW}Testing conventional commit filtering...${NC}"

  cd "$TEMP_DIR"

  # Add various conventional commits
  git commit --allow-empty -m "feat: add new API endpoint" --quiet
  git commit --allow-empty -m "fix: resolve memory leak" --quiet
  git commit --allow-empty -m "docs: update README" --quiet
  git commit --allow-empty -m "style: fix code formatting" --quiet
  git commit --allow-empty -m "test: add unit tests" --quiet
  git commit --allow-empty -m "chore: update dependencies" --quiet

  # Remove existing changelog
  rm -f CHANGELOG.md

  # Generate changelog
  ./generate_changelog.sh -y

  local changelog_content
  changelog_content=$(cat "$TEMP_DIR/CHANGELOG.md")

  # Verify user-facing changes are included
  assert_contains "$changelog_content" "Add new API endpoint" "feat commit included"
  assert_contains "$changelog_content" "Resolve memory leak" "fix commit included"

  # Verify internal changes are excluded
  if [[ "$changelog_content" == *"update README"* ]]; then
    echo -e "${RED}✗ FAIL: docs commit should not appear in changelog${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  else
    echo -e "${GREEN}✓ PASS: docs commit correctly excluded${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  fi
  TESTS_TOTAL=$((TESTS_TOTAL + 1))

  if [[ "$changelog_content" == *"update dependencies"* ]]; then
    echo -e "${RED}✗ FAIL: chore commit should not appear in changelog${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  else
    echo -e "${GREEN}✓ PASS: chore commit correctly excluded${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  fi
  TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

# Main test runner
run_all_tests() {
  echo -e "${BLUE}Starting generate_changelog.sh test suite...${NC}"

  setup_test_env

  # Run all tests
  test_help_functionality
  test_basic_functionality
  test_manual_input
  test_conventional_commit_filtering

  cleanup_test_env

  # Print test summary
  echo -e "\n${BLUE}=== Test Summary ===${NC}"
  echo -e "Total tests: $TESTS_TOTAL"
  echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
  echo -e "${RED}Failed: $TESTS_FAILED${NC}"

  if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed! 🎉${NC}"
    exit 0
  else
    echo -e "\n${RED}Some tests failed! 😢${NC}"
    exit 1
  fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_all_tests
fi
