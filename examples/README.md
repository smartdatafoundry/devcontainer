# Ollama Models Volume Examples

This directory contains examples for using the Ollama models data volume in different scenarios.

## Quick Start

The fastest way to get started with Ollama and pre-loaded models:

```bash
# Run the quick start script
./quick-start-ollama.sh
```

This script will:
1. Pull the models data volume image
2. Create a models container
3. Pull and start Ollama with the pre-loaded models
4. Verify everything is working
5. Provide usage instructions

## Examples

### 1. Quick Start Script

**File:** `quick-start-ollama.sh`

Automated setup script that configures Ollama with pre-loaded models.

```bash
./quick-start-ollama.sh
```

Works with both Docker and Podman, automatically detects which is available.

### 2. Docker Compose

**File:** `docker-compose.ollama.yml`

Complete Docker Compose setup with Ollama, models, and development container.

```bash
# Start all services
docker-compose -f docker-compose.ollama.yml up -d

# List available models
docker-compose -f docker-compose.ollama.yml exec ollama ollama list

# Access development container
docker-compose -f docker-compose.ollama.yml exec devcontainer bash

# Stop all services
docker-compose -f docker-compose.ollama.yml down
```

### 3. Dev Container Configuration

**Directory:** `.devcontainer/`

Complete Dev Container configuration for VS Code with Ollama integration.

To use:
1. Copy `.devcontainer/` to your project root
2. Open project in VS Code
3. Select "Reopen in Container"
4. Models will be automatically available

The configuration includes:
- Ollama service with pre-loaded models
- Development container with Ollama access
- Continue extension for AI-assisted coding
- Port forwarding for Ollama API

## Usage Patterns

### Pattern 1: Data Volume Container

Use the models image as a data volume:

```bash
# Create models container
docker create --name ollama-models ghcr.io/smartdatafoundry/ollama-models:latest

# Run Ollama with models
docker run -d \
  --name ollama \
  --volumes-from ollama-models \
  -p 11434:11434 \
  ghcr.io/smartdatafoundry/ollama:latest
```

### Pattern 2: Named Volume

Extract models to a named volume:

```bash
# Create volume
docker volume create ollama-models

# Extract models
docker run --rm \
  -v ollama-models:/dest \
  ghcr.io/smartdatafoundry/ollama-models:latest \
  sh -c "cp -r /root/.ollama/* /dest/"

# Use volume
docker run -d \
  --name ollama \
  -v ollama-models:/root/.ollama \
  -p 11434:11434 \
  ghcr.io/smartdatafoundry/ollama:latest
```

### Pattern 3: Docker Compose

Use the provided `docker-compose.ollama.yml` for multi-container setup.

### Pattern 4: Dev Container

Use the `.devcontainer/` configuration for VS Code integration.

## Testing Models

After setup, test that models are available:

```bash
# List models
curl http://localhost:11434/api/tags

# Run a model
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Hello, world!",
  "stream": false
}'

# Interactive chat
docker exec -it ollama ollama run llama3.2
```

## Environment-Specific Examples

### Local Development

Use the quick start script or Docker Compose:

```bash
./quick-start-ollama.sh
```

### SDF TRE

In restricted environments with `ces-pull`:

```bash
# Pull models volume
ces-pull a a ghcr.io/smartdatafoundry/ollama-models:latest

# Create and start
podman create --name ollama-models ghcr.io/smartdatafoundry/ollama-models:latest
podman run -d \
  --name ollama \
  --restart unless-stopped \
  --volumes-from ollama-models \
  -p 11434:11434 \
  -e http_proxy \
  -e https_proxy \
  -e no_proxy \
  ghcr.io/smartdatafoundry/ollama:latest
```

### Kubernetes/OpenShift

See the Kubernetes example in the main documentation: [docs/OLLAMA_MODELS_VOLUME.md](../docs/OLLAMA_MODELS_VOLUME.md#kubernetesopenshift)

## Customization

### Using Different Models

Build a custom models volume with specific models:

```bash
# From repository root
./scripts/build-ollama-volume.sh -m "codellama,mistral,phi" -t "custom"
```

### Combining with Your Dev Container

Integrate Ollama into your existing dev container:

1. Add Ollama service to your `docker-compose.yml`:
   ```yaml
   ollama:
     image: ghcr.io/smartdatafoundry/ollama:latest
     volumes:
       - ollama-data:/root/.ollama
     ports:
       - "11434:11434"
   ```

2. Add models initialization:
   ```yaml
   ollama-models:
     image: ghcr.io/smartdatafoundry/ollama-models:latest
     volumes:
       - ollama-data:/root/.ollama
   ```

3. Update your dev container environment:
   ```json
   {
     "remoteEnv": {
       "OLLAMA_HOST": "http://ollama:11434"
     }
   }
   ```

## Troubleshooting

### Models not appearing

```bash
# Check models container exists
docker ps -a | grep ollama-models

# Verify volume has data
docker run --rm --volumes-from ollama-models alpine ls -la /root/.ollama/models

# Check Ollama logs
docker logs ollama
```

### Connection refused

```bash
# Ensure Ollama is running
docker ps | grep ollama

# Test connectivity
curl http://localhost:11434/api/tags

# Check port forwarding
docker port ollama
```

### Permission errors

```bash
# Run with appropriate user
docker run -d \
  --name ollama \
  --user $(id -u):$(id -g) \
  --volumes-from ollama-models \
  -p 11434:11434 \
  ghcr.io/smartdatafoundry/ollama:latest
```

## Resources

- [Main Ollama Documentation](../docs/OLLAMA_MODELS_VOLUME.md)
- [Ollama GitHub](https://github.com/ollama/ollama)
- [Ollama Model Library](https://ollama.com/library)
- [Dev Containers](https://containers.dev)

## Contributing

Have a useful example? Please submit a pull request!

## License

MIT License - See [LICENSE](../LICENSE)
