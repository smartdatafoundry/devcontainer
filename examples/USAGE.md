# Example: Using the Published Dev Container

This directory contains examples of how to use the published dev container with different tagging strategies.

## Available Tags

The dev container is published with multiple tags:
- `latest` - Latest stable build from main branch
- `main` - Latest build from main branch  
- `main-<commit-sha>` - Specific commit builds from main branch
- `pr-<number>` - Pull request builds for testing

## Example 1: Basic Usage (Latest Stable)

Create a `.devcontainer/devcontainer.json` in your project:

```json
{
  "name": "My Python Project",
  "image": "ghcr.io/smartdatafoundry/devcontainer-python:latest",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python"
        // Note: Continue, Black formatter, Jupyter, Markdown All in One, 
        // and Rainbow CSV are already included in the base image
      ]
    }
  },
  "postCreateCommand": "pip install -r requirements.txt"
}
```

## Example 2: Reproducible Build (Specific Commit)

For reproducible builds, pin to a specific commit:

```json
{
  "name": "My Python Project - Reproducible",
  "image": "ghcr.io/smartdatafoundry/devcontainer-python:main-abc1234",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python"
        // Base image already includes: Continue, Black formatter, 
        // Jupyter, Markdown All in One, Rainbow CSV
      ]
    }
  },
  "postCreateCommand": "pip install -r requirements.txt"
}
}
```

## Example 3: With Additional Features

```json
{
  "name": "Advanced Python Development",
  "image": "ghcr.io/smartdatafoundry/devcontainer-python:latest",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python"
        // Note: Jupyter and Black formatter are already included
        // Additional extensions can be added as needed
      ],
      "settings": {
        "python.defaultInterpreterPath": "/usr/bin/python3",
        "python.formatting.provider": "black"
      }
    }
  },
  "postCreateCommand": [
    "pip install --upgrade pip",
    "pip install -r requirements.txt"
  ]
}
  ]
}
```

## Example 3: With Environment Variables

```json
{
  "name": "Python with Environment",
  "image": "ghcr.io/smartdatafoundry/devcontainer-python:latest",
  "containerEnv": {
    "PYTHONPATH": "/workspace",
    "ENVIRONMENT": "development"
  },
  "remoteEnv": {
    "LOCAL_WORKSPACE_FOLDER": "${localWorkspaceFolder}"
  }
}
```

## Docker Compose Example

Create a `docker-compose.yml`:

```yaml
version: '3.8'
services:
  devcontainer:
    image: ghcr.io/smartdatafoundry/devcontainer-python:latest
    volumes:
      - .:/workspace
      - /var/run/docker.sock:/var/run/docker.sock
    working_dir: /workspace
    command: sleep infinity
    environment:
      - PYTHONPATH=/workspace
```

Then create `.devcontainer/devcontainer.json`:

```json
{
  "name": "Python with Docker Compose",
  "dockerComposeFile": "../docker-compose.yml",
  "service": "devcontainer",
  "workspaceFolder": "/workspace"
}
```

## 🏷️ Choosing the Right Tag

### For Different Use Cases

| Use Case | Recommended Tag | Example | Benefits |
|----------|----------------|---------|----------|
| **Development** | `latest` | `ghcr.io/smartdatafoundry/devcontainer-python:latest` | Always up-to-date, stable |
| **Production/CI** | `main-<sha>` | `ghcr.io/smartdatafoundry/devcontainer-python:main-abc1234` | Reproducible, immutable |
| **Testing PRs** | `pr-<number>` | `ghcr.io/smartdatafoundry/devcontainer-python:pr-42` | Test specific changes |
| **Latest Main** | `main` | `ghcr.io/smartdatafoundry/devcontainer-python:main` | Latest main branch |

### Finding Available Tags

Visit the [GitHub Container Registry page](https://github.com/smartdatafoundry/devcontainer-python/pkgs/container/devcontainer-python) to see all available tags and their creation dates.

### Best Practices

1. **Use `latest` for development** - Always gets the most recent stable version
2. **Pin to specific SHA for production** - Ensures consistent, reproducible environments
3. **Test with PR tags** - Validate changes before they're merged
4. **Document your choice** - Include a comment explaining why you chose a specific tag

```json
{
  "name": "My Production App",
  // Using specific commit for reproducible production builds
  "image": "ghcr.io/smartdatafoundry/devcontainer-python:main-abc1234",
  "customizations": {
    "vscode": {
      "extensions": ["ms-python.python"]
    }
  }
}
```
