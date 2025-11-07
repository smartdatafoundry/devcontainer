#!/bin/env bash
set -e

# VS Code Extensions installation script
# This script installs VS Code extensions from vscode-extensions.txt

VSCODE_COMMIT=${1:-"7adae6a56e34cb64d08899664b814cf620465925"}
VSCODE_SERVER_HOME="/root/.vscode-server/bin/${VSCODE_COMMIT}"
EXTENSIONS_FILE="extensions-to-install.txt"

# Check if VS Code server is installed
if [ ! -f "${VSCODE_SERVER_HOME}/bin/code-server" ]; then
    echo "Error: VS Code server not found at ${VSCODE_SERVER_HOME}/bin/code-server"
    echo "Please run install-vscode-server.sh first"
    exit 1
fi

# Check if extensions file exists
if [ ! -f "${EXTENSIONS_FILE}" ]; then
    echo "Error: Extensions file not found at ${EXTENSIONS_FILE}"
    exit 1
fi

echo "Installing VS Code extensions from ${EXTENSIONS_FILE}..."

# Read extensions from file, remove comments and empty lines, then install all at once
extensions=$(grep -v '^#' "${EXTENSIONS_FILE}" | grep -v '^$' | tr -d '\r')

if [ -z "${extensions}" ]; then
    echo "No extensions found in ${EXTENSIONS_FILE}"
    exit 0
fi

echo "Extensions to install: ${extensions}"

# Install all extensions in a single command
"${VSCODE_SERVER_HOME}/bin/code-server" --accept-server-license-terms $(echo "${extensions}" | sed 's/^/--install-extension /' | tr '\n' ' ')

echo "VS Code extensions installation completed successfully"

# List installed extensions
echo ""
echo "Currently installed extensions:"
"${VSCODE_SERVER_HOME}/bin/code-server" --list-extensions
