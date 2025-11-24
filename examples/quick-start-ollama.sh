#!/bin/bash
#
# quick-start-ollama.sh - Quick start script for Ollama with pre-loaded models
#
# This script sets up Ollama with pre-pulled models using the data volume approach.
# It's designed to work in both local Docker/Podman environments and SDF TRE.
#

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
MODELS_IMAGE="ghcr.io/smartdatafoundry/ollama-models:latest"
OLLAMA_IMAGE="ghcr.io/smartdatafoundry/ollama:latest"
MODELS_CONTAINER="ollama-models"
OLLAMA_CONTAINER="ollama"
OLLAMA_PORT="11434"

# Detect container runtime
if command -v docker &> /dev/null; then
    RUNTIME="docker"
elif command -v podman &> /dev/null; then
    RUNTIME="podman"
else
    echo -e "${RED}Error: Neither docker nor podman found${NC}"
    echo "Please install Docker or Podman first"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Ollama Quick Start${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Container runtime:${NC} ${RUNTIME}"
echo -e "${BLUE}========================================${NC}\n"

# Function to check if a container exists
container_exists() {
    ${RUNTIME} ps -a --format '{{.Names}}' | grep -q "^${1}$"
}

# Function to check if a container is running
container_running() {
    ${RUNTIME} ps --format '{{.Names}}' | grep -q "^${1}$"
}

# Step 1: Pull the models image
echo -e "${YELLOW}Step 1: Pulling Ollama models image...${NC}"
if ${RUNTIME} pull "${MODELS_IMAGE}"; then
    echo -e "${GREEN}✓ Models image pulled successfully${NC}\n"
else
    echo -e "${RED}✗ Failed to pull models image${NC}"
    echo "If you're in a restricted environment, you may need to use ces-pull or similar"
    exit 1
fi

# Step 2: Create models container if it doesn't exist
echo -e "${YELLOW}Step 2: Setting up models container...${NC}"
if container_exists "${MODELS_CONTAINER}"; then
    echo -e "${YELLOW}Models container already exists${NC}"
else
    if ${RUNTIME} create --name "${MODELS_CONTAINER}" "${MODELS_IMAGE}"; then
        echo -e "${GREEN}✓ Models container created${NC}"
    else
        echo -e "${RED}✗ Failed to create models container${NC}"
        exit 1
    fi
fi
echo ""

# Step 3: Pull Ollama image
echo -e "${YELLOW}Step 3: Pulling Ollama image...${NC}"
if ${RUNTIME} pull "${OLLAMA_IMAGE}"; then
    echo -e "${GREEN}✓ Ollama image pulled successfully${NC}\n"
else
    echo -e "${RED}✗ Failed to pull Ollama image${NC}"
    exit 1
fi

# Step 4: Start Ollama with models
echo -e "${YELLOW}Step 4: Starting Ollama service...${NC}"

# Stop and remove existing Ollama container if it exists
if container_exists "${OLLAMA_CONTAINER}"; then
    echo -e "${YELLOW}Stopping existing Ollama container...${NC}"
    ${RUNTIME} stop "${OLLAMA_CONTAINER}" 2>/dev/null || true
    ${RUNTIME} rm "${OLLAMA_CONTAINER}" 2>/dev/null || true
fi

# Start new Ollama container
if ${RUNTIME} run -d \
    --name "${OLLAMA_CONTAINER}" \
    --restart unless-stopped \
    --volumes-from "${MODELS_CONTAINER}" \
    -p "${OLLAMA_PORT}:${OLLAMA_PORT}" \
    -e http_proxy \
    -e https_proxy \
    -e no_proxy \
    "${OLLAMA_IMAGE}"; then
    echo -e "${GREEN}✓ Ollama service started${NC}\n"
else
    echo -e "${RED}✗ Failed to start Ollama service${NC}"
    exit 1
fi

# Step 5: Wait for Ollama to be ready
echo -e "${YELLOW}Step 5: Waiting for Ollama to be ready...${NC}"
RETRY_COUNT=0
MAX_RETRIES=30
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if ${RUNTIME} exec "${OLLAMA_CONTAINER}" curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Ollama is ready${NC}\n"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo -n "."
    sleep 1
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo -e "\n${RED}✗ Timeout waiting for Ollama to start${NC}"
    echo "Check logs: ${RUNTIME} logs ${OLLAMA_CONTAINER}"
    exit 1
fi

# Step 6: Verify models
echo -e "${YELLOW}Step 6: Verifying available models...${NC}"
echo -e "${BLUE}Available models:${NC}"
${RUNTIME} exec "${OLLAMA_CONTAINER}" ollama list
echo ""

# Step 7: Test a model
echo -e "${YELLOW}Step 7: Testing model...${NC}"
TEST_RESPONSE=$(${RUNTIME} exec "${OLLAMA_CONTAINER}" ollama run llama3.2 "Say 'Hello, Ollama is working!'" 2>/dev/null || echo "Test failed")
echo -e "${BLUE}Test response:${NC}"
echo "${TEST_RESPONSE}"
echo ""

# Success summary
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Ollama setup complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Access Information:${NC}"
echo -e "  API URL: ${BLUE}http://localhost:${OLLAMA_PORT}${NC}"
echo -e "  Container: ${BLUE}${OLLAMA_CONTAINER}${NC}"
echo ""
echo -e "${GREEN}Useful Commands:${NC}"
echo -e "  List models:         ${BLUE}${RUNTIME} exec ${OLLAMA_CONTAINER} ollama list${NC}"
echo -e "  Run a model:         ${BLUE}${RUNTIME} exec ${OLLAMA_CONTAINER} ollama run llama3.2${NC}"
echo -e "  Check status:        ${BLUE}${RUNTIME} ps | grep ${OLLAMA_CONTAINER}${NC}"
echo -e "  View logs:           ${BLUE}${RUNTIME} logs ${OLLAMA_CONTAINER}${NC}"
echo -e "  Stop Ollama:         ${BLUE}${RUNTIME} stop ${OLLAMA_CONTAINER}${NC}"
echo -e "  Start Ollama:        ${BLUE}${RUNTIME} start ${OLLAMA_CONTAINER}${NC}"
echo -e "  Remove everything:   ${BLUE}${RUNTIME} rm -f ${OLLAMA_CONTAINER} ${MODELS_CONTAINER}${NC}"
echo ""
echo -e "${GREEN}Test with curl:${NC}"
echo -e "  ${BLUE}curl http://localhost:${OLLAMA_PORT}/api/tags${NC}"
echo ""
echo -e "${BLUE}========================================${NC}\n"
