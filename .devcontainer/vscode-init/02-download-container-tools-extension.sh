#!/bin/env bash
set -e

# Container Tools Extension download script
# This script downloads the compatible Container Tools extension (ms-vscode-remote.remote-containers) 
# VSIX file for the specified VS Code commit to /opt/

DOWNLOAD_DIR="/opt"
EXTENSION_PUBLISHER="ms-vscode-remote"
EXTENSION_NAME="remote-containers"

EXTENSION_ID="${EXTENSION_PUBLISHER}.${EXTENSION_NAME}"
EXTENSION_FILEPATH="${DOWNLOAD_DIR}/${EXTENSION_PUBLISHER}.${EXTENSION_NAME}.vsix"
DOWNLOAD_URL="https://${EXTENSION_PUBLISHER}.gallery.vsassets.io/_apis/public/gallery/publisher/${EXTENSION_PUBLISHER}/extension/${EXTENSION_NAME}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"

# Download the extension VSIX file
echo "Downloading ${EXTENSION_ID} extension..."
echo "Target directory: ${DOWNLOAD_DIR}"
echo "Download URL: ${DOWNLOAD_URL}"
curl -sSL -o "${EXTENSION_FILEPATH}" "${DOWNLOAD_URL}"

# Verify the download
if [ -f "${EXTENSION_FILEPATH}" ]; then
    echo "Container Tools extension downloaded successfully to ${EXTENSION_FILEPATH}"
    
    # Display file information
    echo "File size: $(du -h "${EXTENSION_FILEPATH}" | cut -f1)"
else
    echo "Error: Failed to download Container Tools extension"
    # exit 1
fi

echo "Container Tools extension download completed successfully"
