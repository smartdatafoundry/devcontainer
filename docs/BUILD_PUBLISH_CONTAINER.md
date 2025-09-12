# Guide: Implementing the Reusable Docker Publish Workflow

This guide explains how to use the reusable workflow for building and publishing Docker images to GitHub Packages in your repository.

## 1. Prerequisites
- Your repository must have a valid `Dockerfile`.
- The reusable workflow file should exist at `.github/workflows/build-publish-container.yml` in the source repository.
- You need permissions to call workflows and publish packages.

## 2. Reference the Reusable Workflow
In your repository, create a workflow file (e.g., `.github/workflows/publish-docker.yml`) with the following example:

```yaml
name: Build and Publish Docker Image

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  publish:
    uses: smartdatafoundry/devcontainer/.github/workflows/build-publish-container.yml@v1.0.0
    with:
      dockerfile: Dockerfile # Optional, defaults to 'Dockerfile'
      image-name: ${{ github.repository }} # Optional, defaults to repo name
      fail-on-security: '0' # Optional, defaults to '0' (non-blocking scan)
```

- Replace `smartdatafoundry/devcontainer` with the owner/repo of the reusable workflow if different.
- You can override `dockerfile`, `image-name`, and `fail-on-security` as needed.
- Set `fail-on-security: '1'` to make security scans blocking (fail the workflow on vulnerabilities).

## 3. How It Works
- The workflow will run on pushes to `main`, pull requests to `main`, and when manually triggered.
- It builds the Docker image locally (without pushing initially).
- **Security scanning** is performed using Trivy to identify vulnerabilities.
- After successful scanning, the image is pushed to GitHub Packages (`ghcr.io`).
- Tags are automatically generated using commit SHA, branch, PR, and tag references for best practice.

## 4. Authentication
- The workflow uses `GITHUB_TOKEN` for authentication to GitHub Packages. No extra secrets are required for publishing to `ghcr.io`.

## 5. Security Scanning
The workflow includes automated security scanning using Trivy:
- **Non-blocking by default**: Vulnerabilities are reported but don't fail the workflow
- **Configurable behavior**: Set `fail-on-security: '1'` to make scans blocking
- **Comprehensive scanning**: Checks for CRITICAL and HIGH severity vulnerabilities
- **PR comments**: Security scan results are automatically posted as PR comments
- **Artifact retention**: Scan results are stored as workflow artifacts for 30 days

### Example: Blocking Security Scan
```yaml
jobs:
  publish:
    uses: smartdatafoundry/devcontainer/.github/workflows/build-publish-container.yml@v1.0.0
    with:
      fail-on-security: '1' # Fail workflow if vulnerabilities found
```

## 6. Best Practices
- Pin the reusable workflow to a commit SHA for security (e.g., `@a1b2c3d4` instead of `@main`).
- Use descriptive image names and tags.
- Review permissions in your workflow for least privilege.
- Consider using blocking security scans (`fail-on-security: '1'`) for production workflows.
- Monitor security scan artifacts and PR comments for vulnerability reports.

## 7. Troubleshooting
- Ensure your repository has a valid `Dockerfile` at the specified path.
- Check that you have write permissions to GitHub Packages.
- Review workflow run logs for errors in build, scan, or publish steps.
- **Security scan failures**: Check the Trivy scan artifacts for detailed vulnerability reports.
- **Blocking scans**: If using `fail-on-security: '1'`, address vulnerabilities before the workflow will succeed.

## 8. Resources
- [GitHub Actions: Reusing workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows)
- [Publishing Docker images to GitHub Packages](https://docs.github.com/en/actions/tutorials/publish-packages/publish-docker-images#publishing-images-to-github-packages)
- [Trivy Security Scanner](https://github.com/aquasecurity/trivy)
- [Custom Trivy Action](https://github.com/smartdatafoundry/trivy-security-scan)

---

For further help, consult the GitHub Actions documentation or reach out to your repository administrator.

## 🏷️ Choosing the Right Tag

### For Different Use Cases

| Use Case | Recommended Tag | Example | Benefits |
|----------|----------------|---------|----------|
| **Development** | `latest` | `ghcr.io/smartdatafoundry/devcontainer:latest` | Always up-to-date, stable |
| **Production/CI** | `main-<sha>` | `ghcr.io/smartdatafoundry/devcontainer:main-abc1234` | Reproducible, immutable |
| **Testing PRs** | `pr-<number>` | `ghcr.io/smartdatafoundry/devcontainer:pr-42` | Test specific changes |
| **Latest Main** | `main` | `ghcr.io/smartdatafoundry/devcontainer:main` | Latest main branch |

### Finding Available Tags

Visit the [GitHub Container Registry page](https://github.com/smartdatafoundry/devcontainer/pkgs/container/devcontainer) to see all available tags and their creation dates.
