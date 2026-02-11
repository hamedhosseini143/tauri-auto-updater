#!/bin/bash

# ==============================================================================
# Tauri Auto-Updater Production Release Script
# ==============================================================================
# This script is used to build and publish production releases
# Usage: ./scripts/release-prod.sh
# ==============================================================================

set -e # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Config
TAURI_CONFIG_PATH="src-tauri/tauri.conf.json"
MAIN_BRANCH="main"

# ==============================================================================
# Helper Functions
# ==============================================================================

print_header() {
echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}$1${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
}

print_success() {
echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
echo -e "${RED}❌ $1${NC}"
}

print_info() {
echo -e "${BLUE}ℹ️ $1${NC}"
}

# ==============================================================================
# Prerequisite Checks
# ==============================================================================

check_prerequisites() {
print_header "Checking Prerequisites"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
print_error "jq is not installed"
print_info "Please install with: brew install jq"
exit 1
fi
print_success "jq is installed"

# Check if git is installed
if ! command -v git &> /dev/null; then
print_error "git is not installed"
exit 1
fi
print_success "git is installed"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
print_error "This directory is not a git repository"
exit 1
fi
print_success "In a git repository"

# Check if tauri config exists
if [ ! -f "$TAURI_CONFIG_PATH" ]; then
print_error "File $TAURI_CONFIG_PATH not found"
exit 1
fi
print_success "Tauri config file found"
}

# ==============================================================================
# Git Checks
# ==============================================================================

check_git_status() {
print_header "Checking Git Status"

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$MAIN_BRANCH" ]; then
print_error "You are on branch '$CURRENT_BRANCH'"
print_info "Please switch to branch '$MAIN_BRANCH': git checkout $MAIN_BRANCH"
exit 1
fi
print_success "On branch '$MAIN_BRANCH'"

# Check if working directory is clean
if ! git diff-index --quiet HEAD --; then
print_error "Working directory is not clean"
print_info "Please commit or stash your changes"
git status --short
exit 1
fi
print_success "Working directory is clean"
}

# ==============================================================================
# Version Management
# ==============================================================================

get_current_version() {
jq -r '.version' "$TAURI_CONFIG_PATH"
}

get_latest_tag() {
# Get the latest tag that matches v*.*.* pattern
LATEST_TAG=$(git tag -l "v*.*.*" --sort=-v:refname | head -n 1)

if [ -z "$LATEST_TAG" ]; then
echo "v0.0.0"
else
echo "$LATEST_TAG"
fi
}

