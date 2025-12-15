# generate_changelog.sh Tests

This directory contains test suites for the `generate_changelog.sh` script.

## Test Files

- **basic_test.sh** - Simple test suite covering core functionality
- **run_test.sh** - More comprehensive test runner with isolated environment
- **test_generate_changelog.sh** - Original test suite (may be deprecated)

## Running Tests

### Basic Test (Recommended)

```bash
cd /path/to/acore-scripts
./tests/generate_changelog/basic_test.sh
```

### Comprehensive Test

```bash
cd /path/to/acore-scripts
./tests/generate_changelog/run_test.sh
```

## Test Coverage

The test suites verify:

✅ **Help functionality**

- Help menu displays correctly
- All options and examples are shown

✅ **Script execution**

- CHANGELOG.md file creation/updating
- Proper changelog structure generation

✅ **Changelog structure**

- Required headers and sections
- Keep a Changelog format compliance
- Semantic versioning references

✅ **Manual input handling**

- Manual changelog text processing
- Version section creation

✅ **Conventional commit parsing**

- Commit categorization (feat, fix, perf, etc.)
- Filtering of internal changes (docs, chore, etc.)
- User-facing change detection

✅ **Error handling**

- Invalid argument handling
- Missing file scenarios

## Test Environment

Tests use isolated temporary directories with:

- Git repositories with sample commits
- Isolated script execution
- Clean setup and teardown

## Issues & Notes

- Some tests may include logger output in changelog content
- Test execution modifies the main CHANGELOG.md in project root
- Tests are designed to be run from the project root directory

## Improvements Needed

- [ ] Better logger output isolation in tests
- [ ] More edge case testing
- [ ] Git tag management testing
- [ ] Integration with release-git-tag-manage.sh testing
