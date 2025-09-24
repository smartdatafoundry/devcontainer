FROM mcr.microsoft.com/devcontainers/base:noble

# VS Code commit ID for devcontainer compatibility, argument supplied at build time via devcontainer.json
ARG VSCODE_COMMIT

# Copy and run VS Code installation files
COPY ./vscode-init /opt/vscode-init
RUN cd /opt/vscode-init \ 
    && ./00-install-vscode-server.sh ${VSCODE_COMMIT} \
    && ./01-install-vscode-extensions.sh ${VSCODE_COMMIT} \
    && ./02-download-container-tools-extension.sh

WORKDIR /workspace

USER root
