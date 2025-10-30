FROM mcr.microsoft.com/devcontainers/base:noble

# VS Code commit ID for devcontainer compatibility. Can be overridden at build time via build args.
# Default chosen for current stable VS Code Server version used in this repository.
ARG VSCODE_COMMIT=385651c938df8a906869babee516bffd0ddb9829

ENV VSCODE_COMMIT=${VSCODE_COMMIT}

# Copy and run VS Code installation files
COPY ./vscode-init /opt/vscode-init

# Copy Codex config
COPY ./codex-config.toml /root/.codex/config.toml

# Copy Continue Dev config
COPY ./continue-config.yaml /root/.continue/config.toml
COPY ./continue.env /root/.continue/.env

RUN cd /opt/vscode-init \ 
    && ./00-install-vscode-server.sh ${VSCODE_COMMIT} \
    && ./01-install-extensions.sh ${VSCODE_COMMIT} \
    && ./02-download-extensions.sh

WORKDIR /workspace

USER root
