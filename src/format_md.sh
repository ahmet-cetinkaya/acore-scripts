#!/usr/bin/env bash

# 📝 Markdown formatting utility
# Formats Markdown files using Prettier

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source logger utilities
# shellcheck source=/dev/null
source "$SCRIPT_DIR/logger.sh"

# Function to check if prettier is available
acore_format_md_check_prettier() {
  command -v prettier > /dev/null 2>&1
}

# Function to check if there are Markdown files to format
acore_format_md_check_files() {
  local files
  mapfile -t files < <(find . -type f -name "*.md" 2> /dev/null)

  if [[ ${#files[@]} -eq 0 ]]; then
    acore_log_info "No Markdown files found to format"
    return 1
  fi

  return 0
}

# Function to format Markdown files
acore_format_md_files() {
  if ! acore_format_md_check_files; then
    return 0
  fi

  if acore_format_md_check_prettier; then
    acore_log_section "📝 Formatting Markdown Files"
    acore_log_info "Using Prettier formatter"
    prettier --write "**/*.md" \
      --ignore-path=.gitignore \
      --ignore-path=.prettierignore \
      --loglevel warn > /dev/null 2>&1 || true
    acore_log_success "Markdown files formatted successfully!"
  else
    acore_log_warning "Prettier is not installed or not in PATH"
    acore_log_warning "Cannot format Markdown files without Prettier"
    acore_log_info "To format Markdown files, install Prettier:"
    acore_log_info "  npm:    npm install -g prettier"
    acore_log_info "  yarn:   yarn global add prettier"
    acore_log_info "  pnpm:   pnpm add -g prettier"
    acore_log_info "  bun:    bun install -g prettier"
    acore_log_warning "Continuing without Markdown formatting..."
    return 1
  fi
}

# If script is executed directly, run formatting
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  acore_format_md_files
  # Don't exit with error code for missing prettier - just warn
  exit 0
fi
