# Knowledge Base - acore-scripts

A comprehensive collection of usage patterns, best practices, and solutions for common scenarios when working with acore-scripts.

## Table of Contents

- [Getting Started](#getting-started)
  - [Installation Methods](#installation-methods)
  - [Quick Setup](#quick-setup)
  - [First Script Integration](#first-script-integration)
- [Usage Patterns](#usage-patterns)
  - [Logging Patterns](#logging-patterns)
  - [Error Handling Patterns](#error-handling-patterns)
  - [Configuration Patterns](#configuration-patterns)
  - [Integration Patterns](#integration-patterns)
- [Common Scenarios](#common-scenarios)
  - [Deployment Scripts](#deployment-scripts)
  - [Build Scripts](#build-scripts)
  - [Database Scripts](#database-scripts)
  - [Maintenance Scripts](#maintenance-scripts)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Performance Considerations](#performance-considerations)
- [Advanced Topics](#advanced-topics)

---

## Getting Started

### Installation Methods

#### Method 1: Git Submodule (Recommended)

**Best for:** Projects that want to stay updated with the latest improvements

```bash
# Navigate to your project
cd your-project

# Add as submodule
git submodule add https://github.com/ahmet-cetinkaya/acore-scripts.git scripts/acore

# Initialize and update
git submodule update --init --recursive

# Update to latest version
git submodule update --remote scripts/acore
```

**Directory Structure:**

```
your-project/
├── scripts/
│   └── acore/
│       └── src/
│           └── logger.sh
├── your-script.sh
└── ...
```

#### Method 2: Direct Clone

**Best for:** Standalone usage or testing

```bash
git clone https://github.com/ahmet-cetinkaya/acore-scripts.git
cd acore-scripts
```

#### Method 3: Individual Script Copy

**Best for:** Projects that only need specific functionality

```bash
# Copy individual scripts
cp acore-scripts/src/logger.sh your-project/scripts/

# Or download directly
curl -o your-project/scripts/logger.sh https://raw.githubusercontent.com/ahmet-cetinkaya/acore-scripts/main/src/logger.sh

# Make executable
chmod +x your-project/scripts/logger.sh
```

### Quick Setup

Once installed, add this to your shell scripts to enable logging:

```bash
#!/bin/bash

# Source the logger (adjust path based on installation method)
source "$(dirname "$0")/path/to/logger.sh"

# Your script logic here
acore_log_info "Script started"
```

### First Script Integration

Create your first script with logging:

```bash
#!/bin/bash
# File: my-first-script.sh

# Source the logger (for git submodule)
source "$(dirname "$0")/../scripts/acore/src/logger.sh"

# Configure logging
acore_set_log_config "INFO" "true" "true" "true"

# Script starts here
acore_log_header "My First Script"
acore_log_info "Starting execution..."

# Example processing
acore_log_section "Processing Data"
for file in *.txt; do
  acore_log_info "Processing: $file"
  # Your processing logic here
  acore_log_success "Completed: $file"
done

acore_log_success "All files processed successfully"
```

---

## Usage Patterns

### Logging Patterns

#### Progressive Verbosity

```bash
#!/bin/bash
source logger.sh

# Start with normal verbosity
acore_set_log_config "INFO"

# Enable debug mode if requested
if [[ "$1" == "--debug" ]]; then
  acore_log_info "Debug mode enabled"
  acore_set_log_config "DEBUG"
fi

# Your script logic
acore_log_debug "Detailed debugging info"
acore_log_info "General information"
```

#### Environment-based Configuration

```bash
#!/bin/bash
source logger.sh

# Configure based on environment
case "${ENVIRONMENT:-development}" in
  "production")
    acore_set_log_config "WARNING" "true" "true" "false"
    ;;
  "staging")
    acore_set_log_config "INFO" "true" "true" "true"
    ;;
  "development")
    acore_set_log_config "DEBUG" "true" "true" "true"
    ;;
esac

acore_log_info "Environment: $ENVIRONMENT"
```

#### Contextual Logging

```bash
#!/bin/bash
source logger.sh

# Function with contextual logging
process_file() {
  local file=$1

  acore_log_section "Processing: $file"

  if [[ ! -f "$file" ]]; then
    acore_log_error "File not found: $file"
    return 1
  fi

  acore_log_debug "Reading file: $file"
  local content=$(cat "$file")

  acore_log_debug "File size: ${#content} characters"

  # Process content
  acore_log_info "Processing complete"
  acore_log_success "File processed: $file"
}

# Usage
process_file "data.txt"
```

### Error Handling Patterns

#### Exit on Error with Logging

```bash
#!/bin/bash
source logger.sh

# Helper function for error handling
require_file() {
  local file=$1
  if [[ ! -f "$file" ]]; then
    acore_log_and_exit 1 "Required file not found: $file"
  fi
}

# Usage
require_file "config.json"
require_file "database.yml"

acore_log_success "All required files found"
```

#### Command Validation

```bash
#!/bin/bash
source logger.sh

# Validate commands before execution
validate_commands() {
  local commands=("git" "node" "npm")

  for cmd in "${commands[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
      acore_log_and_exit 1 "Required command not found: $cmd"
    fi
  done

  acore_log_success "All required commands available"
}

# Usage
validate_commands
```

#### Try-Catch Pattern

```bash
#!/bin/bash
source logger.sh

# Simulate try-catch with logging
try_command() {
  local description="$1"
  shift

  acore_log_info "Attempting: $description"

  if "$@"; then
    acore_log_success "Completed: $description"
    return 0
  else
    acore_log_error "Failed: $description"
    return 1
  fi
}

# Usage
try_command "Building application" npm run build
try_command "Running tests" npm test
```

### Configuration Patterns

#### Configuration File Loading

```bash
#!/bin/bash
source logger.sh

# Load configuration with validation
load_config() {
  local config_file="${1:-config.sh}"

  acore_log_section "Loading Configuration"

  if [[ ! -f "$config_file" ]]; then
    acore_log_warning "Config file not found: $config_file"
    acore_log_info "Using default configuration"
    return 0
  fi

  acore_log_debug "Sourcing config: $config_file"
  source "$config_file"

  acore_log_success "Configuration loaded from: $config_file"
}

# Example config.sh file structure:
# LOG_LEVEL="DEBUG"
# API_BASE_URL="https://api.example.com"
# MAX_RETRIES="3"

# Usage
load_config "config.sh"
acore_log_info "Configuration: LOG_LEVEL=$LOG_LEVEL"
```

#### Command Line Argument Parsing

```bash
#!/bin/bash
source logger.sh

# Parse command line arguments
parse_arguments() {
  LOG_LEVEL="INFO"
  VERBOSE=false
  DRY_RUN=false

  while [[ $# -gt 0 ]]; do
    case $1 in
      --verbose|-v)
        VERBOSE=true
        LOG_LEVEL="DEBUG"
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --log-level)
        LOG_LEVEL="$2"
        shift 2
        ;;
      *)
        acore_log_error "Unknown option: $1"
        exit 1
        ;;
    esac
  done

  acore_set_log_config "$LOG_LEVEL" "true" "true" "true"

  acore_log_info "Configuration:"
  acore_log_info "  Log Level: $LOG_LEVEL"
  acore_log_info "  Verbose: $VERBOSE"
  acore_log_info "  Dry Run: $DRY_RUN"
}

# Usage
parse_arguments "$@"
```

### Integration Patterns

#### Multi-Script Projects

```bash
#!/bin/bash
# File: scripts/common.sh

# Common initialization for all scripts
init_project() {
  # Source utilities
  source "$(dirname "$0")/../acore/src/logger.sh"

  # Project-wide configuration
  export PROJECT_NAME="my-project"
  export LOG_LEVEL="${LOG_LEVEL:-INFO}"

  # Set up logging
  acore_set_log_config "$LOG_LEVEL" "true" "true" "true"

  acore_log_header "$PROJECT_NAME"
}
```

```bash
#!/bin/bash
# File: scripts/deploy.sh

# Use common initialization
source "$(dirname "$0)/common.sh"

# Script-specific logic
init_project
acore_log_info "Starting deployment..."
```

#### Pipeline Integration

```bash
#!/bin/bash
# CI/CD Pipeline Script
source logger.sh

# Pipeline stages with logging
run_pipeline() {
  acore_log_header "CI/CD Pipeline"

  # Stage 1: Setup
  acore_log_section "Setup Environment"
  npm install
  acore_log_success "Dependencies installed"

  # Stage 2: Build
  acore_log_section "Build Application"
  npm run build
  acore_log_success "Build completed"

  # Stage 3: Test
  acore_log_section "Run Tests"
  npm test
  acore_log_success "All tests passed"

  # Stage 4: Deploy
  acore_log_section "Deploy"
  deploy_application
  acore_log_success "Deployment completed"
}

# Usage
run_pipeline
```

---

## Common Scenarios

### Deployment Scripts

```bash
#!/bin/bash
# deploy.sh - Application deployment script
source "$(dirname "$0")/../scripts/acore/src/logger.sh"

# Configuration
DEPLOY_ENV="${DEPLOY_ENV:-production}"
APP_DIR="/var/www/my-app"
BACKUP_DIR="/var/backups/my-app"

deploy_application() {
  acore_log_header "Deploying to $DEPLOY_ENV"

  # Pre-deployment checks
  acore_log_section "Pre-deployment Checks"

  if [[ ! -d "$APP_DIR" ]]; then
    acore_log_and_exit 1 "Application directory not found: $APP_DIR"
  fi

  if [[ ! -w "$APP_DIR" ]]; then
    acore_log_and_exit 1 "No write permission to: $APP_DIR"
  fi

  acore_log_success "Pre-deployment checks passed"

  # Create backup
  acore_log_section "Creating Backup"
  local backup_name="backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP_DIR"
  cp -r "$APP_DIR" "$BACKUP_DIR/$backup_name"
  acore_log_success "Backup created: $BACKUP_DIR/$backup_name"

  # Deploy files
  acore_log_section "Deploying Files"
  rsync -av --delete dist/ "$APP_DIR/"
  acore_log_success "Files deployed"

  # Post-deployment
  acore_log_section "Post-deployment"
  systemctl reload nginx
  acore_log_success "Nginx reloaded"

  acore_log_success "Deployment completed successfully"
}

# Usage
deploy_application
```

### Build Scripts

```bash
#!/bin/bash
# build.sh - Application build script
source logger.sh

build_application() {
  local build_type="${1:-production}"

  acore_log_header "Building Application ($build_type)"

  # Clean previous build
  acore_log_section "Cleaning"
  rm -rf dist/
  acore_log_success "Cleaned previous build"

  # Install dependencies
  acore_log_section "Installing Dependencies"
  if npm ci; then
    acore_log_success "Dependencies installed"
  else
    acore_log_and_exit 1 "Failed to install dependencies"
  fi

  # Run type checking
  acore_log_section "Type Checking"
  npm run type-check
  acore_log_success "Type checking passed"

  # Build application
  acore_log_section "Building"
  case $build_type in
    "development")
      npm run build:dev
      ;;
    "production")
      npm run build:prod
      ;;
    *)
      acore_log_and_exit 1 "Unknown build type: $build_type"
      ;;
  esac

  acore_log_success "Build completed"

  # Build summary
  acore_log_divider
  acore_log_info "Build type: $build_type"
  acore_log_info "Output size: $(du -sh dist/ | cut -f1)"
  acore_log_info "Files created: $(find dist/ -type f | wc -l)"
}

# Usage
build_application "$1"
```

### Database Scripts

```bash
#!/bin/bash
# db-backup.sh - Database backup script
source logger.sh

# Configuration
DB_NAME="${DB_NAME:-myapp}"
DB_USER="${DB_USER:-admin}"
BACKUP_DIR="/var/backups/database"
RETENTION_DAYS=30

backup_database() {
  acore_log_header "Database Backup"

  # Check database connection
  acore_log_section "Checking Database Connection"
  if ! mysql -u "$DB_USER" -e "USE $DB_NAME;" &>/dev/null; then
    acore_log_and_exit 1 "Cannot connect to database: $DB_NAME"
  fi

  acore_log_success "Database connection verified"

  # Create backup directory
  mkdir -p "$BACKUP_DIR"

  # Generate backup filename
  local timestamp=$(date +%Y%m%d-%H%M%S)
  local backup_file="$BACKUP_DIR/${DB_NAME}_backup_$timestamp.sql"

  # Create backup
  acore_log_section "Creating Backup"
  acore_log_info "Backup file: $backup_file"

  if mysqldump -u "$DB_USER" "$DB_NAME" > "$backup_file"; then
    acore_log_success "Backup created successfully"

    # Compress backup
    acore_log_info "Compressing backup"
    gzip "$backup_file"
    acore_log_success "Backup compressed: ${backup_file}.gz"
  else
    acore_log_and_exit 1 "Failed to create backup"
  fi

  # Clean old backups
  acore_log_section "Cleaning Old Backups"
  find "$BACKUP_DIR" -name "${DB_NAME}_backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete
  acore_log_success "Cleaned backups older than $RETENTION_DAYS days"

  acore_log_success "Database backup completed"
}

# Usage
backup_database
```

### Maintenance Scripts

```bash
#!/bin/bash
# maintenance.sh - System maintenance script
source logger.sh

MAINTENANCE_LOG="/var/log/maintenance.log"

run_maintenance() {
  acore_log_header "System Maintenance"

  # Start logging to file
  acore_log_to_file "$MAINTENANCE_LOG" "INFO" "Starting maintenance: $(date)"

  # Clean temporary files
  acore_log_section "Cleaning Temporary Files"
  local temp_size=$(du -sh /tmp 2>/dev/null | cut -f1)
  acore_log_info "Current /tmp size: $temp_size"

  find /tmp -type f -atime +7 -delete 2>/dev/null
  find /tmp -type d -empty -delete 2>/dev/null

  local new_temp_size=$(du -sh /tmp 2>/dev/null | cut -f1)
  acore_log_success "Cleanup completed. New size: $new_temp_size"

  # Update packages (if on Debian/Ubuntu)
  if command -v apt &> /dev/null; then
    acore_log_section "Updating Package Lists"
    apt update
    acore_log_success "Package lists updated"

    acore_log_section "Installing Security Updates"
    if apt upgrade -y; then
      acore_log_success "Security updates installed"
    else
      acore_log_warning "Some security updates failed"
    fi
  fi

  # Check disk space
  acore_log_section "Disk Space Check"
  df -h | while read filesystem size used avail use_percent mount; do
    if [[ "$use_percent" =~ ^([0-9]+)%$ ]]; then
      local usage=${BASH_REMATCH[1]}
      if (( usage > 80 )); then
        acore_log_warning "Low disk space on $filesystem: $use_percent"
      else
        acore_log_debug "Disk usage on $filesystem: $use_percent"
      fi
    fi
  done

  # System health check
  acore_log_section "System Health"

  # Check load average
  local load_avg=$(uptime | awk -F'load average:' '{print $2}')
  acore_log_info "Load average: $load_avg"

  # Check memory usage
  local mem_info=$(free -h | grep "Mem:")
  acore_log_info "Memory usage: $mem_info"

  acore_log_success "Maintenance completed"
  acore_log_to_file "$MAINTENANCE_LOG" "INFO" "Maintenance completed: $(date)"
}

# Usage
run_maintenance
```

---

## Best Practices

### Code Organization

1. **Source Logger Early**: Always source the logger at the top of your script
2. **Configuration First**: Set up logging configuration before any output
3. **Consistent Patterns**: Use the same logging patterns across all scripts
4. **Error Handling**: Always check command exit codes and log failures

### Performance Considerations

1. **Avoid Excessive Logging**: Don't log in tight loops
2. **Use Appropriate Levels**: Reserve DEBUG for detailed troubleshooting
3. **File Logging**: Use file logging sparingly for long-running processes
4. **Color Control**: Disable colors in non-interactive environments

### Security Best Practices

1. **No Sensitive Data**: Never log passwords, tokens, or sensitive information
2. **File Permissions**: Ensure log files have appropriate permissions
3. **Input Validation**: Validate all inputs before processing
4. **Error Messages**: Don't expose system details in error messages

---

## Troubleshooting

### Common Issues

#### Logger Not Found

**Error:** `logger.sh: No such file or directory`

**Solution:**

```bash
# Check the path to logger.sh
ls -la "$(dirname "$0")/path/to/logger.sh"

# Use absolute path for testing
source /full/path/to/logger.sh
```

#### Colors Not Working

**Symptoms:** Output shows color codes like `[0;32m` instead of colors

**Solutions:**

```bash
# Disable colors explicitly
export LOG_COLOR="false"
acore_set_log_config "$LOG_LEVEL" "" "" "false"

# Or check terminal support
if [[ -t 1 ]]; then
  echo "Terminal supports colors"
else
  echo "Output is being redirected, colors disabled"
fi
```

#### Log Level Not Working

**Symptoms:** All log levels showing regardless of configuration

**Solution:**

```bash
# Check current log level
echo "Current LOG_LEVEL: $LOG_LEVEL"

# Set log level explicitly
acore_set_log_config "ERROR"
```

### Debug Mode

Enable comprehensive debugging:

```bash
#!/bin/bash
source logger.sh

# Enable maximum verbosity
acore_set_log_config "DEBUG" "true" "true" "true"

# Debug the script itself
acore_log_debug "Script: $0"
acore_log_debug "Arguments: $*"
acore_log_debug "Working directory: $(pwd)"
acore_log_debug "User: $(whoami)"
```

### Performance Issues

If logging is slowing down your script:

```bash
# Disable file logging
# Don't call acore_log_to_file()

# Reduce verbosity
acore_set_log_config "WARNING"

# Disable colors and formatting
acore_set_log_config "$LOG_LEVEL" "false" "false" "false"
```

---

## Performance Considerations

### Logging Overhead

- **Minimal**: The logger adds minimal overhead (~1-2ms per log call)
- **Color Processing**: Color codes add slight overhead when enabled
- **Timestamps**: `date` command calls add minimal overhead
- **File I/O**: File logging has the highest overhead

### Optimization Tips

```bash
# For high-frequency operations
if [[ "$DEBUG" == "true" ]]; then
  acore_log_debug "Expensive debug info"
fi

# Batch operations
for item in "${large_array[@]}"; do
  process_item "$item"
done
acore_log_info "Processed ${#large_array[@]} items"  # Log once, not per item

# Conditional logging
[[ "$VERBOSE" == "true" ]] && acore_log_debug "Verbose information"
```

### Memory Usage

The logger uses minimal memory:

- ~50KB for function definitions
- ~1KB per color code definition
- No persistent data structures

---

## Advanced Topics

### Custom Log Handlers

```bash
#!/bin/bash
source logger.sh

# Custom log handler for external services
send_to_log_service() {
  local level=$1
  shift
  local message="$*"

  # Send to external service (example)
  curl -X POST "https://logs.example.com/api/log" \
    -H "Content-Type: application/json" \
    -d "{\"level\": \"$level\", \"message\": \"$message\"}" \
    &>/dev/null
}

# Wrapper function that logs and sends to service
log_and_send() {
  local level=$1
  local message=$2

  # Send to standard log
  case $level in
    "INFO") acore_log_info "$message" ;;
    "ERROR") acore_log_error "$message" ;;
    "SUCCESS") acore_log_success "$message" ;;
  esac

  # Send to external service
  send_to_log_service "$level" "$message"
}

# Usage
log_and_send "INFO" "Application started"
```

### Dynamic Configuration

```bash
#!/bin/bash
source logger.sh

# Load configuration from multiple sources
load_configuration() {
  # 1. Default values
  LOG_LEVEL="INFO"
  LOG_COLOR="true"

  # 2. Environment variables
  [[ -n "$ENV_LOG_LEVEL" ]] && LOG_LEVEL="$ENV_LOG_LEVEL"
  [[ -n "$ENV_NO_COLOR" ]] && LOG_COLOR="false"

  # 3. Configuration file
  [[ -f "config.json" ]] && LOG_LEVEL=$(jq -r '.log_level // "INFO"' config.json)

  # 4. Command line arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --quiet) LOG_LEVEL="ERROR" ;;
      --no-color) LOG_COLOR="false" ;;
    esac
    shift
  done

  # Apply configuration
  acore_set_log_config "$LOG_LEVEL" "" "" "$LOG_COLOR"
}
```

### Integration with Monitoring

```bash
#!/bin/bash
source logger.sh

# Metrics collection with logging
collect_metrics() {
  local operation=$1
  local start_time=$(date +%s)

  # Perform operation
  "$@"
  local exit_code=$?

  local end_time=$(date +%s)
  local duration=$((end_time - start_time))

  # Log metrics
  if [[ $exit_code -eq 0 ]]; then
    acore_log_success "$operation completed in ${duration}s"
    # Send to monitoring system
    send_metric "operation.duration" $duration
    send_metric "operation.success" 1
  else
    acore_log_error "$operation failed after ${duration}s"
    send_metric "operation.failure" 1
  fi
}

# Usage
collect_metrics "database_backup" backup_database
```

---

## Contributing to Knowledge Base

When adding new patterns or examples:

1. **Test Thoroughly**: Ensure all examples work as expected
2. **Document Context**: Explain when and why to use each pattern
3. **Include Error Handling**: Show proper error handling for each scenario
4. **Cross-Reference**: Link to related patterns and documentation

For contributions and improvements, please see the [main repository](https://github.com/ahmet-cetinkaya/acore-scripts).

---

_This knowledge base is continuously updated with new patterns and solutions based on real-world usage and community feedback._
