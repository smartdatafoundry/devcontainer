# VS Code Auto-Update Workflow

## Overview

The `update-vscode.yml` GitHub Actions workflow automatically checks for new VS Code releases daily and creates pull requests to update the devcontainer when a new version is available.

## How It Works

1. **Daily Check**: The workflow runs every day at 2:00 AM UTC (configurable via cron schedule)
2. **Version Detection**: Queries the GitHub API to get the latest stable VS Code release tag
3. **Commit Hash Retrieval**: Fetches the commit hash associated with the latest release tag
4. **Comparison**: Compares the latest release commit hash with the current `VSCODE_COMMIT` in `Dockerfile`
5. **Update Process**: If a new version is found:
   - Updates the `VSCODE_COMMIT` argument in the Dockerfile
   - Creates a new branch named `automated/update-vscode-<short-commit-hash>`
   - Opens a pull request with detailed information about the update
   - Enables auto-merge to automatically merge the PR once checks pass

## Repository Settings Required

For the workflow to function properly, you need to enable the following settings in your GitHub repository:

### 1. Allow GitHub Actions to Create PRs

Go to **Settings** → **Actions** → **General** → **Workflow permissions**:
- Select **"Read and write permissions"**
- Check **"Allow GitHub Actions to create and approve pull requests"**

### 2. Enable Auto-Merge (Optional but Recommended)

Go to **Settings** → **General** → **Pull Requests**:
- Check **"Allow auto-merge"**

### 3. Branch Protection Rules (Recommended)

To ensure auto-merge works safely, configure branch protection for `main`:

Go to **Settings** → **Branches** → **Add rule**:
- Branch name pattern: `main`
- Check **"Require status checks to pass before merging"**
- Select the required status checks (e.g., `build-and-publish`)
- Check **"Require branches to be up to date before merging"**

With these settings, the PR will only auto-merge after all required checks pass.

## Manual Trigger

You can manually trigger the workflow at any time:

```bash
gh workflow run update-vscode.yml
```

Or via the GitHub UI:
1. Go to **Actions** → **Update VS Code Version**
2. Click **Run workflow**

## Workflow Behavior

### When Update is Available

1. Creates a PR with:
   - Title: `chore: update VS Code to <version-tag>`
   - Labels: `automated`, `dependencies`, `devcontainer`
   - Detailed description with version information
2. Triggers the existing build workflow (via PR)
3. Auto-merge enabled (merges automatically once checks pass)
4. Branch automatically deleted after merge

### When Already Up to Date

- Workflow completes successfully
- No PR is created
- Summary indicates no action needed

## Workflow Steps

The workflow performs the following steps:

1. **Checkout repository**: Checks out the repository code
2. **Get current VS Code commit**: Extracts the current `VSCODE_COMMIT` from the Dockerfile
3. **Fetch latest stable VS Code commit**: 
   - Queries GitHub API for the latest release tag
   - Fetches the commit hash for that tag
   - Validates the commit hash format
4. **Check if update needed**: Compares current vs latest commit hashes
5. **Update Dockerfile**: Updates the `VSCODE_COMMIT` argument if needed
6. **Create Pull Request**: Uses `peter-evans/create-pull-request@v7` to create the PR
7. **Enable auto-merge**: Uses GitHub CLI to enable auto-merge on the PR
8. **Summary**: Provides a summary in the GitHub Actions UI

## Customization

### Change Schedule

Edit the cron expression in `.github/workflows/update-vscode.yml`:

```yaml
on:
  schedule:
    # Run daily at 2 AM UTC
    - cron: '0 2 * * *'
```

Examples:
- Twice daily: `'0 2,14 * * *'` (2 AM and 2 PM)
- Weekly: `'0 2 * * 1'` (Monday at 2 AM)
- Hourly: `'0 * * * *'`

### Disable Auto-Merge

Remove or comment out the "Enable auto-merge" step in the workflow file.

### Change Merge Strategy

Edit the merge strategy in the "Enable auto-merge" step:

