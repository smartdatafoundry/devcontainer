FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:noble

# VS Code commit ID for devcontainer compatibility. Can be overridden at build time via build args.
# Default chosen for current stable VS Code Server version used in this repository.
ARG VSCODE_COMMIT=1e3c50d64110be466c0b4a45222e81d2c9352888

ENV VSCODE_COMMIT=${VSCODE_COMMIT}

# Copy and run VS Code installation files
COPY .devcontainer/vscode-init /opt/vscode-init

# Copy Qwen settings
COPY .devcontainer/qwen-settings.json /root/.qwen/settings.json

# Copy Codex config
COPY .devcontainer/codex-config.toml /root/.codex/config.toml

# Copy Continue Dev config
COPY .devcontainer/continue-config.yaml /root/.continue/config.yaml
COPY .devcontainer/continue.env /root/.continue/.env

# Copy scripts folder to /opt/scripts (accessible at runtime)
COPY scripts /opt/scripts

RUN cd /opt/vscode-init \ 
    && ./00-install-vscode-server.sh ${VSCODE_COMMIT} \
    && ./01-install-extensions.sh ${VSCODE_COMMIT} \
    && ./02-download-extensions.sh

WORKDIR /workspace

USER root
