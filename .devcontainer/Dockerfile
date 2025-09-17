FROM mcr.microsoft.com/devcontainers/base:noble

ARG VSCODE_COMMIT=f220831ea2d946c0dcb0f3eaa480eb435a2c1260

# Copy and run VS Code installation files
COPY ./vscode-init /opt/vscode-init
RUN cd /opt/vscode-init \ 
    && ./00-install-vscode-server.sh ${VSCODE_COMMIT} \
    && ./01-install-vscode-extensions.sh ${VSCODE_COMMIT} \
    && ./02-download-container-tools-extension.sh

WORKDIR /workspace

USER root