```bash
# Current: squash merge
gh pr merge "$PR_NUMBER" --auto --squash --delete-branch

# Alternative: merge commit
gh pr merge "$PR_NUMBER" --auto --merge --delete-branch

# Alternative: rebase
gh pr merge "$PR_NUMBER" --auto --rebase --delete-branch
```

## Monitoring

### Check Workflow Status

```bash
# List recent runs
gh run list --workflow=update-vscode.yml

# View details of latest run
gh run view --workflow=update-vscode.yml

# Watch a running workflow
gh run watch
```

### View Created PRs

```bash
# List PRs created by the workflow
gh pr list --label automated --label dependencies

# View a specific PR
gh pr view <PR_NUMBER>
```

## Troubleshooting

### Workflow Fails to Create PR

**Possible causes:**
- Insufficient permissions (check workflow permissions in settings)
- Branch protection rules preventing PR creation
- Network issues accessing GitHub API

**Solution:**
- Verify **"Read and write permissions"** are enabled
- Ensure **"Allow GitHub Actions to create and approve pull requests"** is checked
- Check the workflow logs for specific error messages

### Auto-Merge Not Working

**Possible causes:**
- Auto-merge not enabled in repository settings
- Required status checks not configured
- Status checks failing
- Branch protection rules misconfigured

**Solution:**
- Enable auto-merge in repository settings
- Configure branch protection rules with required status checks
- Check the PR status checks and fix any failures
- Verify the workflow has sufficient permissions

### API Rate Limiting

The workflow uses the GitHub API to fetch VS Code releases. If you hit rate limits:

**Solution:**
- The workflow uses `GITHUB_TOKEN` which has higher rate limits (1000 requests/hour)
- Consider reducing the frequency of scheduled runs
- Check rate limit status: `curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/rate_limit`

### Invalid Commit Hash

If the workflow fails to fetch a valid commit hash:

**Possible causes:**
- GitHub API returned unexpected format
- VS Code release structure changed
- Network/connectivity issues

**Solution:**
- Check the workflow logs for the specific error
- Manually verify the latest release: `curl -s https://api.github.com/repos/microsoft/vscode/releases/latest`
- The workflow validates commit hashes are 40-character hex strings

## Integration with Existing Workflows

The auto-update workflow integrates seamlessly with existing workflows:

1. **build-devcontainer.yml**: Triggered automatically when PR is created
2. **Security scanning**: Runs as part of the build workflow
3. **Container publishing**: Only happens after merge to main

## Security Considerations

- The workflow only updates a single ARG value in the Dockerfile
- Changes are reviewed via PR before merge (even with auto-merge)
- All updates trigger the full build and test pipeline
- Security scans run automatically on the updated container
- Auto-merge only proceeds if all checks pass
- Uses `GITHUB_TOKEN` with minimal required permissions

## Example PR

When an update is available, the workflow creates a PR like this:

```markdown
## 🔄 Automated VS Code Update

This PR updates the VS Code commit hash to the latest stable release.

**Previous version:** `7d842fb85a0275a4a8e4d7e040d2625abbf7f084`
**New version:** `a1b2c3d4e5f6789012345678901234567890abcd`
**Release tag:** `1.95.0`

### Changes
- Updated `VSCODE_COMMIT` in `Dockerfile`

### Verification
This PR will trigger the build workflow to ensure the container builds successfully with the new VS Code version.
```

## Disabling the Workflow

If you need to temporarily disable the workflow:

1. **Via GitHub UI**: Go to Actions → Update VS Code Version → "..." → Disable workflow
2. **Via CLI**: `gh workflow disable update-vscode.yml`

To re-enable:
```bash
gh workflow enable update-vscode.yml
```

## Dependencies

The workflow relies on:
- **GitHub Actions**: `actions/checkout@v4`
- **Create Pull Request**: `peter-evans/create-pull-request@v7`
- **GitHub CLI**: `gh` (pre-installed on GitHub-hosted runners)
- **Standard tools**: `curl`, `jq`, `grep`, `sed`

## Version History

- **v1.0**: Initial implementation with daily checks and auto-merge
- Uses `peter-evans/create-pull-request@v7` for PR creation
- Fetches VS Code releases via GitHub API
