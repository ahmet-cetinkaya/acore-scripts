#!/usr/bin/env bash

# Script to safely manage git tags with interactive confirmations
# Usage: ./release-git-tag-manage.sh --help

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel)"

# Source logger utilities
# shellcheck source=/dev/null
source "$SCRIPT_DIR/logger.sh"

# Default configuration
DEFAULT_PUSH=true

# Function to show help
_show_help() {
	cat <<'EOF'
acore-release-tag - Safe git tag management

USAGE:
    manage-git-release-tag.sh [OPTIONS] <TAG_NAME>

OPTIONS:
    -d, --delete      Delete existing tag
    -f, --force       Force tag creation/recreation
    --no-push         Don't push to remote
    -h, --help        Show this help

EXAMPLES:
    manage-git-release-tag.sh v1.0.0
    manage-git-release-tag.sh v1.2.3 --force
    manage-git-release-tag.sh v2.0.0 --delete
    manage-git-release-tag.sh v1.1.0 --no-push
EOF
}

# Function to validate tag format
_validate_tag_format() {
	local tag="$1"

	# Check if tag follows semantic versioning pattern (v1.2.3, etc.)
	if [[ ! "$tag" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9-]+)?$ ]]; then
		acore_log_error "Invalid tag format: '$tag'"
		acore_log_error "Expected format: v1.2.3, 1.2.3, v1.2.3-alpha, etc."
		return 1
	fi
}

# Function to get repository URL
_get_repo_url() {
	local repo_url
	repo_url=$(git remote get-url origin 2>/dev/null || echo "")

	if [ -z "$repo_url" ]; then
		acore_log_warning "No remote 'origin' found"
		return 1
	fi

	# Convert SSH URL to HTTPS for display
	echo "$repo_url" | sed 's|git@github.com:|https://github.com/|' | sed 's|\.git$||'
}

# Function to check if tag exists locally
_tag_exists_local() {
	local tag="$1"
	git rev-parse "$tag" >/dev/null 2>&1
}

# Function to check if tag exists remotely
_tag_exists_remote() {
	local tag="$1"
	local repo_url="$2"

	if [ -z "$repo_url" ]; then
		return 1
	fi

	# Try to check if tag exists on remote
	git ls-remote --tags origin 2>/dev/null | grep -q "refs/tags/$tag$"
}

# Function to get commit hash for a tag
_get_tag_commit() {
	local tag="$1"
	git rev-list -n 1 "$tag" 2>/dev/null
}

# Function to get current HEAD commit
_get_head_commit() {
	git rev-parse HEAD
}

# Function to create tag
_create_tag() {
	local tag="$1"
	local force="$2"
	local push="$3"
	local repo_url

	# Check if tag already exists locally
	if _tag_exists_local "$tag"; then
		if [ "$force" = true ]; then
			acore_log_warning "Tag '$tag' already exists locally. Recreating with --force."
			git tag -d "$tag"
		else
			acore_log_error "Tag '$tag' already exists locally. Use --force to recreate."
			return 1
		fi
	fi

	# Check if tag exists remotely
	repo_url=$(_get_repo_url)
	if _tag_exists_remote "$tag" "$repo_url"; then
		if [ "$force" = true ]; then
			acore_log_warning "Tag '$tag' exists on remote. Deleting with --force."
			git push origin ":refs/tags/$tag"
		else
			acore_log_error "Tag '$tag' already exists on remote repository."
			acore_log_error "Remote URL: $repo_url"
			acore_log_error "Use --force to replace, or --delete to remove first."
			return 1
		fi
	fi

	# Get current commit for tag message
	local current_commit
	current_commit=$(_get_head_commit)
	local commit_message
	commit_message=$(git log -1 --format=%s "$current_commit")

	acore_log_info "Creating tag '$tag' at commit $current_commit"
	acore_log_info "Tag message: $commit_message"

	# Create the tag
	if git tag -a "$tag" -m "Release $tag

$commit_message

Commit: $current_commit"; then
		acore_log_success "Tag '$tag' created successfully locally"
	else
		acore_log_error "Failed to create tag '$tag'"
		return 1
	fi

	# Push to remote if requested
	if [ "$push" = true ]; then
		if [ -n "$repo_url" ]; then
			acore_log_info "Pushing tag to remote: $repo_url"

			if [ "$force" = true ]; then
				git push origin "$tag" --force
			else
				git push origin "$tag"
			fi

			acore_log_success "Tag '$tag' pushed to remote repository"
		else
			acore_log_warning "No remote repository configured. Skipping push."
		fi
	else
		acore_log_info "Skipping remote push (--no-push specified)"
	fi
}

