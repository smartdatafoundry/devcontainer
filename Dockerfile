FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:noble

# VS Code commit ID for devcontainer compatibility. Can be overridden at build time via build args.
# Default chosen for current stable VS Code Server version used in this repository.
ARG VSCODE_COMMIT=c9d77990917f3102ada88be140d28b038d1dd7c7

ENV VSCODE_COMMIT=${VSCODE_COMMIT}

# Copy custom scripts and installation files
COPY .devcontainer /opt/.devcontainer

# Copy devcontainerctl folder to /opt/devcontainerctl (accessible at runtime)
COPY devcontainerctl /opt/devcontainerctl

# Run VS Code installation files & copy configurations
RUN cd /opt/.devcontainer/vscode-init \ 
    && /opt/.devcontainer/vscode-init/00-install-vscode-server.sh ${VSCODE_COMMIT} \
    && /opt/.devcontainer/vscode-init/01-install-extensions.sh ${VSCODE_COMMIT} \
    && /opt/.devcontainer/vscode-init/02-download-extensions.sh /opt/vscode-extensions \
    && mkdir -p /root/.qwen && cp /opt/.devcontainer/qwen-settings.json /root/.qwen/settings.json \
    && mkdir -p /root/.codex && cp /opt/.devcontainer/codex-config.toml /root/.codex/config.toml \
    && mkdir -p /root/.continue && cp /opt/.devcontainer/continue-config.yaml /root/.continue/config.yaml \
    && cp /opt/.devcontainer/continue.env /root/.continue/.env

WORKDIR /workspace

USER root
