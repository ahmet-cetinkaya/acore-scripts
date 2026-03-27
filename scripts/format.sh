#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACORE_SCRIPTS="${SCRIPT_DIR}/../src"

# shellcheck source=../../src/logger.sh
# shellcheck disable=SC1091
source "${ACORE_SCRIPTS}/logger.sh"

acore_log_info "🐚 Formatting shell scripts with shfmt..."
fd -e sh -t f . "$SCRIPT_DIR" | xargs -d '\n' shfmt -w -sr -ci -ln bash

acore_log_success "✅ Formatting complete!"
