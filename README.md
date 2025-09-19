<div align="center">
  <img src="assets/ouroboros-chicken-logo.png" alt="devcontainer logo" width="200" height="200">
</div>

# devcontainer

Container to support Python development that comes with baked in support for the Visual Studio Code Dev Container extension, additionally includes supporting tooling and a rich set of IDE extensions.

[![Build and Publish Dev Container](https://github.com/smartdatafoundry/devcontainer/actions/workflows/build-devcontainer.yml/badge.svg)](https://github.com/smartdatafoundry/devcontainer/actions/workflows/build-devcontainer.yml)

## 📦 Published Container

This dev container is automatically built and published to GitHub Container Registry with multiple tags:

- **Registry**: GitHub Container Registry (GHCR)  
- **Base Image**: `ghcr.io/smartdatafoundry/devcontainer`
- **Available Tags**:
  - `latest` - Latest stable build from main branch
  - `main` - Latest build from main branch  
  - `main-<commit-sha>` - Specific commit builds from main branch
  - `pr-<number>` - Pull request builds for testing

**Recommended**: Use `latest` for stable deployments or `main-<commit-sha>` for reproducible builds.

## 🚀 Quick Start

### Using the Published Container

Add this to your `.devcontainer/devcontainer.json`:

```json
{
  "name": "Python Development",
  "image": "ghcr.io/smartdatafoundry/devcontainer:latest"
}
```

### Using the Published Container inside the SDF Trusted Research Environment

The following config contains additional arguments to enable devcontainers use
within the SDF Trusted Research Environment.

Add this to your `.devcontainer/devcontainer.json`:

```json
{
  "name": "Development Container",
  "image": "ghcr.io/smartdatafoundry/devcontainer:latest",

  "mounts": [
	  "source=/safe_data,target=/safe_data,type=bind,consistency=cached",
	  "type=tmpfs,target=/tmp"
	],

	"runArgs": [
	  "--userns=host"
	],

  "remoteUser": "root"
}
```

### Using This Repository Directly

1. Clone this repository
2. Open in VS Code
3. Select "Reopen in Container" when prompted

## 📚 Documentation

- [Dev Container Details](DEVCONTAINER.md) - Complete documentation about the container
- [Usage Examples](examples/USAGE.md) - Examples of how to use the published container
- [Dev Container Spec](https://containers.dev) - Learn more about dev containers

## 🛠️ What's Included

- **Base**: Ubuntu 24.04 (Noble) via Microsoft's devcontainers base image
- **Python**: System Python with development tools (via devcontainer feature)
- **Git**: Latest version with configuration support
- **Shell**: Zsh with Oh My Zsh (via common-utils feature)
- **Quarto**: Document publishing platform (latest version)
- **Marimo**: Markdown presentation tool, alternative to Jupyter Notebooks
- **VS Code Extensions**:
  - Continue (AI coding assistant)
  - Python Black formatter
  - Jupyter notebook support
  - Marimo
  - Markdown All in One
  - Rainbow CSV
- **VS Code Server**: Pre-installed for immediate development

## ⚙️ Configuring VS Code Server Version

The container comes with VS Code Server pre-installed for immediate development
within the SDF Trusted Research Environment. The specific version of VS Code 
Server is controlled via the `devcontainer.json` file and needs to track the 
exact commit of the VS Code version inside the Trusted Research Environment,
available via _Help > About_.

To update the VS Code commit argument in the devcontainer file, follow these steps:
- Open the devcontainer file located at `.devcontainer/devcontainer.json`.
- Locate the line that specifies the VS Code commit argument. It should look something like this:
  ```json
  {
    ...
    "build": {
      "dockerfile": "Dockerfile",
      "args": {
        "VSCODE_COMMIT": "your_commit_hash_here"
      }
    },
    ...
  }
  ```
- Replace `your_commit_hash_here` with the desired commit hash of the VS Code Server you want to target.
- Save the changes to the devcontainer file.
- Commit and push the changes to your repository to trigger the build workflow with the updated VS Code commit.

## 🔄 Automated Builds

The container is built automatically with smart tagging:

- **Main Branch Pushes**: Creates `latest`, `main`, and `main-<commit-sha>` tags
- **Pull Requests**: Creates `pr-<number>` tags for testing
- **Manual Dispatch**: Available for on-demand builds
- **Platform**: linux/amd64 optimized for development speed

### Tag Strategy
- Use `latest` for the most recent stable release
- Use `main-<commit-sha>` when you need reproducible builds
- Use `pr-<number>` tags to test specific pull request changes
