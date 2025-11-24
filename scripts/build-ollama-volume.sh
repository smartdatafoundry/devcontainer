#!/bin/bash
#
# build-ollama-volume.sh - Build and publish Ollama model data volume to GHCR
#
# This script creates a container image containing pre-pulled Ollama models,
# which can be used as a data volume to speed up model loading in environments
# where direct model pulling is restricted or slow.
#
# Usage:
#   ./build-ollama-volume.sh [OPTIONS]
#
# Options:
#   -m, --models MODEL[,MODEL...]  Comma-separated list of Ollama models to include
#                                  (e.g., "qwen3-coder:30b,nate/instinct,nomic-embed-text:v1.5")
#   -t, --tag TAG                  Tag for the container image (default: latest)
#   -r, --registry REGISTRY        Container registry (default: ghcr.io/smartdatafoundry)
#   -n, --name NAME                Image name (default: ollama-models)
#   -p, --push                     Push image to registry after build
#   -h, --help                     Display this help message
#
# Examples:
#   # Build with default models
#   ./build-ollama-volume.sh
#
#   # Build with specific models and push
#   ./build-ollama-volume.sh -m "llama3.2,codellama" -p
#
#   # Build with custom tag
#   ./build-ollama-volume.sh -m "mistral" -t "mistral-only" -p
#

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
DEFAULT_MODELS="llama3.2,codellama"
REGISTRY="ghcr.io/smartdatafoundry"
IMAGE_NAME="ollama-models"
TAG="latest"
PUSH_IMAGE=false
MODELS=""

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Build and publish Ollama model data volume to GHCR

Options:
    -m, --models MODEL[,MODEL...]  Comma-separated list of Ollama models to include
                                   (default: ${DEFAULT_MODELS})
    -t, --tag TAG                  Tag for the container image (default: ${TAG})
    -r, --registry REGISTRY        Container registry (default: ${REGISTRY})
    -n, --name NAME                Image name (default: ${IMAGE_NAME})
    -p, --push                     Push image to registry after build
    -h, --help                     Display this help message

Examples:
    # Build with default models
    $0

    # Build with specific models and push
    $0 -m "llama3.2,codellama" -p

    # Build with custom tag
    $0 -m "mistral" -t "mistral-only" -p

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--models)
            MODELS="$2"
            shift 2
            ;;
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        -n|--name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -p|--push)
            PUSH_IMAGE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Use default models if none specified
if [ -z "$MODELS" ]; then
    MODELS="$DEFAULT_MODELS"
fi