increment_version() {
local version=$1
local increment_type=$2

# Remove 'v' prefix if exists
version=${version#v}

# Split version into parts
IFS='.' read -r -a parts <<< "$version"
  major="${parts[0]}"
  minor="${parts[1]}"
  patch="${parts[2]}"

  case $increment_type in
  patch)
  patch=$((patch + 1))
  ;;
  minor)
  minor=$((minor + 1))
  patch=0
  ;;
  major)
  major=$((major + 1))
  minor=0
  patch=0
  ;;
  *)
  print_error "Invalid increment type: $increment_type"
  exit 1
  ;;
  esac

  echo "${major}.${minor}.${patch}"
  }

  select_increment_type() {
  print_header "Select Version Increment Type"

  echo -e "${BLUE}Select the type of changes in this release:${NC}"
  echo ""
  echo "1) Patch (x.x.1) - Bug fixes and minor changes"
  echo "2) Minor (x.1.0) - New features (backward compatible)"
  echo "3) Major (1.0.0) - Major changes (breaking changes)"
  echo ""

  while true; do
  read -p "Your choice [1-3]: " choice
  case $choice in
  1)
  echo "patch"
  return
  ;;
  2)
  echo "minor"
  return
  ;;
  3)
  echo "major"
  return
  ;;
  *)
  print_error "Invalid choice. Please enter 1, 2, or 3"
  esac
  done
  }

  update_tauri_config() {
  local new_version=$1

  print_info "Updating $TAURI_CONFIG_PATH ..."

  # Create a temporary file
  local temp_file=$(mktemp)

  # Update version in config file
  jq --arg version "$new_version" '.version = $version' "$TAURI_CONFIG_PATH"> "$temp_file"

  # Replace original file
  mv "$temp_file" "$TAURI_CONFIG_PATH"

  print_success "Version in $TAURI_CONFIG_PATH updated to $new_version"
  }

  # ==============================================================================
  # Confirmation
  # ==============================================================================

  confirm_release() {
  local old_version=$1
  local new_version=$2
  local increment_type=$3

  print_header "Confirm Production Release"

  echo -e "${YELLOW}⚠️ You are about to create a PRODUCTION RELEASE!${NC}"
  echo ""
  echo -e "${BLUE}Release Information:${NC}"
  echo " • Branch: $MAIN_BRANCH"
  echo " • Current Version: $old_version"
  echo " • New Version: v$new_version"
  echo " • Type: $increment_type"
  echo " • Tag: v$new_version"
  echo ""
  echo -e "${YELLOW}This operation will:${NC}"
  echo " 1. Update version in $TAURI_CONFIG_PATH to $new_version"
  echo " 2. Commit the changes"
  echo " 3. Create tag v$new_version"
  echo " 4. Push changes and tag to GitHub"
  echo " 5. Trigger GitHub Actions workflow"
  echo ""

  read -p "Are you sure you want to continue? (yes/no): " confirm

  if [ "$confirm" != "yes" ]; then
  print_warning "Operation cancelled by user"
  exit 0
  fi
  }

  # ==============================================================================
  # Git Operations
  # ==============================================================================

  pull_latest_changes() {
  print_header "Pulling Latest Changes"

  print_info "Pulling from $MAIN_BRANCH ..."
  if git pull origin "$MAIN_BRANCH"; then
  print_success "Latest changes pulled successfully"
  else
  print_error "Error pulling changes"
  fi
  }

  commit_and_push_changes() {
  local new_version=$1

  print_header "Commit and Push Changes"

  # Add changed files
  git add "$TAURI_CONFIG_PATH"

  # Commit
  print_info "Committing changes ..."
  git commit -m "chore: bump version to $new_version"

  # Push
  print_info "Pushing to $MAIN_BRANCH ..."
  git push origin "$MAIN_BRANCH"

  print_success "Changes committed and pushed"
  }

  create_and_push_tag() {
  local new_version=$1
  local tag_name="v$new_version"

  print_header "Create and Push Tag"

  # Create tag
  print_info "Creating tag $tag_name ..."
  git tag -a "$tag_name" -m "Release $tag_name"

  # Push tag
  print_info "Pushing tag to GitHub ..."
  git push origin "$tag_name"

  print_success "Tag $tag_name created and pushed"
  }

  # ==============================================================================
  # Main
  # ==============================================================================

  main() {
  print_header "🚀 Tauri Auto-Updater Production Release"

  # Step 1: Check prerequisites
  check_prerequisites

  # Step 2: Check git status
  check_git_status

  # Step 3: Pull latest changes
  pull_latest_changes

  # Step 4: Get current version
  CURRENT_VERSION=$(get_current_version)
  print_info "Current version in config: $CURRENT_VERSION"

  # Step 5: Get latest tag
  LATEST_TAG=$(get_latest_tag)
  print_info "Latest production tag: $LATEST_TAG"

  # Step 6: Select increment type
  INCREMENT_TYPE=$(select_increment_type)

  # Step 7: Calculate new version
  NEW_VERSION=$(increment_version "$LATEST_TAG" "$INCREMENT_TYPE")
  print_success "New version calculated: v$NEW_VERSION"
  confirm_release "$LATEST_TAG" "$NEW_VERSION" "$INCREMENT_TYPE"

  # Step 9: Update tauri config
  update_tauri_config "$NEW_VERSION"

  # Step 10: Commit and push changes
  commit_and_push_changes "$NEW_VERSION"

  # Step 11: Create and push tag
  create_and_push_tag "$NEW_VERSION"

  # Success message
  print_header "✅ Release Successful!"

  echo ""
  echo -e "${GREEN}🎉 Version v$NEW_VERSION released successfully!${NC}"
  echo ""
  echo -e "${BLUE}Next Steps:${NC}"
  echo " 1. GitHub Actions workflow will start automatically"
  echo " 2. Application will be built for all platforms"
  echo " 3. Release will be created in GitHub (as draft)"
  echo " 4. Go to this URL to publish the release:"
  echo -e " ${BLUE}https://github.com/hamedhosseini143/tauri-auto-updater/releases${NC}"
  echo ""
  print_info "Wait for GitHub Actions workflow to complete (~5-10 minutes)"
  echo ""
  }

  # Run main function
  main