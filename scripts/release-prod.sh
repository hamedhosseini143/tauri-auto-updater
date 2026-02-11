#!/bin/bash

# ==============================================================================
# Tauri Auto-Updater Production Release Script
# ==============================================================================
# این اسکریپت برای ساخت و انتشار نسخه production استفاده می‌شود
# استفاده: ./scripts/release-prod.sh
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
print_header "بررسی پیش‌نیازها"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
print_error "jq نصب نیست"
print_info "لطفاً با دستور زیر نصب کنید: brew install jq"
exit 1
fi
print_success "jq نصب شده است"

# Check if git is installed
if ! command -v git &> /dev/null; then
print_error "git نصب نیست"
exit 1
fi
print_success "git نصب شده است"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
print_error "این دایرکتوری یک git repository نیست"
exit 1
fi
print_success "در git repository هستیم"

# Check if tauri config exists
if [ ! -f "$TAURI_CONFIG_PATH" ]; then
print_error "فایل $TAURI_CONFIG_PATH پیدا نشد"
exit 1
fi
print_success "فایل Tauri config پیدا شد"
}

# ==============================================================================
# Git Checks
# ==============================================================================

check_git_status() {
print_header "بررسی وضعیت Git"

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$MAIN_BRANCH" ]; then
print_error "شما روی branch '$CURRENT_BRANCH' هستید"
print_info "لطفاً به branch '$MAIN_BRANCH' بروید: git checkout $MAIN_BRANCH"
exit 1
fi
print_success "روی branch '$MAIN_BRANCH' هستید"

# Check if working directory is clean
if ! git diff-index --quiet HEAD --; then
print_error "Working directory clean نیست"
print_info "لطفاً تغییرات را commit یا stash کنید"
git status --short
exit 1
fi
print_success "Working directory clean است"
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
  print_error "نوع increment نامعتبر است: $increment_type"
  exit 1
  ;;
  esac

  echo "${major}.${minor}.${patch}"
  }

  select_increment_type() {
  print_header "انتخاب نوع Version Increment"

  echo -e "${BLUE}نوع تغییرات این release را انتخاب کنید:${NC}"
  echo ""
  echo "1) Patch (x.x.1) - رفع باگ‌ها و تغییرات جزئی"
  echo "2) Minor (x.1.0) - ویژگی‌های جدید (backward compatible)"
  echo "3) Major (1.0.0) - تغییرات بزرگ (breaking changes)"
  echo ""

  while true; do
  read -p "انتخاب شما [1-3]: " choice
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
  print_error "انتخاب نامعتبر. لطفاً 1، 2 یا 3 را وارد کنید"
  ;;
  esac
  done
  }

  update_tauri_config() {
  local new_version=$1

  print_info "در حال آپدیت $TAURI_CONFIG_PATH ..."

  # Create a temporary file
  local temp_file=$(mktemp)

  # Update version in config file
  jq --arg version "$new_version" '.version = $version' "$TAURI_CONFIG_PATH"> "$temp_file"

  # Replace original file
  mv "$temp_file" "$TAURI_CONFIG_PATH"

  print_success "Version در $TAURI_CONFIG_PATH به $new_version آپدیت شد"
  }

  # ==============================================================================
  # Confirmation
  # ==============================================================================

  confirm_release() {
  local old_version=$1
  local new_version=$2
  local increment_type=$3

  print_header "تأیید Production Release"

  echo -e "${YELLOW}⚠️ شما در حال ساخت یک PRODUCTION RELEASE هستید!${NC}"
  echo ""
  echo -e "${BLUE}اطلاعات Release:${NC}"
  echo " • Branch: $MAIN_BRANCH"
  echo " • نسخه فعلی: $old_version"
  echo " • نسخه جدید: v$new_version"
  echo " • نوع: $increment_type"
  echo " • Tag: v$new_version"
  echo ""
  echo -e "${YELLOW}این عملیات:${NC}"
  echo " 1. Version در $TAURI_CONFIG_PATH را به $new_version تغییر می‌دهد"
  echo " 2. تغییرات را commit می‌کند"
  echo " 3. Tag v$new_version را ایجاد می‌کند"
  echo " 4. تغییرات و tag را به GitHub push می‌کند"
  echo " 5. GitHub Actions workflow را trigger می‌کند"
  echo ""

  read -p "آیا مطمئن هستید که می‌خواهید ادامه دهید؟ (yes/no): " confirm

  if [ "$confirm" != "yes" ]; then
  print_warning "عملیات توسط کاربر لغو شد"
  exit 0
  fi
  }

  # ==============================================================================
  # Git Operations
  # ==============================================================================

  pull_latest_changes() {
  print_header "دریافت آخرین تغییرات"

  print_info "در حال pull کردن از $MAIN_BRANCH ..."
  if git pull origin "$MAIN_BRANCH"; then
  print_success "آخرین تغییرات دریافت شد"
  else
  print_error "خطا در دریافت تغییرات"
  exit 1
  fi
  }

  commit_and_push_changes() {
  local new_version=$1

  print_header "Commit و Push تغییرات"

  # Add changed files
  git add "$TAURI_CONFIG_PATH"

  # Commit
  print_info "در حال commit کردن تغییرات ..."
  git commit -m "chore: bump version to $new_version"

  # Push
  print_info "در حال push کردن به $MAIN_BRANCH ..."
  git push origin "$MAIN_BRANCH"

  print_success "تغییرات commit و push شدند"
  }

  create_and_push_tag() {
  local new_version=$1
  local tag_name="v$new_version"

  print_header "ساخت و Push کردن Tag"

  # Create tag
  print_info "در حال ساخت tag $tag_name ..."
  git tag -a "$tag_name" -m "Release $tag_name"

  # Push tag
  print_info "در حال push کردن tag به GitHub ..."
  git push origin "$tag_name"

  print_success "Tag $tag_name ساخته و push شد"
  }

  # ==============================================================================
  # Main Script
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
  print_info "نسخه فعلی در config: $CURRENT_VERSION"

  # Step 5: Get latest tag
  LATEST_TAG=$(get_latest_tag)
  print_info "آخرین tag production: $LATEST_TAG"

  # Step 6: Select increment type
  INCREMENT_TYPE=$(select_increment_type)

  # Step 7: Calculate new version
  NEW_VERSION=$(increment_version "$LATEST_TAG" "$INCREMENT_TYPE")
  print_success "نسخه جدید محاسبه شد: v$NEW_VERSION"

  # Step 8: Confirm release
  confirm_release "$LATEST_TAG" "$NEW_VERSION" "$INCREMENT_TYPE"

  # Step 9: Update tauri config
  update_tauri_config "$NEW_VERSION"

  # Step 10: Commit and push changes
  commit_and_push_changes "$NEW_VERSION"

  # Step 11: Create and push tag
  create_and_push_tag "$NEW_VERSION"

  # Success message
  print_header "✅ Release موفقیت‌آمیز بود!"

  echo ""
  echo -e "${GREEN}🎉 نسخه v$NEW_VERSION با موفقیت release شد!${NC}"
  echo ""
  echo -e "${BLUE}مراحل بعدی:${NC}"
  echo " 1. GitHub Actions workflow به طور خودکار شروع خواهد شد"
  echo " 2. برنامه برای تمام پلتفرم‌ها build خواهد شد"
  echo " 3. Release در GitHub ایجاد خواهد شد (به صورت draft)"
  echo " 4. به این آدرس بروید تا release را publish کنید:"
  echo -e " ${BLUE}https://github.com/hamedhosseini143/tauri-auto-updater/releases${NC}"
  echo ""
  print_info "منتظر بمانید تا GitHub Actions workflow تمام شود (~5-10 دقیقه)"
  echo ""
  }

  # Run main function
  main