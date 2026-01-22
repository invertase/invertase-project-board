# Invertase Project Manager

A GitHub Action that forwards issue and pull request activity to a project board manager endpoint.

> **⚠️ Organization-Specific Action**  
> This action is designed exclusively for Invertase-maintained repositories. It will not work for your project.

## Features

- 🔄 Automatically syncs GitHub issues and PRs with internal project boards
- 🔒 Secure authentication using GitHub OIDC tokens
- 🏷️ Customizable label-based status mappings
- 💬 Smart comment filtering (only sends OP responses)
- 🔗 Automatically links PRs to closing issues

## Usage

### Basic Setup

Add this action to a workflow file (e.g., `.github/workflows/project-sync.yml`):

```yaml
name: Project Board Sync

on:
  issues:
    types: [opened, edited, closed, reopened, labeled, unlabeled]
  pull_request:
    types: [opened, edited, closed, reopened, labeled, unlabeled]
  issue_comment:
    types: [created]

permissions:
  id-token: write  # Required for OIDC token
  contents: read
  issues: read
  pull-requests: read

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: invertase/invertase-project-board@v1
```

### Advanced Configuration

Customize the action with inputs:

```yaml
- uses: invertase/invertase-project-board@v1
  with:
    endpoint_url: 'https://your-endpoint.example.com/events'
    project-boards: '[54, 34]'
    blocked: '["blocked", "on-hold"]'
    in_progress: '["in-progress", "working"]'
    ready: '["ready", "approved"]'
    needs_response: '["needs-response", "waiting-for-response"]'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `endpoint_url` | The endpoint URL to POST events to (also used as OIDC audience) | No | `https://us-central1-project-board-manager.cloudfunctions.net/ingestGithubDataEvents` |
| `project-boards` | Array of project board numbers to update (e.g., `[54, 34]`) | No | `[]` |
| `blocked` | Array of labels that indicate blocked status | No | `[]` |
| `in_progress` | Array of labels that indicate in progress status | No | `[]` |
| `ready` | Array of labels that indicate ready status | No | `[]` |
| `needs_response` | Array of labels that indicate needs response status | No | `[]` |

## Permissions Required

This action requires the following permissions:

```yaml
permissions:
  id-token: write  # Required for OIDC token generation
  contents: read
  issues: read
  pull-requests: read
```

## How It Works

1. **Event Filtering**: The action filters events to only process relevant updates
2. **OP Comment Gating**: Only comments from the original issue/PR author are forwarded
3. **PR Link Collection**: For pull requests, automatically collects linked issues
4. **Payload Building**: Constructs a comprehensive JSON payload with all relevant data
5. **OIDC Authentication**: Generates a GitHub OIDC token for secure authentication
6. **Event Forwarding**: Posts the event data to your configured endpoint

## Payload Structure

The action sends a JSON payload with the following structure:

```json
{
  "source": "github-actions",
  "event_name": "issues",
  "action": "opened",
  "repository": "owner/repo",
  "issue": {
    "number": 123,
    "html_url": "https://github.com/owner/repo/issues/123",
    "title": "Issue title",
    "author": "username",
    "state": "open",
    "labels": ["bug", "needs-triage"],
    "comments": 5,
    "created_at": "2026-01-22T12:00:00Z",
    "updated_at": "2026-01-22T14:30:00Z"
  },
  "op_response": {
    "is_op": false,
    "comment_html_url": "",
    "comment_author": "",
    "comment_created_at": ""
  },
  "pull_request": {
    "html_url": "",
    "number": 0,
    "state": ""
  },
  "linked_issue_urls": [],
  "project": {
    "boards": [54, 34],
    "blocked": ["blocked"],
    "in_progress": ["in-progress"],
    "ready": ["ready"],
    "needs_response": ["needs-response"]
  }
}
```

## Supported Events

- **Issues**: `opened`, `edited`, `closed`, `reopened`, `labeled`, `unlabeled`
- **Pull Requests**: `opened`, `edited`, `closed`, `reopened`, `labeled`, `unlabeled`
- **Issue Comments**: `created` (only OP responses are forwarded)

## Example Workflow

Here's a complete example workflow:

```yaml
name: Project Board Sync

on:
  issues:
    types: [opened, edited, closed, reopened, labeled, unlabeled]
  pull_request:
    types: [opened, edited, closed, reopened, labeled, unlabeled]
  issue_comment:
    types: [created]

permissions:
  id-token: write
  contents: read
  issues: read
  pull-requests: read

jobs:
  sync-project-board:
    runs-on: ubuntu-latest
    name: Sync to Project Board
    steps:
      - name: Forward to Project Manager
        uses: invertase/invertase-project-board@v1
        with:
          project-boards: '[1, 2, 3]'
          blocked: '["blocked", "on-hold"]'
          in_progress: '["in-progress", "wip"]'
          ready: '["ready", "approved"]'
          needs_response: '["needs-info", "waiting-for-response"]'
```

## Security

This action uses GitHub's OIDC (OpenID Connect) provider to generate authentication tokens. The tokens are:

- Short-lived and automatically expire
- Scoped to your specific endpoint (audience claim)
- Signed by GitHub for verification
- Transmitted over HTTPS

Your endpoint should verify the OIDC token before processing events.

## Troubleshooting

### Events Not Being Forwarded

1. Check that your workflow permissions include `id-token: write`
2. Verify the endpoint URL is accessible
3. Check workflow run logs for error messages

### Comments Not Being Sent

Only comments from the original post (OP) author are forwarded. This is intentional to prevent noise from other comments.

### PR Links Not Collected

Ensure your repository has PRs that use closing keywords (e.g., "Closes #123", "Fixes #456") in the PR description.

## License

See [LICENSE](LICENSE) for more information.
