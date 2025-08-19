# Example: Using the Published Dev Container

This directory contains examples of how to use the published dev container `ghcr.io/smartdatafoundry/devcontainer-python:latest`.

## Example 1: Basic Usage

Create a `.devcontainer/devcontainer.json` in your project:

```json
{
  "name": "My Python Project",
  "image": "ghcr.io/smartdatafoundry/devcontainer-python:latest",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.pylint"
      ]
    }
  },
  "postCreateCommand": "pip install -r requirements.txt"
}
```

## Example 2: With Additional Features

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
        "ms-python.python",
        "ms-toolsai.jupyter",
        "ms-python.black-formatter"
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
