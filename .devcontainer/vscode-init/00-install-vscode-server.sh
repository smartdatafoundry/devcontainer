#!/bin/bash
set -e

# VS Code Server installation script
# This script downloads and installs the VS Code server for the specified commit

VSCODE_COMMIT=${1:-"7adae6a56e34cb64d08899664b814cf620465925"}
VSCODE_SERVER_HOME="/root/.vscode-server/bin/${VSCODE_COMMIT}"

echo "Installing VS Code server for commit: ${VSCODE_COMMIT}"

# Download VS Code server
curl -sSL "https://update.code.visualstudio.com/commit:${VSCODE_COMMIT}/server-linux-x64/stable" -o vscode-server-linux-x64.tar.gz

# Create directory structure
mkdir -p "${VSCODE_SERVER_HOME}"

# Extract the server
tar -xzf vscode-server-linux-x64.tar.gz --strip-components=1 -C "${VSCODE_SERVER_HOME}"

# Clean up
rm -rf vscode-server-linux-x64.tar.gz

echo "VS Code server installation completed successfully"
