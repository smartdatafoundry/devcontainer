# Dev Container for Python Development

This repository contains a development container configuration optimized for Python development, along with automated workflows to build and publish the container image to GitHub Container Registry (GHCR).

## 📦 Published Container

The dev container is automatically built and published to:
- **Registry**: `ghcr.io`
- **Image**: `ghcr.io/smartdatafoundry/devcontainer-python:latest`

## 🚀 Quick Start

### Using in VS Code Dev Containers

1. Create or update your `.devcontainer/devcontainer.json`:

```json
{
  "name": "Python Development",
  "image": "ghcr.io/smartdatafoundry/devcontainer-python:latest",
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
# Pull the latest image
docker pull ghcr.io/smartdatafoundry/devcontainer-python:latest

# Run interactively
docker run --rm -it ghcr.io/smartdatafoundry/devcontainer-python:latest bash

# Mount your project directory
docker run --rm -it -v $(pwd):/workspace ghcr.io/smartdatafoundry/devcontainer-python:latest
```

## 🛠️ What's Included

This dev container includes:

- **Base**: Ubuntu Noble (24.04) with non-root user setup
- **Python**: System Python with pip and development tools
- **Git**: Latest version with configuration support
- **Shell**: Zsh with Oh My Zsh configuration
- **Quarto**: For document publishing and data science workflows
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
- **Features**: Single platform (linux/amd64), caching, validation tests
- **Publishing**: Only publishes from main branch to `ghcr.io/smartdatafoundry/devcontainer-python:latest`

## 📁 Repository Structure

```
├── .devcontainer/
│   └── devcontainer.json          # Dev container configuration
├── .github/workflows/
│   └── build-devcontainer.yml     # Build and publish workflow
└── README.md                      # This file
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
