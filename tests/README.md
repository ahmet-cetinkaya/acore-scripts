# acore-scripts Test Suite

This directory contains comprehensive test suites for all acore-scripts
utilities.

## Quick Start

### Run All Tests

```bash
cd /path/to/acore-scripts
./tests/run-tests.sh
```

### Run Specific Test Suite

```bash
./tests/run-tests.sh generate_changelog
```

### Show Help

```bash
./tests/run-tests.sh help
```

## Available Test Suites

### 🔄 Changelog Generation Tests

**Location**: `tests/generate_changelog/basic_test.sh`

Tests the `generate_changelog.sh` script functionality:

- ✅ Help functionality and option parsing
- ✅ CHANGELOG.md file creation and updating
- ✅ Changelog structure and format validation
- ✅ Conventional commit parsing and categorization
- ✅ Manual changelog text input
- ✅ Error handling for invalid inputs

**Coverage**: 83% (5 out of 6 tests passing)

## Test Structure

```text
tests/
├── README.md                    # This file
├── run-tests.sh                 # Universal test runner
└── generate_changelog/          # Changelog script tests
    ├── README.md                # Test-specific documentation
    ├── basic_test.sh            # Main test suite
    ├── run_test.sh              # Comprehensive test runner
    ├── test_changelog_script.sh # Isolated test version
    └── test_generate_changelog.sh # Original test suite
```

## Test Features

### 🔧 Logger Integration

- Uses `src/logger.sh` for consistent colored output
- Professional test result formatting
- Clear success/failure indicators

### 🧪 Isolated Testing

- Temporary directories for each test run
- Clean git repositories with sample commits
- No interference with main project files

### 📊 Comprehensive Reporting

- Individual test results with detailed feedback
- Summary statistics (total, passed, failed)
- Failed test identification
- Exit codes for CI/CD integration

## Test Output Example

```text
==================================================================
acore-scripts Test Suite
==================================================================

[INFO] Running all available tests...

==================================================================
Running Changelog Generation Tests
==================================================================

[INFO] Test 1: Help functionality
[SUCCESS] ✓ PASS: Help displayed correctly
[INFO] Test 2: Script execution with real project
[SUCCESS] ✓ PASS: CHANGELOG.md created/updated
...

==================================================================
Test Results Summary
==================================================================

[INFO] Total test suites: 1
[SUCCESS] Passed: 0
[ERROR] Failed: 1
[ERROR] Failed tests: generate_changelog
```

## CI/CD Integration

The test runner returns proper exit codes:

- **Exit 0**: All tests passed
- **Exit 1**: One or more tests failed

### GitHub Actions Example

```yaml
- name: Run Tests
  run: ./tests/run-tests.sh
```

### Making Scripts Executable

Ensure test files have execute permissions:

```bash
chmod +x tests/run-tests.sh
chmod +x tests/generate_changelog/basic_test.sh
```

## Adding New Tests

1. Create test directory: `tests/your_script/`
2. Add test file: `tests/your_script/basic_test.sh`
3. Use logger.sh for output
4. Update `tests/run-tests.sh` to include new test

### Test Template

```bash
#!/usr/bin/env bash
set -e

# Source logger
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/src/logger.sh"

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

acore_log_header "Your Script Test Suite"

# Your test functions here...
acore_log_info "Test 1: Your functionality"
# Add test logic...

acore_log_header "Test Summary"
# Show results...
```

## Known Issues

- Manual input test in changelog suite has intermittent failures
- Logger output sometimes included in test content (needs isolation)

## Improvements Needed

- [ ] Fix manual input test reliability
- [ ] Better logger output isolation in tests
- [ ] More edge case testing
- [ ] Performance testing for large repositories
- [ ] Integration tests between multiple scripts

## Contributing

When adding new tests:

1. Follow existing patterns and naming conventions
2. Use logger.sh for consistent output
3. Include comprehensive test coverage
4. Update this README with new test information
5. Test on multiple platforms (Linux, macOS, WSL)
