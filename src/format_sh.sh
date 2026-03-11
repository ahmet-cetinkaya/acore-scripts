#!/usr/bin/env bash

# 🐚 Shell script formatting utility
# Formats shell scripts using shfmt

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source logger utilities
# shellcheck source=/dev/null
source "$SCRIPT_DIR/logger.sh"

# Configuration (shfmt defaults)
INDENT_SIZE="${INDENT_SIZE:-2}"
BINARY_NEXT_LINE="${BINARY_NEXT_LINE:-true}"
SWITCH_CASE_INDENT="${SWITCH_CASE_INDENT:-true}"
SPACE_REDIRECTS="${SPACE_REDIRECTS:-true}"
KEEP_PADDING="${KEEP_PADDING:-false}"
RECURSIVE="${RECURSIVE:-true}"
CHECK_ONLY="${CHECK_ONLY:-false}"
VERBOSE="${VERBOSE:-false}"
TARGET_DIR="${TARGET_DIR:-.}"

# shfmt command options
SHFMT_OPTS=""

# Function to check if command exists
acore_sh_command_exists() {
  command -v "$1" > /dev/null 2>&1
}

# Function to check if shfmt is available
acore_sh_check_shfmt() {
  if ! acore_sh_command_exists shfmt; then
    acore_log_warning "shfmt is not installed or not in PATH"
    acore_log_info "To format shell scripts, install shfmt:"
    acore_log_info "  Go:     go install mvdan.cc/sh/v3/cmd/shfmt@latest"
    return 1
  fi
  return 0
}

# Function to build shfmt options
acore_sh_build_options() {
  local opts=()

  # Indentation
  opts+=("-i" "$INDENT_SIZE")

  # Binary operators
  if [[ "$BINARY_NEXT_LINE" == "true" ]]; then
    opts+=("-bn")
  fi

  # Switch case indentation
  if [[ "$SWITCH_CASE_INDENT" == "true" ]]; then
    opts+=("-ci")
  fi

  # Space redirects
  if [[ "$SPACE_REDIRECTS" == "true" ]]; then
    opts+=("-sr")
  fi

  # Keep padding
  if [[ "$KEEP_PADDING" == "true" ]]; then
    opts+=("-kp")
  fi

  # Check mode
  if [[ "$CHECK_ONLY" == "true" ]]; then
    opts+=("-d")
  else
    opts+=("-w")
  fi

  SHFMT_OPTS="${opts[*]}"
}

# Function to format file
acore_sh_format_file() {
  local file=$1

  # Check if file is actually a shell script
  if [[ ! -f "$file" ]]; then
    acore_log_error "File not found: $file"
    return 1
  fi

  # Basic shell script detection
  if ! file "$file" 2> /dev/null | grep -qi "shell script\|bash\|sh"; then
    # Check shebang line
    if ! head -n1 "$file" 2> /dev/null | grep -q '^#!.*\(bash\|sh\|ksh\|zsh\|dash\)$'; then
      [[ "$VERBOSE" == "true" ]] && acore_log_info "Skipping non-shell file: $file"
      return 0
    fi
  fi

  [[ "$VERBOSE" == "true" ]] && acore_log_info "Formatting shell script: $file"

  # Run shfmt
  # shellcheck disable=SC2086
  if shfmt $SHFMT_OPTS "$file" 2> /dev/null; then
    if [[ "$CHECK_ONLY" == "true" ]]; then
      [[ "$VERBOSE" == "true" ]] && acore_log_success "File is properly formatted: $file"
    fi
    return 0
  else
    local exit_code=$?
    if [[ "$CHECK_ONLY" == "true" ]] && [[ $exit_code -eq 1 ]]; then
      acore_log_warning "File needs formatting: $file"
      return 1
    else
      acore_log_error "Failed to format file: $file"
      return 1
    fi
  fi
}

# Function to check if file is ignored by git
acore_sh_check_git_ignore() {
  local file=$1
  # Check if .git exists and git check-ignore command works
  if [[ -d ".git" ]] && command -v git > /dev/null 2>&1; then
    # Use git check-ignore to see if file is ignored
    git check-ignore -q "$file" 2> /dev/null
    return $?
  fi
  return 1 # Not ignored if git is not available
}

# Function to find shell scripts
acore_sh_find_shell_scripts() {
  local dir=${1:-$TARGET_DIR}
  local recursive=${2:-$RECURSIVE}

  # Find .sh files, excluding .git directory and respecting .gitignore
  if [[ "$recursive" == "true" ]]; then
    find "$dir" -type f -name "*.sh" -not -path "./.git/*" 2> /dev/null | while read -r file; do
      if ! acore_sh_check_git_ignore "$file"; then
        echo "$file"
      fi
    done
  else
    find "$dir" -maxdepth 1 -type f -name "*.sh" -not -path "./.git/*" 2> /dev/null | while read -r file; do
      if ! acore_sh_check_git_ignore "$file"; then
        echo "$file"
      fi
    done
  fi

  # Also find executable files without extension that might be shell scripts
  if [[ "$recursive" == "true" ]]; then
    find "$dir" -type f -executable ! -name "*.sh" -not -path "./.git/*" 2> /dev/null | while read -r file; do
      if ! acore_sh_check_git_ignore "$file"; then
        if head -n1 "$file" 2> /dev/null | grep -q '^#!.*\(bash\|sh\|ksh\|zsh\|dash\)$'; then
          echo "$file"
        fi
      fi
    done
  else
    find "$dir" -maxdepth 1 -type f -executable ! -name "*.sh" -not -path "./.git/*" 2> /dev/null | while read -r file; do
      if ! acore_sh_check_git_ignore "$file"; then
        if head -n1 "$file" 2> /dev/null | grep -q '^#!.*\(bash\|sh\|ksh\|zsh\|dash\)$'; then
          echo "$file"
        fi
      fi
    done
  fi
}

# Main function to format all shell scripts
acore_sh_format_all() {
  # Find shell scripts
  local files
  mapfile -t files < <(acore_sh_find_shell_scripts)

  if [[ ${#files[@]} -eq 0 ]]; then
    acore_log_info "No shell scripts found"
    return 0
  fi

  # Check if shfmt is available
  if ! acore_sh_check_shfmt; then
    acore_log_warning "Cannot format shell scripts without shfmt"
    acore_log_warning "Continuing without shell script formatting..."
    return 1
  fi

  # Build shfmt options
  acore_sh_build_options

  acore_log_section "🐚 Formatting Shell Scripts"
  acore_log_info "Using shfmt formatter"

  # Process files
  local exit_code=0
  for file in "${files[@]}"; do
    if ! acore_sh_format_file "$file"; then
      exit_code=1
    fi
  done

  # Summary
  if [[ "$CHECK_ONLY" == "true" ]]; then
    if [[ $exit_code -eq 0 ]]; then
      acore_log_success "All files are properly formatted"
    else
      acore_log_warning "Some files need formatting"
    fi
  else
    if [[ $exit_code -eq 0 ]]; then
      acore_log_success "Formatting completed successfully"
    else
      acore_log_warning "Formatting completed with some issues"
    fi
  fi

  return $exit_code
}

# If script is executed directly, run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  acore_sh_format_all
  # Don't exit with error code for missing shfmt - just warn
  exit 0
fi
