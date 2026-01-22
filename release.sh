#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() { echo -e "${GREEN}➜${NC} $1"; }
print_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

# Check if version argument is provided
if [ $# -eq 0 ]; then
    print_error "Usage: ./release.sh <version>"
    echo "Example: ./release.sh 1.0.1"
    exit 1
fi

VERSION=$1
FULL_VERSION="v${VERSION}"

# Validate version format (e.g., 1.0.0)
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_error "Invalid version format. Use semantic versioning (e.g., 1.0.1)"
    exit 1
fi

# Extract major version (e.g., 1 from 1.0.1)
MAJOR_VERSION="v$(echo $VERSION | cut -d. -f1)"

print_info "Preparing release ${FULL_VERSION}..."

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    print_error "You have uncommitted changes. Commit or stash them first."
    exit 1
fi

# Check if we're on main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    print_warn "You're on branch '${CURRENT_BRANCH}', not 'main'. Continue anyway? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_error "Release cancelled."
        exit 1
    fi
fi

# Check if tag already exists
if git rev-parse "$FULL_VERSION" >/dev/null 2>&1; then
    print_error "Tag ${FULL_VERSION} already exists!"
    exit 1
fi

# Remind to update CHANGELOG
print_warn "Have you updated CHANGELOG.md for version ${VERSION}? (y/n)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    print_error "Please update CHANGELOG.md first, then run this script again."
    exit 1
fi

# Confirm release
echo ""
print_info "Ready to release:"
echo "  Version: ${FULL_VERSION}"
echo "  Major tag: ${MAJOR_VERSION}"
echo ""
print_warn "Continue with release? (y/n)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    print_error "Release cancelled."
    exit 1
fi

# Create version tag
print_info "Creating tag ${FULL_VERSION}..."
git tag -a "$FULL_VERSION" -m "$FULL_VERSION"

# Create/update major version tag
print_info "Creating/updating major version tag ${MAJOR_VERSION}..."
git tag -f "$MAJOR_VERSION" -m "$MAJOR_VERSION"

# Push version tag
print_info "Pushing tag ${FULL_VERSION}..."
git push origin "$FULL_VERSION"

# Push major version tag (with force)
print_info "Pushing major version tag ${MAJOR_VERSION}..."
git push origin "$MAJOR_VERSION" --force

echo ""
print_info "✓ Release ${FULL_VERSION} completed successfully!"
echo ""
echo "Next steps:"
echo "  • Verify tags at: https://github.com/invertase/invertase-project-board/tags"
echo "  • Test in a repo using: invertase/invertase-project-board@${MAJOR_VERSION}"
echo ""