# Full image reference
FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}:${TAG}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Ollama Model Volume Builder${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Registry:${NC} ${REGISTRY}"
echo -e "${GREEN}Image:${NC} ${IMAGE_NAME}"
echo -e "${GREEN}Tag:${NC} ${TAG}"
echo -e "${GREEN}Models:${NC} ${MODELS}"
echo -e "${GREEN}Push:${NC} ${PUSH_IMAGE}"
echo -e "${BLUE}========================================${NC}\n"

# Create temporary directory for build context
BUILD_DIR=$(mktemp -d)
trap "rm -rf ${BUILD_DIR}" EXIT

echo -e "${YELLOW}Creating build context in ${BUILD_DIR}${NC}\n"

# Create Dockerfile
cat > "${BUILD_DIR}/Dockerfile" << 'EOF'
FROM --platform=linux/amd64 ghcr.io/smartdatafoundry/ollama:latest AS builder

# Install models
ARG MODELS
RUN if [ -z "$MODELS" ]; then \
        echo "Error: MODELS build arg is required" && exit 1; \
    fi && \
    # Start Ollama service in background
    /bin/ollama serve & \
    OLLAMA_PID=$! && \
    sleep 5 && \
    # Pull each model
    echo "$MODELS" | tr ',' '\n' | while read -r model; do \
        if [ -n "$model" ]; then \
            echo "Pulling model: $model" && \
            ollama pull "$model" || exit 1; \
        fi; \
    done && \
    # Stop Ollama service
    kill $OLLAMA_PID && \
    wait $OLLAMA_PID || true

# Create minimal data volume image
FROM scratch

# Copy models from builder
COPY --from=builder /root/.ollama /root/.ollama

# Add metadata
LABEL org.opencontainers.image.title="Ollama Models Data Volume"
LABEL org.opencontainers.image.description="Pre-pulled Ollama models for use as a data volume"
LABEL org.opencontainers.image.source="https://github.com/smartdatafoundry/devcontainer"
LABEL org.opencontainers.image.vendor="Smart Data Foundry"
LABEL models="${MODELS}"

# Volume mount point
VOLUME ["/root/.ollama"]

# Default command (won't actually run in scratch, but documents usage)
CMD ["Models available in /root/.ollama"]
EOF

# Create README for the image
cat > "${BUILD_DIR}/README.md" << EOF
# Ollama Models Data Volume

This container image contains pre-pulled Ollama models and is designed to be used as a data volume.

## Included Models

\`\`\`
${MODELS}
\`\`\`

## Usage

### Using with Docker/Podman

Mount this image as a volume to an Ollama container:

\`\`\`bash
# Create a container from the data volume image
docker create --name ollama-models ${FULL_IMAGE}

# Run Ollama with the models volume
docker run -d \\
    --name ollama \\
    --volumes-from ollama-models \\
    -p 11434:11434 \\
    ghcr.io/smartdatafoundry/ollama:latest
\`\`\`

### Using with Podman

\`\`\`bash
# Create a container from the data volume image
podman create --name ollama-models ${FULL_IMAGE}

# Run Ollama with the models volume
podman run -d \\
    --name ollama \\
    --volumes-from ollama-models \\
    -p 11434:11434 \\
    ghcr.io/smartdatafoundry/ollama:latest
\`\`\`

### Using in Dev Containers

Add to your \`.devcontainer/devcontainer.json\`:

\`\`\`json
{
  "name": "Development with Ollama",
  "dockerComposeFile": "docker-compose.yml",
  "service": "devcontainer",
  "workspaceFolder": "/workspace"
}
\`\`\`

And in \`.devcontainer/docker-compose.yml\`:

\`\`\`yaml
version: '3.8'

services:
  ollama-models:
    image: ${FULL_IMAGE}
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
      - ..:/workspace
    depends_on:
      - ollama
    environment:
      - OLLAMA_HOST=http://ollama:11434

volumes:
  ollama-data:
\`\`\`

## Verifying Models

After mounting the volume, verify models are available:

\`\`\`bash
docker exec ollama ollama list
\`\`\`

## Building

This image was built using:

\`\`\`bash
./scripts/build-ollama-volume.sh -m "${MODELS}" -t "${TAG}"
\`\`\`

## Registry

Published to: ${FULL_IMAGE}

EOF

# Build the container
echo -e "${YELLOW}Building container image...${NC}\n"

if command -v docker &> /dev/null; then
    CONTAINER_CMD="docker"
elif command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
else
    echo -e "${RED}Error: Neither docker nor podman found${NC}"
    exit 1
fi

echo -e "${BLUE}Using container runtime: ${CONTAINER_CMD}${NC}\n"

# Build with BuildKit/Buildah
${CONTAINER_CMD} build \
    --build-arg "MODELS=${MODELS}" \
    --tag "${FULL_IMAGE}" \
    --label "build.date=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --label "build.models=${MODELS}" \
    --label "build.tag=${TAG}" \
    "${BUILD_DIR}"

echo -e "\n${GREEN}✓ Build complete!${NC}\n"

# Show image info
echo -e "${BLUE}Image Information:${NC}"
${CONTAINER_CMD} images "${FULL_IMAGE}"
echo ""

# Push if requested
if [ "$PUSH_IMAGE" = true ]; then
    echo -e "${YELLOW}Pushing image to registry...${NC}\n"
    
    # Check if logged in (basic check)
    if ${CONTAINER_CMD} login ghcr.io --get-login &> /dev/null || \
       grep -q "ghcr.io" "${HOME}/.docker/config.json" 2>/dev/null || \
       grep -q "ghcr.io" "${XDG_RUNTIME_DIR}/containers/auth.json" 2>/dev/null; then
        ${CONTAINER_CMD} push "${FULL_IMAGE}"
        echo -e "\n${GREEN}✓ Image pushed successfully!${NC}\n"
        
        # Create additional tags
        echo -e "${BLUE}Creating additional tags...${NC}\n"
        
        # Tag with model list hash for unique identification
        MODEL_HASH=$(echo -n "${MODELS}" | sha256sum | cut -c1-8)
        MODEL_TAG="${REGISTRY}/${IMAGE_NAME}:models-${MODEL_HASH}"
        ${CONTAINER_CMD} tag "${FULL_IMAGE}" "${MODEL_TAG}"
        ${CONTAINER_CMD} push "${MODEL_TAG}"
        echo -e "${GREEN}✓ Also tagged as: ${MODEL_TAG}${NC}\n"
        
    else
        echo -e "${RED}Error: Not logged in to ${REGISTRY}${NC}"
        echo -e "${YELLOW}Please login first:${NC}"
        echo -e "  ${CONTAINER_CMD} login ghcr.io"
        exit 1
    fi
else
    echo -e "${YELLOW}Image built but not pushed (use -p to push)${NC}\n"
fi

# Print usage instructions
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Usage Instructions${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "\n${GREEN}Test locally:${NC}"
echo -e "  ${CONTAINER_CMD} create --name ollama-models ${FULL_IMAGE}"
echo -e "  ${CONTAINER_CMD} run -d --name ollama --volumes-from ollama-models -p 11434:11434 ghcr.io/smartdatafoundry/ollama:latest"
echo -e "  ${CONTAINER_CMD} exec ollama ollama list"

if [ "$PUSH_IMAGE" = true ]; then
    echo -e "\n${GREEN}Pull from registry:${NC}"
    echo -e "  ${CONTAINER_CMD} pull ${FULL_IMAGE}"
fi

echo -e "\n${GREEN}Available models in this volume:${NC}"
IFS=',' read -ra MODEL_ARRAY <<< "$MODELS"
for model in "${MODEL_ARRAY[@]}"; do
    echo -e "  • ${model}"
done

echo -e "\n${BLUE}========================================${NC}\n"
echo -e "${GREEN}✓ Done!${NC}\n"
