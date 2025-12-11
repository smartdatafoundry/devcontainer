#!/bin/env bash
set -e

# Some extensions are for the system VS Code, e.g. Dev Containers.
# Because installed extensions are enabled by default, and an extension
# like e.g. VS Code Vim would be disruptive to most users, we can
# download them instead. Then it is up to the user to extract and
# install the extension into their system VS Code in the TRE.
# In some cases, such as for VS Code Vim, the system VS Code install
# of the extension and its functionality gets inherited by devcontainers.

EXTENSIONS_FILE="extensions-to-download.txt"
DOWNLOAD_DIR=${1:-"/opt/vscode-extensions"}
SUCCESSFUL_DOWNLOADS=()

mkdir -p "${DOWNLOAD_DIR}"

if [ ! -f "${EXTENSIONS_FILE}" ]; then
    echo "Error: Extensions file not found at ${EXTENSIONS_FILE}"
    exit 1
fi

echo ""
echo "Reading extensions from: ${EXTENSIONS_FILE}"
echo "Target directory: ${DOWNLOAD_DIR}"
echo ""

download_extension() {
    local extension_id="$1"

    # Skip empty lines and comments
    if [[ -z "$extension_id" || "$extension_id" =~ ^[[:space:]]*# ]]; then
        return 0
    fi
    
    # Example of valid ID: publisher-name.extension-name
    if [[ "$extension_id" != *.* ]]; then
        echo "Invalid extension ID format '$extension_id' - check for typos"
        exit 1
    fi
    
    local publisher="${extension_id%.*}"
    local extension_name="${extension_id#*.}"
    
    local extension_filepath="${DOWNLOAD_DIR}/${extension_id}.vsix"

    # We first need to lookup releases to find the latest version and architecture to download URL
    local download_url="$(curl -sSL https://marketplace.visualstudio.com/_apis/public/gallery/vscode/${publisher}/${extension_name}/latest \
      | jq -r '.versions[] | select(.targetPlatform == "linux-x64" or .targetPlatform == null) | select(.flags | contains("prerelease") | not) | .files[] | select(.assetType == "Microsoft.VisualStudio.Services.VSIXPackage") | .source' | head -n1)"
    
    echo "Downloading ${extension_id}..."
    
    if curl -sSL -o "${extension_filepath}" "${download_url}"; then
        if [ -f "${extension_filepath}" ] && [ -s "${extension_filepath}" ]; then
            if [ "$(cat "${extension_filepath}" | jq -r '.typeKey' 2>/dev/null)" = "ExtensionDoesNotExistException" ]; then
                echo "  ✗ Download failed: $extension_id does not exist"
                echo "Response from Microsoft:"
                cat "${extension_filepath}" | jq .
                exit 1
            fi
        fi
        
        if [ -f "${extension_filepath}" ] && [ -s "${extension_filepath}" ]; then
            echo "  ✓ Downloaded successfully ($(du -h "${extension_filepath}" | cut -f1))"
            SUCCESSFUL_DOWNLOADS+=("$extension_id")
        else
            echo "  ✗ Download failed - file is empty or missing"
            [ -f "${extension_filepath}" ] && rm -f "${extension_filepath}"
            exit 1
        fi
    else
        echo "  ✗ Download failed - curl error"
        [ -f "${extension_filepath}" ] && rm -f "${extension_filepath}"
        exit 1
    fi
}

# Read and process each extension
while IFS= read -r extension_id || [ -n "$extension_id" ]; do
    # Remove leading/trailing whitespace
    extension_id=$(echo "$extension_id" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    download_extension "$extension_id"
done < "${EXTENSIONS_FILE}"

if [ ${#SUCCESSFUL_DOWNLOADS[@]} -eq 0 ]; then
    echo "No extensions found in ${EXTENSIONS_FILE}."
    echo ""
else
    echo "All extensions downloaded successfully:"
    printf "  ✓ %s\n" "${SUCCESSFUL_DOWNLOADS[@]}"
    echo ""
fi
