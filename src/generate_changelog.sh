#!/bin/bash

# Script to create changelogs following "Keep a Changelog" standards
# Usage: ./src/generate_changelog.sh --help

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MAIN_CHANGELOG="$PROJECT_ROOT/CHANGELOG.md"

# Source logger utilities
# shellcheck source=/dev/null
source "$SCRIPT_DIR/logger.sh"

# Function to show help
_show_help() {
  cat << 'EOF'
acore-changelog - Generate changelogs from git commits

USAGE:
    generate_changelog.sh [OPTIONS] [VERSION] [TEXT]

OPTIONS:
    -y              Auto-accept generated changelog
    --all-versions  Generate for all historical versions
    -h, --help      Show this help

EXAMPLES:
    generate_changelog.sh -y
    generate_changelog.sh 1.2.3 -y
    generate_changelog.sh --all-versions -y
    generate_changelog.sh 1.2.3 "Manual changelog text"
EOF
}

# Parse arguments
AUTO_ACCEPT=false
ALL_VERSIONS=false
VERSION_CODE=""
CHANGELOG_TEXT=""

for arg in "$@"; do
  case $arg in
    --help | -h)
      _show_help
      exit 0
      ;;
    -y)
      AUTO_ACCEPT=true
      shift
      ;;
    --all-versions)
      ALL_VERSIONS=true
      shift
      ;;
    *)
      if [ -z "$VERSION_CODE" ]; then
        VERSION_CODE="$arg"
      elif [ -z "$CHANGELOG_TEXT" ]; then
        CHANGELOG_TEXT="$arg"
      fi
      shift
      ;;
  esac
done

# Get current version from git tags or use default
CURRENT_VERSION=$(git describe --tags --abbrev=0 2> /dev/null || echo "1.0.0")
VERSION_CODE=${VERSION_CODE:-$CURRENT_VERSION}

# Function to capitalize first letter of a string
_capitalize_first_letter() {
  local text="$1"
  echo "$(echo "${text:0:1}" | tr '[:lower:]' '[:upper:]')${text:1}"
}

