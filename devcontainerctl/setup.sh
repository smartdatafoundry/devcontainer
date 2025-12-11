#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}DevContainer Setup Script${NC}"
echo "================================"

# Define files & paths
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SCRIPT_SOURCE="$SCRIPT_DIR/devcontainerctl"
SYMLINK_TARGET="$HOME/bin/devcontainerctl"
CRON_COMMAND="0 8 * * * $SYMLINK_TARGET sync"
EXTENSION_FILE="/safe_data/shared/vscode-extensions/ms-vscode-remote.remote-containers.vsix"

# Check if source script exists
if [ ! -f "$SCRIPT_SOURCE" ]; then
    echo -e "${RED}Error: Source script not found at $SCRIPT_SOURCE${NC}"
    exit 1
fi

# Install VS Code remote containers extensions if code command is available
if command -v code >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing VS Code remote containers extension...${NC}"
    code --install-extension $EXTENSION_FILE || {
        echo -e "${RED}Failed to install remote containers extension${NC}"
        exit 1
    }
else
    echo -e "${RED}VS Code command 'code' not found. Skipping extension installation.${NC}"
    exit 1
fi

# Create ~/bin directory if it doesn't exist
if [ ! -d "$HOME/bin" ]; then
    echo -e "${YELLOW}Creating $HOME/bin directory...${NC}"
    mkdir -p "$HOME/bin"
fi

# Create symlink
if [ -L "$SYMLINK_TARGET" ]; then
    echo -e "${YELLOW}Symlink already exists at $SYMLINK_TARGET${NC}"
    echo -e "${YELLOW}Removing old symlink...${NC}"
    rm "$SYMLINK_TARGET"
fi

echo -e "${GREEN}Creating symlink: $SYMLINK_TARGET -> $SCRIPT_SOURCE${NC}"
ln -s "$SCRIPT_SOURCE" "$SYMLINK_TARGET"

# Make sure the source script is executable
if [ ! -x "$SCRIPT_SOURCE" ]; then
    echo -e "${YELLOW}Warning: $SCRIPT_SOURCE is not executable${NC}"
    echo -e "${YELLOW}You may need to run: sudo chmod +x $SCRIPT_SOURCE${NC}"
fi

# Add ~/bin to PATH if not already present
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo -e "${YELLOW}Adding $HOME/bin to PATH in ~/.bashrc${NC}"
    echo '' >> "$HOME/.bashrc"
    echo '# Added by devcontainer setup' >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    echo -e "${GREEN}Please run: source ~/.bashrc${NC}"
fi

# Configure cron job
echo -e "${GREEN}Configuring cron job...${NC}"

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "devcontainerctl sync"; then
    echo -e "${YELLOW}Cron job already exists. Removing old entry...${NC}"
    crontab -l 2>/dev/null | grep -v "devcontainerctl sync" | crontab -
fi

# Add new cron job
(crontab -l 2>/dev/null; echo "$CRON_COMMAND") | crontab -

echo -e "${GREEN}Cron job added successfully!${NC}"
echo "Schedule: Daily at 8:00 AM"
echo "Command: $CRON_COMMAND"

# Verify installation
echo ""
echo "================================"
echo -e "${GREEN}Setup Complete!${NC}"
echo ""
echo -e "${GREEN}Verification:${NC}"
echo -e "${GREEN}  Symlink: $(ls -la $SYMLINK_TARGET 2>/dev/null || echo 'Not found')${NC}"
echo -e "${GREEN}  Cron job:${NC}"
crontab -l | grep "devcontainerctl sync" || echo -e "${GREEN}  Not found${NC}"
echo ""
echo -e "${YELLOW}Note: You may need to restart your shell or run 'source ~/.bashrc'${NC}"