# Dev Container for Python Development

This repository contains a development container configuration optimized for Python development, along with automated workflows to build and publish the container image to GitHub Container Registry (GHCR).

## 📦 Published Container

The dev container is automatically built and published with multiple tags:

- **Registry**: `ghcr.io`
- **Base Image**: `ghcr.io/smartdatafoundry/devcontainer`
- **Available Tags**:
  - `latest` - Latest stable build from main branch
  - `main` - Latest build from main branch  
  - `main-<commit-sha>` - Specific commit builds from main branch
  - `pr-<number>` - Pull request builds for testing

### Choosing the Right Tag

- **For production/stable use**: `ghcr.io/smartdatafoundry/devcontainer:latest`
- **For reproducible builds**: `ghcr.io/smartdatafoundry/devcontainer:main-abc1234` 
- **For testing PR changes**: `ghcr.io/smartdatafoundry/devcontainer:pr-123`

## 🚀 Quick Start

### Using in VS Code Dev Containers

1. Create or update your `.devcontainer/devcontainer.json`:

```json
{
  "name": "Python Development",
  "image": "ghcr.io/smartdatafoundry/devcontainer:latest",
  "features": {},
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python"
      ]
    }
  }
}
```

2. Open the folder in VS Code and select "Reopen in Container"

### Using with Docker

```bash
# Pull the latest stable image
docker pull ghcr.io/smartdatafoundry/devcontainer:latest

# Or pull a specific commit version
docker pull ghcr.io/smartdatafoundry/devcontainer:main-abc1234

# Run interactively
docker run --rm -it ghcr.io/smartdatafoundry/devcontainer:latest bash

# Mount your project directory
docker run --rm -it -v $(pwd):/workspace ghcr.io/smartdatafoundry/devcontainer:latest
```

## 🛠️ What's Included

This dev container includes:

- **Base**: Ubuntu Noble (24.04) via Microsoft's `mcr.microsoft.com/devcontainers/base:noble`
- **Python**: System Python with pip and development tools (via devcontainer feature)
- **Git**: Latest version with configuration support
- **Shell**: Zsh with Oh My Zsh configuration (via common-utils feature)
- **Quarto**: For document publishing and data science workflows (latest version)
- **Marimo**: Markdown presentation tool, alternative to Jupyter Notebooks (latest version)
- **VS Code Server**: Pre-installed for immediate development
- **VS Code Extensions**:
  - Continue (AI assistant)
  - Black formatter for Python
  - Jupyter support
  - Markdown All in One
  - Rainbow CSV

## 🔄 Automated Builds

The container is automatically built and published using GitHub Actions:

### Build Workflow (`build-devcontainer.yml`)
- **Triggers**: Push to main branch, PRs, manual dispatch
- **Features**: Single platform (linux/amd64), intelligent caching, comprehensive validation tests
- **Publishing**: Multi-tag publishing with `latest`, `main`, `main-<sha>`, and `pr-<number>` tags
- **Testing**: Validates Python, Git, Zsh, and Quarto installations

## 📁 Repository Structure

```
├── .devcontainer/
│   ├── devcontainer.json          # Dev container configuration
│   ├── Dockerfile                 # Custom Docker build
│   └── vscode-init/               # VS Code server and extensions setup
│       ├── 00-install-vscode-server.sh
│       ├── 01-install-extensions.sh
│       ├── 02-download-extensions.sh
│       ├── extensions-to-download.txt
│       └── extensions-to-install.txt
├── .github/workflows/
│   ├── build-devcontainer.yml     # Build and publish workflow
│   └── build-publish-container.yml
├── assets/                        # Documentation assets
├── docs/                          # Additional documentation
├── DEVCONTAINER.md                # Detailed documentation
├── README.md                      # Overview and quick start
└── SDF_TRE_SETUP.md              # SDF TRE setup guide
```

## 🔧 Customization

To customize this dev container for your needs:

1. Fork this repository
2. Modify `.devcontainer/devcontainer.json`:
   - Add/remove features
   - Update VS Code extensions
   - Change base image or configuration
3. Update the workflows to use your repository name
4. Push changes - the container will be built automatically

## 🏗️ Local Development
## 🔄 Automated Build Process

The container images are built and published automatically using GitHub Actions with intelligent tagging:

### Build Triggers
- **Main Branch Pushes**: Builds when `.devcontainer/**` or workflow files change
- **Pull Requests**: Builds for testing when devcontainer files are modified
- **Manual Dispatch**: On-demand builds via GitHub Actions workflow

### Build Process
1. **Container Build**: Uses `devcontainers/ci` action for proper dev container support
2. **Testing**: Validates Python, Git, and tool installations
3. **Tag Extraction**: Processes metadata to create appropriate image tags
4. **Publishing**: Pushes to GitHub Container Registry with all generated tags

### Tag Strategy
The build system creates multiple tags from a single build:
- `latest`: Only for main branch, represents the most stable version
- `main`: Latest commit from main branch
- `main-<sha>`: Specific commit SHA for reproducible builds
- `pr-<number>`: Pull request builds for testing changes

## 🧪 Testing

To test the dev container locally:

```bash
# Install the devcontainer CLI
npm install -g @devcontainers/cli

# Build the container
devcontainer build --workspace-folder .

# Run the container
devcontainer exec --workspace-folder . bash
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes to `.devcontainer/devcontainer.json`
4. Test locally using the devcontainer CLI
5. Submit a pull request

The GitHub Action will automatically test your changes when you submit a PR.

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

---

**Note**: The container includes a mount point for `/safe_data` which may be specific to certain environments. Remove or modify this mount in the devcontainer.json if not needed for your use case.
