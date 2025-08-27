FROM mcr.microsoft.com/devcontainers/base:noble

ARG VSCODE_COMMIT=7adae6a56e34cb64d08899664b814cf620465925

# Copy and run VS Code installation files
COPY ./vscode-init /opt/vscode-init
RUN cd /opt/vscode-init \ 
    && ./00-install-vscode-server.sh ${VSCODE_COMMIT} \
    && ./01-install-vscode-extensions.sh ${VSCODE_COMMIT} \
    && ./02-download-container-tools-extension.sh

WORKDIR /workspace

USER root