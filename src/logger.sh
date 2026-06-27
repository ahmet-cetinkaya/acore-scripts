#!/usr/bin/env bash

# Universal logging utilities for shell scripts
# Provides colored output with configurable levels and formatting

# Color codes
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_PURPLE='\033[0;35m'
COLOR_CYAN='\033[0;36m'
COLOR_WHITE='\033[1;37m'
COLOR_GRAY='\033[0;90m'
COLOR_NC='\033[0m' # No Color

# Configuration
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_PREFIX="${LOG_PREFIX:-true}"
LOG_TIMESTAMP="${LOG_TIMESTAMP:-false}"
LOG_COLOR="${LOG_COLOR:-true}"
LOG_WIDTH="${LOG_WIDTH:-66}"

# Get terminal width dynamically
acore_get_terminal_width() {
	local width
	# Try tput cols (most portable across Unix systems)
	if width=$(tput cols 2>/dev/null) && [[ -n "$width" && "$width" -gt 0 ]]; then
		echo "$width"
		return
	fi
	# Fallback to configured LOG_WIDTH
	echo "$LOG_WIDTH"
}

# Utility function to repeat a character
acore_repeat_char() {
	local char=$1
	local count=$2
	printf "%${count}s" | tr ' ' "$char"
}

# Timestamp function
get_timestamp() {
	date '+%Y-%m-%d %H:%M:%S'
}

# Print with optional prefix and timestamp
_print_with_formatting() {
	local level=$1
	local color=$2
	local message=$3

	local prefix=""
	if [[ "$LOG_PREFIX" == "true" ]]; then
		prefix="[$level]"
	fi

	local timestamp=""
	if [[ "$LOG_TIMESTAMP" == "true" ]]; then
		timestamp="[$(get_timestamp)]"
	fi

	local color_code=""
	local reset_code=""
	if [[ "$LOG_COLOR" == "true" ]]; then
		color_code=$color
		reset_code=$COLOR_NC
	fi

	printf "%b%b%b%b %s\n" "${timestamp}" "${color_code}" "${prefix}" "${reset_code}" "${message}" >&2
}

# Logging functions
acore_log_debug() {
	if [[ "$LOG_LEVEL" == "DEBUG" ]]; then
		_print_with_formatting "DEBUG" "$COLOR_GRAY" "$*"
	fi
}

acore_log_info() {
	if [[ "$LOG_LEVEL" == "DEBUG" || "$LOG_LEVEL" == "INFO" ]]; then
		_print_with_formatting "INFO" "$COLOR_BLUE" "$*"
	fi
}

acore_log_success() {
	if [[ "$LOG_LEVEL" != "ERROR" ]]; then
		_print_with_formatting "SUCCESS" "$COLOR_GREEN" "$*"
	fi
}

acore_log_warning() {
	if [[ "$LOG_LEVEL" != "ERROR" ]]; then
		_print_with_formatting "WARNING" "$COLOR_YELLOW" "$*"
	fi
}

acore_log_error() {
	_print_with_formatting "ERROR" "$COLOR_RED" "$*" >&2
}

acore_log_critical() {
	_print_with_formatting "CRITICAL" "$COLOR_RED" "$*" >&2
}

# Utility functions
acore_log_header() {
	local title="$1"
	local char="${2:-=}"
	local width
	width=$(acore_get_terminal_width)

	# Calculate padding for left-aligned text (reserve space for safety)
	local title_length=${#title}
	local text_length=$((title_length + 4))  # 2 chars + title + 2 chars
	local padding=$((width - text_length))

	# Ensure padding doesn't go negative
	if [[ $padding -lt 0 ]]; then
		padding=0
	fi

	if [[ "$LOG_COLOR" == "true" ]]; then
		printf "%b" "${COLOR_CYAN}${char}${char} ${title} " >&2
		printf "%b" "${COLOR_CYAN}" >&2
		printf "%${padding}s" | tr ' ' "$char" >&2
		printf "%b\n" "${COLOR_NC}" >&2
	else
		printf "%s" "${char}${char} ${title} " >&2
		printf "%${padding}s" | tr ' ' "$char" >&2
		printf "\n" >&2
	fi
}

acore_log_section() {
	local title="$1"
	local char="${2:--}"
	local width
	width=$(acore_get_terminal_width)

	# Calculate padding for left-aligned text (reserve space for safety)
	local title_length=${#title}
	local text_length=$((title_length + 4))  # 2 chars + title + 2 chars
	local padding=$((width - text_length))

	# Ensure padding doesn't go negative
	if [[ $padding -lt 0 ]]; then
		padding=0
	fi

	if [[ "$LOG_COLOR" == "true" ]]; then
		printf "%b" "${COLOR_PURPLE}" >&2
		printf "%s" "-- ${title} " >&2
		printf "%b" "${COLOR_NC}" >&2
		printf "%b" "${COLOR_PURPLE}" >&2
		printf "%${padding}s" | tr ' ' "$char" >&2
		printf "%b\n" "${COLOR_NC}" >&2
	else
		printf "%s" "-- ${title} " >&2
		printf "%${padding}s" | tr ' ' "$char" >&2
		printf "\n" >&2
	fi
}

acore_log_divider() {
	local width
	width=$(acore_get_terminal_width)
	local separator
	separator=$(acore_repeat_char "-" "$width")
	printf "%s\n" "${separator}"
}

# Special formatting functions
acore_log_bold() {
	if [[ "$LOG_COLOR" == "true" ]]; then
		printf "%b%s%b\n" "${COLOR_WHITE}" "$*" "${COLOR_NC}"
	else
		printf "%s\n" "$*"
	fi
}

acore_log_italic() {
	# Note: Italic may not work in all terminals
	if [[ "$LOG_COLOR" == "true" ]]; then
		printf "%b%s%b\n" "${COLOR_PURPLE}" "$*" "${COLOR_NC}"
	else
		printf "%s\n" "$*"
	fi
}

# Logging to file
acore_log_to_file() {
	local file_path=$1
	local level=$2
	shift 2
	local message="$*"

	mkdir -p "$(dirname "$file_path")"
	echo "$(get_timestamp) [$level] $message" >>"$file_path"
}

# Error handling with logging
acore_log_and_exit() {
	local exit_code=$1
	shift
	acore_log_error "$*"
	exit "$exit_code"
}

# Progress indicators
acore_log_spinner() {
	local pid=$1
	local delay=0.1
	local spinstr="|/-\\"

	while kill -0 "$pid" 2>/dev/null; do
		local temp=${spinstr#?}
		printf "\r%s" "${temp}" >&2
		spinstr=$temp${spinstr%"$temp"}
		sleep "$delay"
	done
	printf "\r" >&2
}

# Configuration function
acore_set_log_config() {
	local level=$1
	local show_prefix=${2:-$LOG_PREFIX}
	local show_timestamp=${3:-$LOG_TIMESTAMP}
	local use_color=${4:-$LOG_COLOR}

	case $level in
	DEBUG | INFO | WARNING | ERROR | CRITICAL)
		export LOG_LEVEL=$level
		;;
	*)
		acore_log_error "Invalid log level: $level"
		return 1
		;;
	esac

	export LOG_PREFIX=$show_prefix
	export LOG_TIMESTAMP=$show_timestamp
	export LOG_COLOR=$use_color
}

# Example usage:
# source logger.sh
# acore_log_info "Starting application"
# acore_log_error "Something went wrong"
# acore_set_log_config DEBUG true true false

# End of logger utilities
