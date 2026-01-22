# Release Process

This document outlines how to release new versions of the Invertase Project Manager action.

## Automated Release (Recommended)

Use the provided release script:

```bash
# 1. Update CHANGELOG.md with your changes

# 2. Commit and push changes
git add .
git commit -m "chore: prepare release v1.x.x"
git push

# 3. Run the release script
./release.sh 1.x.x
```

The script will:
- ✓ Validate version format
- ✓ Check for uncommitted changes
- ✓ Create both version tags (`v1.x.x` and `v1`)
- ✓ Push both tags to GitHub
- ✓ Provide verification links

## Manual Release Steps

If you prefer to release manually:

```bash
# 1. Update CHANGELOG.md with changes

# 2. Commit changes
git add .
git commit -m "chore: prepare release v1.x.x"
git push

# 3. Create tags (both specific and major version)
git tag -a v1.x.x -m "v1.x.x"
git tag -f v1 -m "v1"

# 4. Push tags (both to GitHub)
git push origin v1.x.x
git push origin v1 --force
```

## Why Two Tags?

We maintain two types of tags:

### Specific Version Tag (`v1.0.0`, `v1.0.1`, etc.)
- **Purpose**: Permanent reference to exact release
- **Never moves**: Always points to the same commit
- **Use case**: When someone needs to pin to a specific version

### Major Version Tag (`v1`, `v2`, etc.)
- **Purpose**: "Always latest" pointer for that major version
- **Moves with updates**: Gets force-updated with each new release
- **Use case**: What users should reference in workflows (`@v1`)

**Benefit**: Repos using `@v1` automatically get bug fixes and new features without updating their workflow files.

## Why Force Push?

The `--force` flag on the major version tag push is required because:
- The `v1` tag already exists from a previous release
- We're moving it to point to the new release
- Git won't let you move a tag without forcing it

## Version Numbering

Follow semantic versioning:

- **Patch** (v1.0.1): Bug fixes, no breaking changes
- **Minor** (v1.1.0): New features, no breaking changes  
- **Major** (v2.0.0): Breaking changes (create new `v2` tag)

## Example: Releasing v1.0.1

```bash
# Make your bug fix changes
git add .
git commit -m "fix: resolve issue with payload formatting"
git push

# Update CHANGELOG.md
# ... add entry for v1.0.1 ...
git add CHANGELOG.md
git commit -m "chore: update changelog for v1.0.1"
git push

# Tag the release
git tag -a v1.0.1 -m "v1.0.1"
git tag -f v1 -m "v1"

# Push both tags
git push origin v1.0.1
git push origin v1 --force
```

All repos using `invertase/invertase-project-board@v1` now automatically use v1.0.1!

## Optional: GitHub Release

For documentation purposes, you can create a GitHub release:

```bash
gh release create v1.x.x \
  --title "v1.x.x" \
  --notes-file <(sed -n '/## \[1\.x\.x\]/,/## \[/p' CHANGELOG.md | head -n -1)
```

**Important**: Do NOT check "Publish this Action to the GitHub Marketplace" - this is an internal-only action.