# Function to generate changelog from git commits
_generate_from_commits() {
  local start_tag="$1"
  local end_tag="$2"

  cd "$PROJECT_ROOT"

  # If generating for current version (no parameters), use latest tag to HEAD
  if [ -z "$start_tag" ] && [ -z "$end_tag" ]; then
    # Get the latest version tag
    LATEST_TAG=$(git tag --sort=-version:refname | head -1)

    if [ -z "$LATEST_TAG" ]; then
      acore_log_warning "No version tags found. Using all commits from the beginning."
      COMMIT_RANGE="HEAD"
    else
      COMMIT_RANGE="$LATEST_TAG..HEAD"
      acore_log_info "Generating changelog from commits since tag: $LATEST_TAG to current changes"
    fi
  elif [ -z "$start_tag" ]; then
    # No start tag but end tag provided - get all commits from beginning to end_tag
    COMMIT_RANGE="$end_tag"
    acore_log_info "Generating changelog from all commits up to tag: $end_tag"
  elif [ -z "$end_tag" ]; then
    # No end tag, use HEAD
    COMMIT_RANGE="$start_tag..HEAD"
    acore_log_info "Generating changelog from commits between $start_tag and HEAD"
  else
    COMMIT_RANGE="$start_tag..$end_tag"
    acore_log_info "Generating changelog from commits between $start_tag and $end_tag"
  fi

  # Get commit messages and categorize them
  ADDED=""
  CHANGED=""
  DEPRECATED=""
  REMOVED=""
  FIXED=""
  SECURITY=""

  while IFS= read -r commit; do
    if [ -n "$commit" ]; then
      # Extract commit message (everything after the hash and space)
      MESSAGE=$(echo "$commit" | cut -d' ' -f2-)

      # Skip version bump commits and merge commits
      if [[ ! "$MESSAGE" =~ ^(chore:\ update\ app\ version|Merge\ ) ]]; then
        # Categorize commit message - only user-facing changes
        if [[ "$MESSAGE" =~ ^(feat|fix|docs|style|refactor|perf|test|chore|ci|build)(\(.+\))?:\ (.+)$ ]]; then
          # Conventional commit format
          TYPE=$(echo "$MESSAGE" | cut -d':' -f1 | sed 's/(.*//')
          DESCRIPTION=$(echo "$MESSAGE" | cut -d':' -f2- | sed 's/^ *//')
          DESCRIPTION=$(_capitalize_first_letter "$DESCRIPTION")

          # Only include user-facing commit types
          case "$TYPE" in
            "feat")
              # New features for users
              if [ -z "$ADDED" ]; then
                ADDED="- $DESCRIPTION"
              else
                ADDED="$ADDED\n- $DESCRIPTION"
              fi
              ;;
            "fix")
              # Bug fixes
              if [ -z "$FIXED" ]; then
                FIXED="- $DESCRIPTION"
              else
                FIXED="$FIXED\n- $DESCRIPTION"
              fi
              ;;
            "perf")
              # Performance improvements
              if [ -z "$CHANGED" ]; then
                CHANGED="- $DESCRIPTION"
              else
                CHANGED="$CHANGED\n- $DESCRIPTION"
              fi
              ;;
            "refactor")
              # Only include refactors that affect user experience
              if [[ "$DESCRIPTION" =~ (UI|user|interface|experience|performance) ]]; then
                if [ -z "$CHANGED" ]; then
                  CHANGED="- $DESCRIPTION"
                else
                  CHANGED="$CHANGED\n- $DESCRIPTION"
                fi
              fi
              ;;
              # Skip these types as they don't affect end users:
              # "docs" - documentation changes
              # "style" - code style changes
              # "test" - test additions/changes
              # "build" - build system changes
              # "ci" - CI/CD changes
              # "chore" - maintenance tasks
          esac
        else
          # Non-conventional commit - only include if it seems user-facing
          if [[ "$MESSAGE" =~ ^(add|new|create).*(feature|function|capability) ]] \
            || [[ "$MESSAGE" =~ ^(improve|enhance|update).*(UI|user|interface|performance) ]] \
            || [[ "$MESSAGE" =~ ^(fix|resolve|correct).*(bug|issue|problem|error) ]]; then

            MESSAGE=$(_capitalize_first_letter "$MESSAGE")

            if [[ "$MESSAGE" =~ ^(Add|New|Create) ]]; then
              if [ -z "$ADDED" ]; then
                ADDED="- $MESSAGE"
              else
                ADDED="$ADDED\n- $MESSAGE"
              fi
            elif [[ "$MESSAGE" =~ ^(Fix|Resolve|Correct) ]]; then
              if [ -z "$FIXED" ]; then
                FIXED="- $MESSAGE"
              else
                FIXED="$FIXED\n- $MESSAGE"
              fi
            else
              if [ -z "$CHANGED" ]; then
                CHANGED="- $MESSAGE"
              else
                CHANGED="$CHANGED\n- $MESSAGE"
              fi
            fi
          fi
          # Skip all other non-conventional commits (likely internal/dev changes)
        fi
      fi
    fi
  done < <(git log --oneline --no-merges "$COMMIT_RANGE")

  # Build changelog sections
  CHANGELOG_SECTIONS=""

  if [ -n "$ADDED" ]; then
    CHANGELOG_SECTIONS="### Added\n$ADDED\n"
  fi

  if [ -n "$CHANGED" ]; then
    if [ -n "$CHANGELOG_SECTIONS" ]; then
      CHANGELOG_SECTIONS="$CHANGELOG_SECTIONS\n### Changed\n$CHANGED\n"
    else
      CHANGELOG_SECTIONS="### Changed\n$CHANGED\n"
    fi
  fi

  if [ -n "$DEPRECATED" ]; then
    if [ -n "$CHANGELOG_SECTIONS" ]; then
      CHANGELOG_SECTIONS="$CHANGELOG_SECTIONS\n### Deprecated\n$DEPRECATED\n"
    else
      CHANGELOG_SECTIONS="### Deprecated\n$DEPRECATED\n"
    fi
  fi

  if [ -n "$REMOVED" ]; then
    if [ -n "$CHANGELOG_SECTIONS" ]; then
      CHANGELOG_SECTIONS="$CHANGELOG_SECTIONS\n### Removed\n$REMOVED\n"
    else
      CHANGELOG_SECTIONS="### Removed\n$REMOVED\n"
    fi
  fi

  if [ -n "$FIXED" ]; then
    if [ -n "$CHANGELOG_SECTIONS" ]; then
      CHANGELOG_SECTIONS="$CHANGELOG_SECTIONS\n### Fixed\n$FIXED\n"
    else
      CHANGELOG_SECTIONS="### Fixed\n$FIXED\n"
    fi
  fi

  if [ -n "$SECURITY" ]; then
    if [ -n "$CHANGELOG_SECTIONS" ]; then
      CHANGELOG_SECTIONS="$CHANGELOG_SECTIONS\n### Security\n$SECURITY\n"
    else
      CHANGELOG_SECTIONS="### Security\n$SECURITY\n"
    fi
  fi

  echo -e "$CHANGELOG_SECTIONS"
}

