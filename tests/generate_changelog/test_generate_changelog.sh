#!/usr/bin/env bash

# Test suite for generate_changelog.sh script
# Usage: ./tests/generate_changelog/test_generate_changelog.sh

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
SCRIPT_DIR="$PROJECT_ROOT/src"
TEST_DIR="$PROJECT_ROOT/tests/generate_changelog"
TEMP_DIR="$TEST_DIR/temp"

# Script under test
CHANGELOG_SCRIPT="$TEST_DIR/test_changelog_script.sh"
LOGGER_SCRIPT="$SCRIPT_DIR/logger.sh"

# Setup test environment
setup_test_env() {
  echo -e "${BLUE}Setting up test environment...${NC}"

  # Create temporary directory
  rm -rf "$TEMP_DIR"
  mkdir -p "$TEMP_DIR"

  # Create test git repository
  cd "$TEMP_DIR"
  git init --quiet
  git config user.name "Test User"
  git config user.email "test@example.com"

  # Create initial commit
  echo "# Test Project" > README.md
  git add README.md
  git commit -m "Initial commit" --quiet

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
assert_equals() {
  local expected="$1"
  local actual="$2"
  local test_name="$3"

  TESTS_TOTAL=$((TESTS_TOTAL + 1))

  if [ "$expected" = "$actual" ]; then
    echo -e "${GREEN}✓ PASS: $test_name${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗ FAIL: $test_name${NC}"
    echo -e "${RED}  Expected: '$expected'${NC}"
    echo -e "${RED}  Actual:   '$actual'${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

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
    echo -e "${RED}  Haystack was: '$haystack'${NC}"
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

  # Test --help flag
  local help_output
  help_output=$("$CHANGELOG_SCRIPT" --help 2>&1 || true)

  assert_contains "$help_output" "acore-changelog - Generate changelogs from git commits" "Help header displayed"
  assert_contains "$help_output" "USAGE:" "Usage section present"
  assert_contains "$help_output" "OPTIONS:" "Options section present"
  assert_contains "$help_output" "-y" "Auto-accept option documented"
  assert_contains "$help_output" "--help" "Help option documented"
}

test_script_execution() {
  echo -e "\n${YELLOW}Testing script execution...${NC}"

  cd "$TEMP_DIR"

  # Add some commits with conventional commit format
  echo "Feature: User authentication" >> auth.js
  git add auth.js
  git commit -m "feat: add user authentication" --quiet

  echo "Bug fix: Login redirect loop" >> auth.js
  git add auth.js
  git commit -m "fix(auth): resolve login redirect loop" --quiet

  echo "Performance: Database optimization" >> db.js
  git add db.js
  git commit -m "perf: optimize database queries" --quiet

  # Test auto-accept mode
  "$CHANGELOG_SCRIPT" -y

  # Verify CHANGELOG.md was created
  assert_file_exists "$TEMP_DIR/CHANGELOG.md" "CHANGELOG.md created"

  # Verify content structure
  local changelog_content
  changelog_content=$(cat "$TEMP_DIR/CHANGELOG.md")

  assert_contains "$changelog_content" "# Changelog" "Changelog header present"
  assert_contains "$changelog_content" "Keep a Changelog" "Keep a Changelog reference present"
  assert_contains "$changelog_content" "Semantic Versioning" "Semantic Versioning reference present"
  assert_contains "$changelog_content" "## [Unreleased]" "Unreleased section present"
}

test_conventional_commit_parsing() {
  echo -e "\n${YELLOW}Testing conventional commit parsing...${NC}"

  cd "$TEMP_DIR"

  # Add various conventional commits
  git commit --allow-empty -m "feat: add new API endpoint" --quiet
  git commit --allow-empty -m "fix: resolve memory leak" --quiet
  git commit --allow-empty -m "docs: update README" --quiet
  git commit --allow-empty -m "style: fix code formatting" --quiet
  git commit --allow-empty -m "refactor: improve code structure" --quiet
  git commit --allow-empty -m "test: add unit tests" --quiet
  git commit --allow-empty -m "chore: update dependencies" --quiet
  git commit --allow-empty -m "perf: improve application performance" --quiet
  git commit --allow-empty -m "ci: configure CI pipeline" --quiet

  # Test changelog generation
  "$CHANGELOG_SCRIPT" -y

  local changelog_content
  changelog_content=$(cat "$TEMP_DIR/CHANGELOG.md")

  # Verify only user-facing changes are included
  assert_contains "$changelog_content" "### Added" "Added section for feat commits"
  assert_contains "$changelog_content" "### Fixed" "Fixed section for fix commits"
  assert_contains "$changelog_content" "### Changed" "Changed section for perf/refactor commits"

  # Verify internal changes are excluded
  assert_contains "$changelog_content" "Add new API endpoint" "feat commit included"
  assert_contains "$changelog_content" "Resolve memory leak" "fix commit included"

  # These should not appear in changelog (internal changes)
  if [[ "$changelog_content" == *"update README"* ]]; then
    echo -e "${RED}✗ FAIL: docs commit should not appear in changelog${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  else
    echo -e "${GREEN}✓ PASS: docs commit correctly excluded${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  fi
  TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

test_manual_changelog_input() {
  echo -e "\n${YELLOW}Testing manual changelog input...${NC}"

  cd "$TEMP_DIR"

  # Test manual changelog text
  local manual_text="Added custom feature
Fixed critical bug
Improved performance"

  echo "$manual_text" | "$CHANGELOG_SCRIPT" 1.2.3 -y 2> /dev/null || true

  local changelog_content
  changelog_content=$(cat "$TEMP_DIR/CHANGELOG.md")

  assert_contains "$changelog_content" "## [1.2.3]" "Version section created"
  assert_contains "$changelog_content" "Added custom feature" "Manual text included"
  assert_contains "$changelog_content" "Fixed critical bug" "Manual text included"
  assert_contains "$changelog_content" "Improved performance" "Manual text included"
}

test_fresh_changelog_creation() {
  echo -e "\n${YELLOW}Testing fresh CHANGELOG.md creation...${NC}"

  cd "$TEMP_DIR"

  # Remove existing changelog if any
  rm -f CHANGELOG.md

  # Add a commit
  git commit --allow-empty -m "feat: initial feature" --quiet

  # Generate changelog
  "$CHANGELOG_SCRIPT" -y

  local changelog_content
  changelog_content=$(cat "$TEMP_DIR/CHANGELOG.md")

  # Verify fresh file structure
  assert_contains "$changelog_content" "# Changelog" "Header present"
  assert_contains "$changelog_content" "All notable changes to this project" "Description present"
  assert_contains "$changelog_content" "## [Unreleased]" "Unreleased section present"
  assert_contains "$changelog_content" "[unreleased]:" "Footer links present"
}

test_footer_generation() {
  echo -e "\n${YELLOW}Testing footer generation...${NC}"

  cd "$TEMP_DIR"

  # Add a remote to test footer links
  git remote add origin https://github.com/test/repo.git

  # Add a commit and generate changelog
  git commit --allow-empty -m "feat: test feature" --quiet
  "$CHANGELOG_SCRIPT" 1.0.0 -y

  local changelog_content
  changelog_content=$(cat "$TEMP_DIR/CHANGELOG.md")

  # Verify footer links
  assert_contains "$changelog_content" "[unreleased]: https://github.com/test/repo/compare/v1.0.0...HEAD" "Unreleased link correct"
  assert_contains "$changelog_content" "[1.0.0]: https://github.com/test/repo/releases/tag/v1.0.0" "Version link correct"
}

test_error_handling() {
  echo -e "\n${YELLOW}Testing error handling...${NC}"

  cd "$TEMP_DIR"

  # Test invalid arguments
  local error_output
  error_output=$("$CHANGELOG_SCRIPT" --invalid-flag 2>&1 || true)

  assert_contains "$error_output" "Unknown option" "Invalid option error handled"
}

test_version_detection() {
  echo -e "\n${YELLOW}Testing version detection...${NC}"

  cd "$TEMP_DIR"

  # Create a tag
  git tag v1.5.0

  # Add a commit
  git commit --allow-empty -m "feat: new feature after tag" --quiet

  # Generate changelog (should use current version)
  "$CHANGELOG_SCRIPT" -y

  local changelog_content
  changelog_content=$(cat "$TEMP_DIR/CHANGELOG.md")

  # Should use current version for the entry
  assert_contains "$changelog_content" "## [1.5.0]" "Current version detected and used"
}

# Main test runner
run_all_tests() {
  echo -e "${BLUE}Starting generate_changelog.sh test suite...${NC}"

  setup_test_env

  # Run all tests
  test_help_functionality
  test_script_execution
  test_conventional_commit_parsing
  test_manual_changelog_input
  test_fresh_changelog_creation
  test_footer_generation
  test_error_handling
  test_version_detection

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
