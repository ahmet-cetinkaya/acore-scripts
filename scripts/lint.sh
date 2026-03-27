#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACORE_SCRIPTS="${SCRIPT_DIR}/../src"

# shellcheck source=../../src/logger.sh
# shellcheck disable=SC1091
source "${ACORE_SCRIPTS}/logger.sh"

acore_log_info "🔍 Linting shell scripts with shellcheck..."
mapfile -t shellcheck_scripts < <(fd -e sh -t f . "$SCRIPT_DIR")
if [ ${#shellcheck_scripts[@]} -eq 0 ]; then
	acore_log_warning "No shell scripts found."
	exit 0
fi
shellcheck "${shellcheck_scripts[@]}"

acore_log_success "✨ Linting complete!"
