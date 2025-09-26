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
  - `vscode-<vscode-commit-sha>` - Builds with specific VS Code Server versions
  - `vscode-<vscode-commit-sha>-<commit-sha>` - Combination of VS Code Server and container commit

**Recommended**: Use `latest` for stable deployments or `vscode-<vscode-commit-sha>` for reproducible builds with specific VS Code Server versions.

## 🚀 Quick Start

### Using the Published Container

Add this to your `.devcontainer/devcontainer.json`:

```json
{
  "name": "Python Development",
  "image": "ghcr.io/smartdatafoundry/devcontainer:latest"
}
```

### Using in SDF Trusted Research Environment

For detailed instructions on setting up and using this dev container within the SDF Trusted Research Environment, see:

**[📋 SDF TRE Setup Guide](SDF_TRE_SETUP.md)**

This includes:
- Manual Dev Containers extension installation
- TRE-specific configuration requirements
- Proxy and network setup
- Troubleshooting TRE-specific issues

### Using This Repository Directly

1. Clone this repository
2. Open in VS Code
3. Select "Reopen in Container" when prompted

## 📚 Documentation

- [SDF TRE Setup Guide](SDF_TRE_SETUP.md) - Complete setup guide for SDF Trusted Research Environment
- [Dev Container Details](DEVCONTAINER.md) - Complete documentation about the container
- [Build & Publish Guide](docs/BUILD_PUBLISH_CONTAINER.md) - Guide for building and publishing containers
- [Dev Container Spec](https://containers.dev) - Learn more about dev containers

## 🛠️ What's Included

- **Base**: Ubuntu 24.04 (Noble) via Microsoft's devcontainers base image
- **Python**: System Python with development tools (via devcontainer feature)
- **R**: Full R language support with development tools (via Rocker Project devcontainer feature)
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

## 📊 R Language Support

This dev container includes comprehensive R language support through the [Rocker Project's devcontainer features](https://github.com/rocker-org/devcontainer-features). The R feature provides:

### Features Available
- **R Installation**: Latest R version via apt package manager
- **Development Tools**: devtools, renv for package management
- **IDE Integration**: 
  - languageserver package for VS Code R extension support
  - httpgd package for interactive graphics
  - rmarkdown for document generation
- **Jupyter Integration**: R kernel for Jupyter notebooks
- **Interactive Console**: radian (enhanced R console with syntax highlighting)
- **Debugging Support**: vscDebugger package for VS Code R debugging

## ⚙️ VS Code Server

The container comes with VS Code Server pre-installed for immediate development. For TRE-specific VS Code Server configuration, see the [SDF TRE Setup Guide](SDF_TRE_SETUP.md).

## Adding New Extensions
To add new VS Code extensions to the container, follow these steps:
1. Open the appropriate file in `.devcontainer/vscode-init/`:
   - `extensions-to-install.txt` for extensions to install directly
   - `extensions-to-download.txt` for extensions that need to be downloaded first
2. Add the identifier of the desired extension in the format `publisher.extensionName` on a new line.
3. Save the changes to the extension file.
4. Commit and push the changes to your repository to trigger the build workflow with the updated extensions

## 🔄 Automated Builds

The container is built automatically with smart tagging:

- **Pull Requests**: Creates `pr-<number>` tags for testing (uses default VS Code Server commit)
- **Manual Dispatch**: Creates production tags with custom VS Code Server commit hash
  - Required input: VS Code Server commit hash
  - Creates `latest`, `main`, `vscode-<vscode-commit-sha>`, and commit-based tags
- **Platform**: linux/amd64 optimized for development speed

### Manual Build Process

To create a production build with a specific VS Code Server version:

1. Go to [Actions → Build and Publish Dev Container](../../actions/workflows/build-devcontainer.yml)
2. Click "Run workflow"
3. Enter the desired VS Code Server commit hash (required)
4. Click "Run workflow"

This ensures all published builds use the correct VS Code Server version and prevents automatic builds with mismatched versions.

### Tag Strategy
- Use `latest` for the most recent stable release
- Use `main-<commit-sha>` when you need reproducible builds
- Use `pr-<number>` tags to test specific pull request changes
- Use `vscode-<vscode-commit-sha>` tags to match specific VS Code Server versions
- Use `vscode-<vscode-commit-sha>-<container-commit-sha>` tags for complete reproducibility (specific VS Code Server + container version)
