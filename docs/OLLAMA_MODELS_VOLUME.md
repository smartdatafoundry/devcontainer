# Ollama Models Data Volume

This guide explains how to build, publish, and use pre-built Ollama model data volumes from GitHub Container Registry.

## Overview

The Ollama Models Data Volume is a container image that contains pre-pulled Ollama models. This is useful for:

- **Air-gapped environments**: Pre-load models where internet access is restricted
- **Faster startup**: Skip model download time in development containers
- **Consistency**: Ensure everyone uses the same model versions
- **Bandwidth optimization**: Download models once, reuse many times

## Table of Contents

1. [Building Locally](#building-locally)
2. [Using Pre-built Images](#using-pre-built-images)
3. [GitHub Actions Workflow](#github-actions-workflow)
4. [Integration Examples](#integration-examples)
5. [Available Models](#available-models)
6. [Troubleshooting](#troubleshooting)

## Building Locally

### Prerequisites

- Docker or Podman installed
- Sufficient disk space for models (typically 2-10GB per model)
- GitHub personal access token (for pushing to GHCR)

### Using the Build Script

The `scripts/build-ollama-volume.sh` script provides a convenient way to build and publish Ollama model volumes.

#### Basic Usage

```bash
# Build with default models (llama3.2, codellama)
./scripts/build-ollama-volume.sh

# Build with specific models
./scripts/build-ollama-volume.sh -m "llama3.2,mistral,codellama"

# Build and push to registry
./scripts/build-ollama-volume.sh -m "llama3.2" -p
```

#### Script Options

| Option | Description | Default |
|--------|-------------|---------|
| `-m, --models` | Comma-separated list of models | `llama3.2,codellama` |
| `-t, --tag` | Tag for the container image | `latest` |
| `-r, --registry` | Container registry | `ghcr.io/smartdatafoundry` |
| `-n, --name` | Image name | `ollama-models` |
| `-p, --push` | Push to registry after build | `false` |
| `-h, --help` | Display help message | - |

#### Authentication

Before pushing, authenticate with GitHub Container Registry:

```bash
# Docker
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Podman
echo $GITHUB_TOKEN | podman login ghcr.io -u USERNAME --password-stdin
```

### Manual Build

If you prefer to build manually without the script:

```bash
# Create Dockerfile
cat > Dockerfile.ollama << 'EOF'
FROM ghcr.io/smartdatafoundry/ollama:latest AS builder

ARG MODELS
RUN /bin/ollama serve & \
    OLLAMA_PID=$! && \
    sleep 5 && \
    IFS=',' read -ra MODEL_ARRAY <<< "$MODELS" && \
    for model in "${MODEL_ARRAY[@]}"; do \
        ollama pull "$model"; \
    done && \
    kill $OLLAMA_PID

FROM scratch
COPY --from=builder /root/.ollama /root/.ollama
VOLUME ["/root/.ollama"]
EOF

# Build
docker build \
  --build-arg MODELS="llama3.2,codellama" \
  -t ghcr.io/smartdatafoundry/ollama-models:latest \
  -f Dockerfile.ollama .

# Push
docker push ghcr.io/smartdatafoundry/ollama-models:latest
```

## Using Pre-built Images

### Available Tags

| Tag | Description | Example |
|-----|-------------|---------|
| `latest` | Latest stable build from main | `ghcr.io/smartdatafoundry/ollama-models:latest` |
| `models-<hash>` | Specific model combination | `ghcr.io/smartdatafoundry/ollama-models:models-a1b2c3d4` |
| `pr-<number>` | Preview for pull request | `ghcr.io/smartdatafoundry/ollama-models:pr-42` |

### Docker Usage

```bash
# Pull the image
docker pull ghcr.io/smartdatafoundry/ollama-models:latest

# Create a container from the data volume
docker create --name ollama-models ghcr.io/smartdatafoundry/ollama-models:latest

# Run Ollama using the models volume
docker run -d \
  --name ollama \
  --volumes-from ollama-models \
  -p 11434:11434 \
  ghcr.io/smartdatafoundry/ollama:latest

# Verify models are available
docker exec ollama ollama list
```

### Podman Usage

```bash
# Pull the image
podman pull ghcr.io/smartdatafoundry/ollama-models:latest

# Create a container from the data volume
podman create --name ollama-models ghcr.io/smartdatafoundry/ollama-models:latest

# Run Ollama using the models volume
podman run -d \
  --name ollama \
  --volumes-from ollama-models \
  -p 11434:11434 \
  ghcr.io/smartdatafoundry/ollama:latest

# Verify models are available
podman exec ollama ollama list
```

### Using Named Volumes

For more flexibility, you can extract models to a named volume:

```bash
# Create a named volume
docker volume create ollama-models

# Extract models from the data volume image
docker run --rm \
  -v ollama-models:/dest \
  ghcr.io/smartdatafoundry/ollama-models:latest \
  sh -c "cp -r /root/.ollama/* /dest/"

# Run Ollama with the named volume
docker run -d \
  --name ollama \
  -v ollama-models:/root/.ollama \
  -p 11434:11434 \
  ghcr.io/smartdatafoundry/ollama:latest
```

## GitHub Actions Workflow

### Automated Builds

The repository includes a GitHub Actions workflow that automatically builds and publishes Ollama model volumes.

**Workflow file:** `.github/workflows/build-ollama-models.yml`

### Triggers

- **Push to main**: Builds with default models
- **Pull requests**: Builds for preview (no push)
- **Manual dispatch**: Build with custom models and tags

### Manual Workflow Dispatch

1. Go to **Actions** → **Build and Publish Ollama Models Volume**
2. Click **Run workflow**
3. Configure:
   - **Models**: Comma-separated list (e.g., `llama3.2,mistral,codellama`)
   - **Tag**: Primary tag (e.g., `latest`, `dev`, `v1.0`)
   - **Additional tags**: Optional extra tags
4. Click **Run workflow**

### Workflow Inputs

| Input | Description | Default |
|-------|-------------|---------|
| `models` | Comma-separated model list | `qwen3-coder:30b,nate/instinct,nomic-embed-text:v1.5` |
| `tag` | Primary image tag | `latest` |
| `additional_tags` | Extra tags (comma-separated) | `` |

## Integration Examples

### Dev Container Integration

Add to `.devcontainer/docker-compose.yml`:

```yaml
version: '3.8'

services:
  ollama-models:
    image: ghcr.io/smartdatafoundry/ollama-models:latest
    volumes:
      - ollama-data:/root/.ollama

  ollama:
    image: ghcr.io/smartdatafoundry/ollama:latest
    volumes:
      - ollama-data:/root/.ollama
    ports:
      - "11434:11434"

  devcontainer:
    image: ghcr.io/smartdatafoundry/devcontainer:latest
    volumes:
      - ..:/workspace:cached
    working_dir: /workspace
    depends_on:
      - ollama
    environment:
      - OLLAMA_HOST=http://ollama:11434

volumes:
  ollama-data:
```

And `.devcontainer/devcontainer.json`:

```json
{
  "name": "Development with Ollama",
  "dockerComposeFile": "docker-compose.yml",
  "service": "devcontainer",
  "workspaceFolder": "/workspace",
  "forwardPorts": [11434],
  "postStartCommand": "curl -s http://ollama:11434/api/tags | jq"
}
```

### SDF TRE Usage

```bash
# Pull the models volume
ces-pull a a ghcr.io/smartdatafoundry/ollama-models:latest

# Create models container
podman create --name ollama-models ghcr.io/smartdatafoundry/ollama-models:latest

# Start Ollama with models
podman run -d \
  --name ollama \
  --restart unless-stopped \
  --volumes-from ollama-models \
  -p 11434:11434 \
  -e http_proxy \
  -e https_proxy \
  -e no_proxy \
  ghcr.io/smartdatafoundry/ollama:latest

# Verify
podman exec ollama ollama list
```

### Kubernetes/OpenShift

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ollama-with-models
spec:
  initContainers:
  - name: load-models
    image: ghcr.io/smartdatafoundry/ollama-models:latest
    volumeMounts:
    - name: models
      mountPath: /root/.ollama
    command: ["sh", "-c", "cp -r /root/.ollama/* /dest/"]
    
  containers:
  - name: ollama
    image: ghcr.io/smartdatafoundry/ollama:latest
    ports:
    - containerPort: 11434
    volumeMounts:
    - name: models
      mountPath: /root/.ollama
      
  volumes:
  - name: models
    emptyDir: {}
```

## Available Models

### Default Models

The default build includes:

- **llama3.2**: Meta's Llama 3.2 (general purpose)
- **codellama**: Code-specialized variant of Llama
- **mistral**: Mistral 7B (efficient general purpose)

### Custom Model Lists

Build with any combination of models available in the [Ollama library](https://ollama.com/library):

```bash
# Specialized for coding
./scripts/build-ollama-volume.sh -m "codellama,deepseek-coder,starcoder2" -t "coding"

# Lightweight models
./scripts/build-ollama-volume.sh -m "phi,gemma:2b,qwen:1.8b" -t "lightweight"

# Large context models
./scripts/build-ollama-volume.sh -m "llama3.2:90b,mixtral:8x7b" -t "large"
```

### Model Size Considerations

| Model | Approximate Size | Use Case |
|-------|-----------------|----------|
| `phi` | ~1.6 GB | Testing, resource-constrained |
| `llama3.2` | ~4.7 GB | General purpose |
| `codellama` | ~3.8 GB | Code generation |
| `mistral` | ~4.1 GB | Efficient general purpose |
| `llama3.2:70b` | ~40 GB | High performance |

## Troubleshooting

### Build Issues

#### "Error: MODELS build arg is required"

Ensure you're passing the `MODELS` build argument:

```bash
./scripts/build-ollama-volume.sh -m "llama3.2"
```

#### Out of disk space

Models can be large. Check available space:

```bash
df -h

# Clean up unused Docker/Podman resources
docker system prune -a
podman system prune -a
```

#### Model pull timeout

Some models are large and may timeout. Increase timeout or use smaller models:

```bash
# Build with smaller models
./scripts/build-ollama-volume.sh -m "phi,gemma:2b"
```

### Runtime Issues

#### Models not available in Ollama

Verify the volume is properly mounted:

```bash
# Check if container exists
docker ps -a | grep ollama-models

# Inspect volume mounts
docker inspect ollama | grep -A 10 "Mounts"

# Check models in volume
docker run --rm --volumes-from ollama-models alpine ls -la /root/.ollama/models
```

#### Permission errors

Ensure proper ownership:

```bash
# Run Ollama as root or matching UID
docker run -d \
  --name ollama \
  --user root \
  --volumes-from ollama-models \
  -p 11434:11434 \
  ghcr.io/smartdatafoundry/ollama:latest
```

### Registry Issues

#### Authentication failed

Re-authenticate:

```bash
# Logout
docker logout ghcr.io

# Login with fresh token
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin
```

#### Rate limits

GitHub Container Registry has rate limits. Use authenticated pulls:

```bash
docker login ghcr.io
docker pull ghcr.io/smartdatafoundry/ollama-models:latest
```

## Best Practices

1. **Tag strategy**: Use specific tags for reproducibility
   ```bash
   # Good - pinned version
   ghcr.io/smartdatafoundry/ollama-models:models-a1b2c3d4
   
   # Caution - may change
   ghcr.io/smartdatafoundry/ollama-models:latest
   ```

2. **Build for your use case**: Create specialized volumes
   ```bash
   # Development
   ./scripts/build-ollama-volume.sh -m "codellama,phi" -t "dev"
   
   # Production
   ./scripts/build-ollama-volume.sh -m "llama3.2:70b" -t "prod"
   ```

3. **Verify after build**: Always test models are accessible
   ```bash
   docker exec ollama ollama list
   docker exec ollama ollama run llama3.2 "Hello, world!"
   ```

4. **Monitor size**: Keep track of image sizes
   ```bash
   docker images ghcr.io/smartdatafoundry/ollama-models
   ```

## Resources

- [Ollama Documentation](https://github.com/ollama/ollama)
- [Ollama Model Library](https://ollama.com/library)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Dev Containers Specification](https://containers.dev)

## Contributing

To add or modify models in the default build:

1. Edit `.github/workflows/build-ollama-models.yml`
2. Update the default `MODELS` value
3. Submit a pull request
4. Wait for automated build and tests

## License

MIT License - See [LICENSE](../LICENSE) for details.
