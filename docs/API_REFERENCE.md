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