# Function to delete tag
_delete_tag() {
	local tag="$1"
	local repo_url

	# Check if tag exists locally
	if _tag_exists_local "$tag"; then
		acore_log_info "Deleting local tag '$tag'"
		git tag -d "$tag"
		acore_log_success "Local tag '$tag' deleted"
	else
		acore_log_warning "Local tag '$tag' does not exist"
	fi

	# Check and delete from remote
	repo_url=$(_get_repo_url)
	if _tag_exists_remote "$tag" "$repo_url"; then
		acore_log_info "Deleting remote tag '$tag' from: $repo_url"
		git push origin ":refs/tags/$tag"
		acore_log_success "Remote tag '$tag' deleted"
	else
		if [ -n "$repo_url" ]; then
			acore_log_warning "Remote tag '$tag' does not exist"
		else
			acore_log_warning "No remote repository configured"
		fi
	fi
}

# Function to show tag information
_show_tag_info() {
	local tag="$1"
	local repo_url

	acore_log_header "Tag Information: $tag"

	# Local tag info
	if _tag_exists_local "$tag"; then
		local commit
		commit=$(_get_tag_commit "$tag")
		local commit_date
		commit_date=$(git log -1 --format=%ai "$commit" | cut -d' ' -f1)
		local commit_message
		commit_message=$(git log -1 --format=%s "$commit")

		echo "Local Tag: ✅ Exists"
		echo "Commit: $commit"
		echo "Date: $commit_date"
		echo "Message: $commit_message"
	else
		echo "Local Tag: ❌ Does not exist"
	fi

	# Remote tag info
	repo_url=$(_get_repo_url)
	if [ -n "$repo_url" ]; then
		if _tag_exists_remote "$tag" "$repo_url"; then
			echo "Remote Tag: ✅ Exists"
			echo "Remote URL: $repo_url"
		else
			echo "Remote Tag: ❌ Does not exist"
		fi
	else
		echo "Remote Tag: ⚠️  No remote repository"
	fi
}

# Function to confirm action
_confirm_action() {
	local action="$1"
	local tag="$2"
	local response

	echo
	read -r -p "Are you sure you want to $action tag '$tag'? (y/N): " response

	case "$response" in
	[yY] | [yY][eE][sS])
		return 0
		;;
	*)
		acore_log_error "Operation cancelled by user"
		return 1
		;;
	esac
}

# Public function: Main tag management entry point
acore_release_tag_manage() {
	local tag_name=""
	local delete_tag=false
	local force_tag=false
	local push_tag="$DEFAULT_PUSH"

	# Parse arguments
	while [[ $# -gt 0 ]]; do
		case $1 in
		-h | --help)
			_show_help
			exit 0
			;;
		-d | --delete)
			delete_tag=true
			shift
			;;
		-f | --force)
			force_tag=true
			shift
			;;
		--no-push)
			push_tag=false
			shift
			;;
		-*)
			acore_log_error "Unknown option: $1"
			_show_help
			exit 1
			;;
		*)
			if [ -z "$tag_name" ]; then
				tag_name="$1"
			else
				acore_log_error "Multiple tag names provided: '$tag_name' and '$1'"
				exit 1
			fi
			shift
			;;
		esac
	done

	# Validate tag name
	if [ -z "$tag_name" ]; then
		acore_log_error "No tag name provided"
		_show_help
		exit 1
	fi

	# Validate tag format
	_validate_tag_format "$tag_name"

	# Change to project root directory
	cd "$PROJECT_ROOT"

	# Check if we're in a git repository
	if ! git rev-parse --git-dir >/dev/null 2>&1; then
		acore_log_error "Not in a git repository"
		exit 1
	fi

	# Check working directory is clean (unless deleting)
	if [ "$delete_tag" = false ]; then
		if [ -n "$(git status --porcelain)" ]; then
			acore_log_warning "Working directory is not clean:"
			git status --short
			acore_log_warning "It's recommended to commit changes before creating a release tag"

			read -r -p "Continue anyway? (y/N): " response
			case "$response" in
			[yY] | [yY][eE][sS])
				acore_log_info "Proceeding despite unclean working directory"
				;;
			*)
				acore_log_error "Operation cancelled by user"
				exit 1
				;;
			esac
		fi
	fi

	# Show current tag information
	_show_tag_info "$tag_name"

	# Perform requested action
	if [ "$delete_tag" = true ]; then
		if _confirm_action "delete" "$tag_name"; then
			_delete_tag "$tag_name"
			acore_log_success "Tag deletion completed for '$tag_name'"
		fi
	else
		if _confirm_action "create" "$tag_name"; then
			_create_tag "$tag_name" "$force_tag" "$push_tag"
			acore_log_success "Tag creation completed for '$tag_name'"
		fi
	fi
}

# Execute public function when script is called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	acore_release_tag_manage "$@"
fi
