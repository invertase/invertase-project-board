# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.1] - 2026-01-23

### Changed
- `project-boards` input is now required (previously optional with empty array default)
- Updated documentation to reflect required status of `project-boards` input

## [1.0.0] - 2026-01-22

### Added
- Initial release of Invertase Project Manager GitHub Action
- Support for issue events (opened, edited, closed, reopened, labeled, unlabeled)
- Support for pull request events (opened, edited, closed, reopened, labeled, unlabeled)
- Support for issue comment events (created, with OP filtering)
- Automatic collection of PR closing-linked issues via GraphQL
- OIDC-based authentication for secure endpoint communication
- Configurable label-based status mappings (blocked, in_progress, ready, needs_response)
- Configurable project board numbers
- Smart comment filtering (only forwards OP responses)
- Comprehensive payload structure with issue, PR, and project metadata

[Unreleased]: https://github.com/invertase/invertase-project-board/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/invertase/invertase-project-board/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/invertase/invertase-project-board/releases/tag/v1.0.0
