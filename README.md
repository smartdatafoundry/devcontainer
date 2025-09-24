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
  - `vscode-<vscode-commit-sha>` - Builds with specific VS Code versions
  - `vscode-<vscode-commit-sha>-<commit-sha>` - Combination of VS Code and git commit

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
- [Usage Examples](examples/USAGE.md) - Examples of how to use the published container
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

### R Package Installation Options

The R feature supports multiple package installation methods:

1. **Binary Installation via apt** (Fastest)
   - Uses pre-compiled packages from CRAN and BioConductor
   - On Ubuntu, all CRAN packages available via [r2u](https://eddelbuettel.github.io/r2u/)
   - Install using: `apt-get install r-cran-<package-name>`

2. **Source Installation via R**
   - Traditional `install.packages()` function
   - Required for packages not available via apt

3. **Binary Installation with bspm** (Ubuntu only)
   - Bridge to System Package Manager
   - Automatically uses apt when available, falls back to source

### Configuration Example

To enable R support in your devcontainer, add the r-apt feature to your `devcontainer.json`:

```json
{
  "name": "Python & R Development Environment",
  "build": {
    "dockerfile": "Dockerfile"
  },
  "features": {
    "ghcr.io/rocker-org/devcontainer-features/r-apt:0": {
      "vscodeRSupport": "full",
      "installDevTools": true,
      "installREnv": true,
      "installRMarkdown": true,
      "installJupyterlab": true,
      "installRadian": true,
      "installVscDebugger": true
    }
  }
}
```

### Supported Platforms
- `linux/amd64` and `linux/arm64` platforms
- Debian and Ubuntu LTS distributions
- Compatible with non-R base images (R will be installed automatically)

### Additional R Features

The Rocker Project provides additional complementary features you can combine:

- **r-packages**: Install specific R packages via pak during build
- **r-dependent-packages**: Install R packages from a DESCRIPTION file
- **renv-cache**: Share renv cache across containers
- **rstudio-server**: Add RStudio Server for web-based IDE

Example with additional features:
```json
"features": {
  "ghcr.io/rocker-org/devcontainer-features/r-apt:0": {
    "vscodeRSupport": "full",
    "installDevTools": true,
    "installREnv": true
  },
  "ghcr.io/rocker-org/devcontainer-features/r-packages:1": {
    "packages": "dplyr,ggplot2,tidyr"
  },
  "ghcr.io/rocker-org/devcontainer-features/rstudio-server:0": {}
}
```

For more detailed information about R devcontainer features, visit the [Rocker Project devcontainer features documentation](https://github.com/rocker-org/devcontainer-features/tree/main/src/r-apt).

## ⚙️ VS Code Server

The container comes with VS Code Server pre-installed for immediate development. For TRE-specific VS Code Server configuration, see the [SDF TRE Setup Guide](SDF_TRE_SETUP.md).

## Adding New Extensions
To add new VS Code extensions to the container, follow these steps:
1. Open the `.devcontainer/vscode-init/vscode-extensions.txt` file.
2. Add the identifier of the desired extension in the format `publisher.extensionName` on a new line.
3. Save the changes to the `vscode-extensions.txt` file.
4. Commit and push the changes to your repository to trigger the build workflow with the updated extensions

## 🔄 Automated Builds

The container is built automatically with smart tagging:

- **Main Branch Pushes**: Creates `latest`, `main`, and `main-<commit-sha>` tags
- **Pull Requests**: Creates `pr-<number>` tags for testing
- **VS Code Commits**: Creates `vscode-<vscode-commit-sha>` and `vscode-<vscode-commit-sha>-<commit-sha>` tags
- **Manual Dispatch**: Available for on-demand builds
- **Platform**: linux/amd64 optimized for development speed

### Tag Strategy
- Use `latest` for the most recent stable release
- Use `main-<commit-sha>` when you need reproducible builds
- Use `pr-<number>` tags to test specific pull request changes
- Use `vscode-<commit-sha>` tags to match specific VS Code versions
- Use `vscode-<commit-sha>-<container-commit-sha>` tags for a combination of VS Code and git commits
