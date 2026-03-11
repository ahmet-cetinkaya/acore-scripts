# API Reference - acore-scripts

## Table of Contents

- [Logger Utilities (`logger.sh`)](#logger-utilities-loggersh)
  - [Configuration](#configuration)
  - [Logging Functions](#logging-functions)
  - [Utility Functions](#utility-functions)
  - [Formatting Functions](#formatting-functions)
  - [File Logging](#file-logging)
  - [Error Handling](#error-handling)
  - [Progress Indicators](#progress-indicators)
  - [Configuration Management](#configuration-management)

- [Format Utilities](#format-utilities)
  - [JSON Formatter (`format_json.sh`)](#json-formatter-format_jsonsh)
  - [YAML Formatter (`format_yaml.sh`)](#yaml-formatter-format_yamlsh)
  - [Markdown Formatter (`format_md.sh`)](#markdown-formatter-format_mdsh)
  - [Shell Script Formatter (`format_sh.sh`)](#shell-script-formatter-format_shsh)

---

## Logger Utilities (`logger.sh`)

A comprehensive logging library for shell scripts providing colored output,
configurable levels, timestamps, and formatting utilities.

### Usage

```bash
# Source the logger script in your shell script
source "$(dirname "$0")/logger.sh"

# Use logging functions
acore_log_info "Application starting"
acore_log_error "Something went wrong"
acore_log_success "Operation completed"
```

### Configuration

Configuration is handled through environment variables with sensible defaults:

| Variable        | Default   | Description                                                          |
| --------------- | --------- | -------------------------------------------------------------------- |
| `LOG_LEVEL`     | `"INFO"`  | Minimum log level to display (DEBUG, INFO, WARNING, ERROR, CRITICAL) |
| `LOG_PREFIX`    | `"true"`  | Show/hide log level prefixes                                         |
| `LOG_TIMESTAMP` | `"false"` | Show/hide timestamps                                                 |
| `LOG_COLOR`     | `"true"`  | Enable/disable colored output                                        |

**Example Configuration:**

```bash
export LOG_LEVEL="DEBUG"
export LOG_TIMESTAMP="true"
export LOG_COLOR="false"
```

### Logging Functions

#### `acore_log_debug(message...)`

Prints debug messages in gray. Only displayed when `LOG_LEVEL` is set to
`"DEBUG"`.

**Parameters:**

- `message...`: Message to display (supports multiple arguments)

**Example:**

```bash
acore_log_debug "Variable value: $VAR"
acore_log_debug "Processing file" "$filename"
```

#### `acore_log_info(message...)`

Prints informational messages in blue. Displayed when `LOG_LEVEL` is `"DEBUG"`
or `"INFO"`.

**Parameters:**

- `message...`: Message to display

**Example:**

```bash
acore_log_info "Starting deployment"
acore_log_info "Processing" "$count" "files"
```

#### `acore_log_success(message...)`

Prints success messages in green. Hidden only when `LOG_LEVEL` is `"ERROR"`.

**Parameters:**

- `message...`: Success message to display

**Example:**

```bash
acore_log_success "Build completed successfully"
acore_log_success "All tests passed"
```

#### `acore_log_warning(message...)`

Prints warning messages in yellow. Hidden only when `LOG_LEVEL` is `"ERROR"`.

**Parameters:**

- `message...`: Warning message to display

**Example:**

```bash
acore_log_warning "Deprecated function used"
acore_log_warning "Configuration file not found, using defaults"
```

#### `acore_log_error(message...)`

Prints error messages in red to stderr. Always displayed regardless of
`LOG_LEVEL`.

**Parameters:**

- `message...`: Error message to display

**Example:**

```bash
acore_log_error "Failed to connect to database"
acore_log_error "File not found:" "$filename"
```

#### `acore_log_critical(message...)`

Prints critical error messages in red to stderr. Always displayed regardless of
`LOG_LEVEL`.

**Parameters:**

- `message...`: Critical error message to display

**Example:**

```bash
acore_log_critical "System out of memory"
acore_log_critical "Security breach detected"
```

### Utility Functions

#### `acore_log_header(title)`

Prints a full-width cyan header with the given title surrounded by equal signs.

**Parameters:**

- `title`: Header title text

**Example:**

```bash
acore_log_header "Installation Complete"
# Output:
# ==================================================================
# Installation Complete
# ==================================================================
```

#### `acore_log_section(title)`

Prints a section divider in purple with the given title surrounded by dashes.

**Parameters:**

- `title`: Section title text

**Example:**

```bash
acore_log_section "Database Setup"
# Output:
# --- Database Setup ---
```

#### `acore_log_divider()`

Prints a horizontal line of 50 equal signs for visual separation.

**Example:**

```bash
acore_log_divider
# Output:
# ==================================================
```

### Formatting Functions

#### `acore_log_bold(message...)`

Prints text in bold white (when colors are enabled).

**Parameters:**

- `message...`: Text to display in bold

**Example:**

```bash
acore_log_bold "IMPORTANT:" "Read this carefully"
```

#### `acore_log_italic(message...)`

Prints text in purple (simulating italic when colors are enabled). Note: Italic
may not work in all terminals.

**Parameters:**

- `message...`: Text to display in italic style

**Example:**

```bash
acore_log_italic "Note:" "This is optional"
```

### File Logging

#### `acore_log_to_file(file_path, level, message...)`

Writes a timestamped log message to a specified file.

**Parameters:**

- `file_path`: Path to the log file (directory will be created if needed)
- `level`: Log level string (e.g., "INFO", "ERROR")
- `message...`: Message to write to file

**Example:**

```bash
acore_log_to_file "/var/log/app.log" "INFO" "Application started"
acore_log_to_file "$LOG_DIR/error.log" "ERROR" "Database connection failed"
```

### Error Handling

#### `acore_log_and_exit(exit_code, message...)`

Logs an error message and exits the script with the specified exit code.

**Parameters:**

- `exit_code`: Exit code to return
- `message...`: Error message to display before exiting

**Example:**

```bash
acore_log_and_exit 1 "Configuration file not found"
acore_log_and_exit 2 "Invalid arguments provided"
```

### Progress Indicators

#### `acore_log_spinner(pid)`

Displays a spinning cursor while a process is running. This function runs in the
background and should be used with background processes.

**Parameters:**

- `pid`: Process ID to monitor

**Example:**

```bash
# Start a long-running process in background
long_running_process &
PID=$!

# Show spinner while process runs
acore_log_spinner $PID

# Wait for process to complete
wait $PID
```

### Configuration Management

#### `acore_set_log_config(level, show_prefix, show_timestamp, use_color)`

Updates logging configuration dynamically.

**Parameters:**

- `level`: New log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- `show_prefix` (optional): Enable/disable prefixes (default: current value)
- `show_timestamp` (optional): Enable/disable timestamps (default: current
  value)
- `use_color` (optional): Enable/disable colors (default: current value)

**Example:**

```bash
# Enable debug mode with full formatting
acore_set_log_config "DEBUG" "true" "true" "true"

# Switch to error-only mode without colors
acore_set_log_config "ERROR" "false" "false" "false"

# Enable timestamps while keeping other settings
acore_set_log_config "INFO" "" "true" ""
```

### Color Constants

The logger defines the following color constants for custom formatting:

| Constant       | Color            |
| -------------- | ---------------- |
| `COLOR_RED`    | Red              |
| `COLOR_GREEN`  | Green            |
| `COLOR_YELLOW` | Yellow           |
| `COLOR_BLUE`   | Blue             |
| `COLOR_PURPLE` | Purple           |
| `COLOR_CYAN`   | Cyan             |
| `COLOR_WHITE`  | White (bold)     |
| `COLOR_GRAY`   | Gray             |
| `COLOR_NC`     | No Color (reset) |

**Custom Formatting Example:**

```bash
echo -e "${COLOR_GREEN}Success:${COLOR_NC} Operation completed"
echo -e "${COLOR_YELLOW}Warning:${COLOR_NC} Check configuration"
```

## Integration Examples

### Basic Script Integration

```bash
#!/usr/bin/env bash

# Source the logger (relative path)
source "$(dirname "$0")/path/to/logger.sh"

# Configure logging
acore_set_log_config "INFO" "true" "true" "true"

# Start script
acore_log_header "My Application"
acore_log_info "Starting application..."

# Do work
acore_log_section "Processing Data"
acore_log_info "Processing files..."

# Check for errors
if [[ ! -f "config.json" ]]; then
  acore_log_and_exit 1 "Configuration file missing"
fi

# Success
acore_log_success "Application completed successfully"
```

### Integration with Git Submodule

```bash
#!/usr/bin/env bash

# When using as git submodule in scripts/acore/
source "$(dirname "$0")/../acore/src/logger.sh"

# Use in deployment script
acore_log_header "Deployment Script"
acore_log_info "Deploying to production..."

# Run deployment commands with logging
if npm run build; then
  acore_log_success "Build completed"
else
  acore_log_and_exit 1 "Build failed"
fi
```

### Multi-Level Logging Example

```bash
#!/usr/bin/env bash

source logger.sh

# Start with info level
acore_log_info "Script starting"

# Enable debug for troubleshooting
acore_set_log_config "DEBUG"
acore_log_debug "Detailed debugging information"
acore_log_debug "Variable values: VAR1=$VAR1, VAR2=$VAR2"

# Switch back to info for normal operation
acore_set_log_config "INFO"
acore_log_info "Continuing normal operation"

# Handle error
if [[ -z "$REQUIRED_VAR" ]]; then
  acore_log_error "Required variable not set"
  exit 1
fi
```

---

## Contributing to API Documentation

When adding new scripts or functions:

1. Follow the same documentation format
2. Include usage examples
3. Document all parameters and return values
4. Add integration examples
5. Update the table of contents

---

## Format Utilities

The format utilities provide consistent code formatting for various file types
using industry-standard tools. All format scripts can be used as libraries
(sourced) or executed directly.

### Common Characteristics

- **Graceful Dependency Handling**: Scripts warn when required tools are missing
  but don't fail
- **Git Integration**: Respect `.gitignore` and exclude `.git` directory
- **Logging**: Use the `logger.sh` utility for consistent output
- **Environment Configuration**: Support environment variable overrides
- **POSIX Compliance**: Compatible across Linux, macOS, and WSL

---

## JSON Formatter (`format_json.sh`)

Formats JSON files using Prettier with consistent styling and proper formatting.

### Dependencies

- **Prettier**: Required for JSON formatting (gracefully handled if missing)

### Usage

```bash
# Source as a library
source "$(dirname "$0")/format_json.sh"

# Format all JSON files
acore_format_json_files

# Execute directly
./format_json.sh
```

### Functions

#### `acore_format_json_check_prettier()`

Checks if Prettier is installed and available in PATH.

**Returns:**

- `0`: Prettier is available
- `1`: Prettier is not installed

**Example:**

```bash
if acore_format_json_check_prettier; then
  acore_log_info "Prettier is available"
else
  acore_log_warning "Prettier not found"
fi
```

#### `acore_format_json_check_files()`

Checks if there are any JSON files in the current directory to format.

**Returns:**

- `0`: JSON files found
- `1`: No JSON files found

**Example:**

```bash
if ! acore_format_json_check_files; then
  acore_log_info "No JSON files to format"
  exit 0
fi
```

#### `acore_format_json_files()`

Main function to format all JSON files in the project.

**Features:**

- Searches for `*.json` files recursively
- Respects `.gitignore` and `.prettierignore`
- Provides installation instructions if Prettier is missing
- Uses Prettier with standard JSON formatting rules

**Example:**

```bash
# Format all JSON files with verbose output
export VERBOSE=true
acore_format_json_files
```

### Environment Variables

| Variable  | Default   | Description                   |
| --------- | --------- | ----------------------------- |
| `VERBOSE` | `"false"` | Enable verbose logging output |

### Integration Example

```bash
#!/usr/bin/env bash
# Pre-commit hook for JSON formatting

source "$(dirname "$0")/../acore/src/format_json.sh"

acore_log_header "JSON Formatting Check"
acore_format_json_files

if [[ $? -eq 0 ]]; then
  acore_log_success "All JSON files properly formatted"
  exit 0
else
  acore_log_error "JSON formatting failed"
  exit 1
fi
```

---

## YAML Formatter (`format_yaml.sh`)

Formats YAML files using Prettier for consistent structure and readability.

### Dependencies

- **Prettier**: Required for YAML formatting (gracefully handled if missing)

### Usage

```bash
# Source as a library
source "$(dirname "$0")/format_yaml.sh"

# Format all YAML files
acore_format_yaml_files

# Execute directly
./format_yaml.sh
```

### Functions

#### `acore_format_yaml_check_prettier()`

Checks if Prettier is installed and available in PATH.

**Returns:**

- `0`: Prettier is available
- `1`: Prettier is not installed

#### `acore_format_yaml_check_files()`

Checks if there are any YAML files (`.yml` or `.yaml`) in the current directory.

**Returns:**

- `0`: YAML files found
- `1`: No YAML files found

#### `acore_format_yaml_files()`

Main function to format all YAML files in the project.

**Features:**

- Searches for `*.yml` and `*.yaml` files recursively
- Respects `.gitignore` and `.prettierignore`
- Provides installation instructions if Prettier is missing
- Uses Prettier with standard YAML formatting rules

**Example:**

```bash
# Format with custom configuration
acore_format_yaml_files
```

### Environment Variables

| Variable  | Default   | Description                   |
| --------- | --------- | ----------------------------- |
| `VERBOSE` | `"false"` | Enable verbose logging output |

### Integration Example

```bash
#!/usr/bin/env bash
# CI/CD pipeline YAML formatting check

source "$(dirname "$0")/acore/src/format_yaml.sh"

acore_log_header "YAML Format Validation"
if acore_format_yaml_files; then
  acore_log_success "YAML files formatted correctly"
else
  acore_log_warning "Prettier not available - skipping YAML formatting"
fi
```

---

## Markdown Formatter (`format_md.sh`)

Formats Markdown files using Prettier for consistent documentation formatting.

### Dependencies

- **Prettier**: Required for Markdown formatting (gracefully handled if missing)

### Usage

```bash
# Source as a library
source "$(dirname "$0")/format_md.sh"

# Format all Markdown files
acore_format_md_files

# Execute directly
./format_md.sh
```

### Functions

#### `acore_format_md_check_prettier()`

Checks if Prettier is installed and available in PATH.

**Returns:**

- `0`: Prettier is available
- `1`: Prettier is not installed

#### `acore_format_md_check_files()`

Checks if there are any Markdown files (`.md`) in the current directory.

**Returns:**

- `0`: Markdown files found
- `1`: No Markdown files found

#### `acore_format_md_files()`

Main function to format all Markdown files in the project.

**Features:**

- Searches for `*.md` files recursively
- Respects `.gitignore` and `.prettierignore`
- Provides installation instructions if Prettier is missing
- Uses Prettier with standard Markdown formatting rules

**Example:**

```bash
# Format documentation files
acore_format_md_files
```

### Environment Variables

| Variable  | Default   | Description                   |
| --------- | --------- | ----------------------------- |
| `VERBOSE` | `"false"` | Enable verbose logging output |

### Integration Example

```bash
#!/usr/bin/env bash
# Documentation formatting script

source "$(dirname "$0")/acore/src/format_md.sh"

acore_log_header "Formatting Documentation"
acore_format_md_files
acore_log_success "Documentation formatting complete"
```

---

## Shell Script Formatter (`format_sh.sh`)

Formats shell scripts using shfmt with comprehensive options and git
integration.

### Dependencies

- **shfmt**: Required for shell script formatting (gracefully handled if
  missing)

### Usage

```bash
# Source as a library
source "$(dirname "$0")/format_sh.sh"

# Format all shell scripts
acore_sh_format_all

# Execute directly
./format_sh.sh
```

### Functions

#### `acore_sh_command_exists(command)`

Checks if a command exists in the system PATH.

**Parameters:**

- `command`: Command name to check

**Returns:**

- `0`: Command exists
- `1`: Command does not exist

**Example:**

```bash
if acore_sh_command_exists shfmt; then
  acore_log_info "shfmt is available"
else
  acore_log_warning "shfmt not found"
fi
```

#### `acore_sh_check_shfmt()`

Checks if shfmt is installed and provides installation instructions if missing.

**Returns:**

- `0`: shfmt is available
- `1`: shfmt is not installed

#### `acore_sh_build_options()`

Builds shfmt command options from environment variables.

**Sets global variable:**

- `SHFMT_OPTS`: Complete options string for shfmt command

**Environment Variables Used:**

- `INDENT_SIZE`: Indentation size (default: 2)
- `BINARY_NEXT_LINE`: Place binary operators on new line (default: true)
- `SWITCH_CASE_INDENT`: Indent switch cases (default: true)
- `SPACE_REDIRECTS`: Add spaces around redirection operators (default: true)
- `KEEP_PADDING`: Keep column alignment padding (default: false)
- `CHECK_ONLY`: Check mode only, don't write changes (default: false)

#### `acore_sh_format_file(file)`

Formats a single shell script file.

**Parameters:**

- `file`: Path to the shell script file to format

**Features:**

- Validates file is a shell script (shebang or file command)
- Applies shfmt formatting with configured options
- Provides detailed logging in check mode

**Returns:**

- `0`: File formatted successfully or doesn't need formatting
- `1`: Formatting failed or file needs formatting (in check mode)

**Example:**

```bash
acore_sh_format_file "./scripts/deploy.sh"
```

#### `acore_sh_check_git_ignore(file)`

Checks if a file is ignored by git.

**Parameters:**

- `file`: File path to check

**Returns:**

- `0`: File is ignored by git
- `1`: File is not ignored or git not available

**Features:**

- Only runs when `.git` directory exists
- Uses `git check-ignore` for accurate ignoring
- Gracefully handles git unavailability

#### `acore_sh_find_shell_scripts(dir, recursive)`

Finds shell scripts in the specified directory.

**Parameters:**

- `dir`: Directory to search (default: `.`)
- `recursive`: Search recursively (default: true)

**Features:**

- Finds `*.sh` files
- Finds executable files with shell shebangs
- Excludes `.git` directory completely
- Respects `.gitignore` patterns
- Handles both recursive and non-recursive searches

**Returns:**

- Outputs list of found shell script files, one per line

**Example:**

```bash
# Find all shell scripts recursively
acore_sh_find_shell_scripts

# Find only in current directory
acore_sh_find_shell_scripts "." false

# Find in specific directory
acore_sh_find_shell_scripts "./scripts"
```

#### `acore_sh_format_all()`

Main function to format all shell scripts in the project.

**Features:**

- Searches for shell scripts using `acore_sh_find_shell_scripts()`
- Validates shfmt availability
- Builds formatting options
- Processes all found files
- Provides comprehensive summary

**Returns:**

- `0`: All operations successful
- `1`: Some operations failed

### Environment Variables

| Variable             | Default   | Description                             |
| -------------------- | --------- | --------------------------------------- |
| `INDENT_SIZE`        | `"2"`     | Number of spaces for indentation        |
| `BINARY_NEXT_LINE`   | `"true"`  | Place binary operators on new line      |
| `SWITCH_CASE_INDENT` | `"true"`  | Indent switch cases                     |
| `SPACE_REDIRECTS`    | `"true"`  | Add spaces around redirection operators |
| `KEEP_PADDING`       | `"false"` | Keep column alignment padding           |
| `RECURSIVE`          | `"true"`  | Search recursively                      |
| `CHECK_ONLY`         | `"false"` | Check mode only, don't write changes    |
| `VERBOSE`            | `"false"` | Enable verbose logging output           |
| `TARGET_DIR`         | `"."`     | Target directory to search              |

### Integration Examples

#### Pre-commit Hook

```bash
#!/usr/bin/env bash
# Pre-commit hook for shell script formatting

source "$(dirname "$0")/../acore/src/format_sh.sh"

export CHECK_ONLY=true
acore_log_header "Shell Script Format Check"

if acore_sh_format_all; then
  acore_log_success "All shell scripts properly formatted"
  exit 0
else
  acore_log_error "Shell scripts need formatting"
  acore_log_info "Run: ./scripts/acore/src/format_sh.sh"
  exit 1
fi
```

#### CI/CD Pipeline

```bash
#!/usr/bin/env bash
# GitHub Actions step for shell script validation

name: Check Shell Script Formatting
run: |
  source ./scripts/acore/src/format_sh.sh

  export CHECK_ONLY=true VERBOSE=true
  acore_sh_format_all

  if [[ $? -eq 0 ]]; then
    echo "✅ All shell scripts are properly formatted"
  else
    echo "❌ Shell scripts need formatting"
    exit 1
  fi
```

#### Custom Configuration

```bash
#!/usr/bin/env bash
# Custom formatting configuration

source "$(dirname "$0")/format_sh.sh"

# Custom formatting preferences
export INDENT_SIZE=4
export BINARY_NEXT_LINE=false
export KEEP_PADDING=true
export VERBOSE=true

acore_log_header "Custom Shell Script Formatting"
acore_sh_format_all
```

For more information, see the [main documentation](README.md) and
[Product Requirements Document](PRD.md).