# Function to generate changelog for all versions
_generate_all_versions() {
  cd "$PROJECT_ROOT"

  acore_log_info "Generating changelog for all historical versions..."

  # Get all tags sorted by version
  mapfile -t ALL_TAGS < <(git tag --sort=version:refname)

  if [ ${#ALL_TAGS[@]} -eq 0 ]; then
    acore_log_warning "No version tags found in repository."
    return 1
  fi

  acore_log_info "Found ${#ALL_TAGS[@]} version tags: ${ALL_TAGS[*]}"

  # Start with the changelog header
  cat > "$MAIN_CHANGELOG" << EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

EOF

  # Generate changelog for each version (newest first)
  for ((i = ${#ALL_TAGS[@]} - 1; i >= 0; i--)); do
    current_tag="${ALL_TAGS[$i]}"
    previous_tag=""

    if [ $i -gt 0 ]; then
      previous_tag="${ALL_TAGS[$((i - 1))]}"
    fi

    acore_log_info "Processing version $current_tag..."

    # Get the tag date
    tag_date=$(git log -1 --format=%ai "$current_tag" | cut -d' ' -f1)

    # Generate changelog content for this version
    if [ -n "$previous_tag" ]; then
      changelog_content=$(_generate_from_commits "$previous_tag" "$current_tag")
    else
      # First version - get all commits up to this tag
      changelog_content=$(_generate_from_commits "" "$current_tag")
    fi

    # Clean version number (remove 'v' prefix if present)
    clean_version="${current_tag#v}"

    # Add to main changelog
    echo "## [$clean_version] - $tag_date" >> "$MAIN_CHANGELOG"
    echo "" >> "$MAIN_CHANGELOG"

    if [ -n "$changelog_content" ]; then
      echo -e "$changelog_content" >> "$MAIN_CHANGELOG"
    else
      echo "### Changed" >> "$MAIN_CHANGELOG"
      echo "- Various behind-the-scenes improvements and optimizations for a better experience" >> "$MAIN_CHANGELOG"
    fi

    echo "" >> "$MAIN_CHANGELOG"
  done

  acore_log_success "Generated complete changelog for all ${#ALL_TAGS[@]} versions"
}

# Function to add or update footer with version links
_update_footer() {
  local version="$1"

  # Get the repo URL from git remote
  local repo_url
  repo_url=$(git remote get-url origin 2> /dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//' || echo "https://github.com/USER/REPO")

  # Check if footer already exists
  if grep -q "\[unreleased\]:" "$MAIN_CHANGELOG"; then
    # Footer exists, update version links
    # Update the unreleased link
    sed -i "s|\[unreleased\]:.*|[unreleased]: $repo_url/compare/v$version...HEAD|g" "$MAIN_CHANGELOG"

    # Add new version link if not already present
    if ! grep -q "\[$version\]:" "$MAIN_CHANGELOG"; then
      # Find the unreleased line and add version link after it
      awk -v repo_url="$repo_url" -v version="$version" '
                /\[unreleased\]:/ {
                    print
                    print "[$version]: $repo_url/releases/tag/v$version"
                }
                { print }
            ' "$MAIN_CHANGELOG" >> "$MAIN_CHANGELOG.tmp"
      mv "$MAIN_CHANGELOG.tmp" "$MAIN_CHANGELOG"
    fi
  else
    # No footer, add it
    cat >> "$MAIN_CHANGELOG" << EOF

[unreleased]: $repo_url/compare/v$version...HEAD
[$version]: $repo_url/releases/tag/v$version
EOF
  fi
}

# Function to create or update main CHANGELOG.md
_update_main_changelog() {
  local version="$1"
  local changelog_content="$2"
  local date
  date=$(date +%Y-%m-%d)

  local new_entry="## [$version] - $date\n\n$changelog_content"

  if [ ! -f "$MAIN_CHANGELOG" ]; then
    # Create new CHANGELOG.md
    acore_log_info "Creating fresh CHANGELOG.md file"
    cat > "$MAIN_CHANGELOG" << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

EOF
    # Add the new entry after creating the fresh file
    echo -e "$new_entry" >> "$MAIN_CHANGELOG"
  else
    # Update existing CHANGELOG.md
    # Insert new entry after "## [Unreleased]" line
    if grep -q "## \[Unreleased\]" "$MAIN_CHANGELOG"; then
      # Create temporary file with new entry
      awk -v new_entry="$new_entry" '
                /^## \[Unreleased\]/ {
                    print $0
                    print ""
                    printf "%s", new_entry
                    print ""
                    next
                }
                { print }
            ' "$MAIN_CHANGELOG" > "$MAIN_CHANGELOG.tmp"
      mv "$MAIN_CHANGELOG.tmp" "$MAIN_CHANGELOG"
    else
      # If no Unreleased section, add after the header
      awk -v new_entry="$new_entry" '
                NR <= 5 && /^# Changelog/ {
                    # Print header lines until we find the main header
                    while ((getline line) > 0 && line !~ /^## /) {
                        print line
                    }
                    print ""
                    print "## [Unreleased]"
                    print ""
                    print new_entry
                    print ""
                    if (line ~ /^## /) print line  # Print the line we read ahead
                    next
                }
                { print }
            ' "$MAIN_CHANGELOG" > "$MAIN_CHANGELOG.tmp"
      mv "$MAIN_CHANGELOG.tmp" "$MAIN_CHANGELOG"
    fi
  fi

  # Update footer with version links
  _update_footer "$version"
}

# Function to extract changelog content from CHANGELOG.md for a specific version
_extract_from_main() {
  local version="$1"

  if [ ! -f "$MAIN_CHANGELOG" ]; then
    acore_log_error "CHANGELOG.md not found"
    return 1
  fi

  # Extract content between version section and next version section
  local content
  content=$(awk "
        /^## \[$version\]/ { found=1; next }
        found && /^## \[/ { found=0 }
        found && /^###/ { print }
        found && /^- / { print }
    " "$MAIN_CHANGELOG")

  if [ -n "$content" ]; then
    echo -e "$content"
  else
    acore_log_warning "No content found for version $version in CHANGELOG.md"
    return 1
  fi
}

# Public function: Generate changelog - the main entry point
acore_changelog_generate() {
  local version="$1"
  local text="$2"
  local auto_accept="$3"
  local all_versions="$4"

  # Export variables for use in the script
  export VERSION_CODE="${version:-$CURRENT_VERSION}"
  export CHANGELOG_TEXT="$text"
  export AUTO_ACCEPT="${auto_accept:-false}"
  export ALL_VERSIONS="${all_versions:-false}"

  # Execute the changelog generation logic
  if [ "$ALL_VERSIONS" = true ]; then
    acore_log_info "Generating changelog for all historical versions..."
    if [ "$AUTO_ACCEPT" = false ]; then
      acore_log_warning "This will completely regenerate CHANGELOG.md with all historical versions."
      read -r -p "Do you want to continue? (y/N): " confirm
      if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        acore_log_error "Operation cancelled."
        return 1
      fi
    fi
    _generate_all_versions
    acore_log_success "Complete changelog generated successfully!"
    acore_log_info "Main changelog: $MAIN_CHANGELOG"
  else
    acore_log_info "Generating changelog for version $VERSION_CODE..."
    if [ -z "$CHANGELOG_TEXT" ]; then
      CHANGELOG_CONTENT=$(_generate_from_commits)
      if [ -z "$CHANGELOG_CONTENT" ]; then
        acore_log_warning "No user-facing changes found since last version."
        CHANGELOG_CONTENT="### Changed\n- Internal improvements and maintenance"
      fi
      acore_log_header "Generated Changelog"
      echo -e "$CHANGELOG_CONTENT"
      if [ "$AUTO_ACCEPT" != true ]; then
        read -r -p "Use this generated changelog? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
          acore_log_error "Operation cancelled."
          return 1
        fi
      fi
    else
      # Manual changelog
      CAPITALIZED_ITEMS=$(echo -e "$CHANGELOG_TEXT" | sed 's/^• /- /g' | while IFS= read -r line; do
        if [[ "$line" =~ ^-\ (.+)$ ]]; then
          content="${BASH_REMATCH[1]}"
          echo "- $(_capitalize_first_letter "$content")"
        elif [ -n "$line" ]; then
          echo "- $(_capitalize_first_letter "$line")"
        fi
      done)
      CHANGELOG_CONTENT="### Changed\n$CAPITALIZED_ITEMS"
    fi
    _update_main_changelog "$CURRENT_VERSION" "$CHANGELOG_CONTENT"
    acore_log_success "Updated $MAIN_CHANGELOG"
  fi

  acore_log_success "Changelog processing complete!"
}

# Private function: Get version from version identifier
_get_version_from_identifier() {
  local version_identifier="$1"

  cd "$PROJECT_ROOT"

  # If the identifier matches a git tag directly, return it
  if git rev-parse "$version_identifier" > /dev/null 2>&1; then
    echo "${version_identifier#v}"
    return 0
  fi

  # Search through git tags for matching version
  for tag in $(git tag --sort=-version:refname); do
    local clean_tag="${tag#v}"
    if [ "$clean_tag" = "$version_identifier" ]; then
      echo "$clean_tag"
      return 0
    fi
  done

  acore_log_error "Unknown version: $version_identifier"
  return 1
}

# Execute public function when script is called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Call the public function with parsed arguments
  acore_changelog_generate "$VERSION_CODE" "$CHANGELOG_TEXT" "$AUTO_ACCEPT" "$ALL_VERSIONS"
fi
