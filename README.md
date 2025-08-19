# devcontainer-python

Base Dev Container development environment for working with Python

[![Build and Publish Dev Container](https://github.com/smartdatafoundry/devcontainer-python/actions/workflows/build-devcontainer.yml/badge.svg)](https://github.com/smartdatafoundry/devcontainer-python/actions/workflows/build-devcontainer.yml)

## 📦 Published Container

This dev container is automatically built and published to GitHub Container Registry:

- **Image**: `ghcr.io/smartdatafoundry/devcontainer-python:latest`
- **Registry**: GitHub Container Registry (GHCR)

## 🚀 Quick Start

### Using the Published Container

Add this to your `.devcontainer/devcontainer.json`:

```json
{
  "name": "Python Development",
  "image": "ghcr.io/smartdatafoundry/devcontainer-python:latest"
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

- **Base**: Ubuntu 24.04 (Noble) 
- **Python**: System Python with pip and development tools
- **Git**: Latest version with configuration support
- **Shell**: Zsh with Oh My Zsh
- **Quarto**: Document publishing platform
- **VS Code Extensions**: Python development essentials

## 🔄 Automated Builds

The container is built automatically:
- On pushes to main branch
- On pull requests (for testing)
- Manual workflow dispatch
- Single platform (linux/amd64) for simplicity and speed
