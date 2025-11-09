# Setting up Dev Containers in the SDF Trusted Research Environment

This guide provides step-by-step instructions for setting up and using dev containers within the SDF Trusted Research Environment (TRE).

## Quick Start

### Automated Setup (Recommended)

For users who want the fastest setup with automatic updates:

```bash
# 1. Pull the devcontainer image
ces-pull a a ghcr.io/smartdatafoundry/devcontainer:latest

# 2. Extract the setup scripts
podman run --rm -v $HOME:$HOME -w $HOME \
  ghcr.io/smartdatafoundry/devcontainer:latest \
  cp -r /workspace/scripts $HOME/devcontainer-scripts

# 3. Run the one-time setup
cd $HOME/devcontainer-scripts
./setup.sh

# 4. Start your devcontainer
devcontainerctl start
```

See the "Using the Setup Scripts" section below for details.

### Manual Setup

For users who prefer manual control or are setting this up for the first time:

1. Pull the devcontainer image
2. Extract and install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
3. Create your project directory
4. Add project config file `.devcontainer/devcontainer.json`
5. Open the project in VS Code
6. Open in Container
   1. Option A: Click "Reopen in Container" when prompted by VS Code
   2. Option B: Open Command Palette (`Ctrl+Shift+P`) and run "Dev Containers: Reopen in Container"
7. Wait for container to start
8. Do your work

See the sections below for detailed instructions.

## Using the Setup Scripts (Recommended)

The devcontainer includes scripts that automate deployment and management in the TRE environment.

### One-Time Setup

After extracting the scripts (see Quick Start above), run the setup script:

```bash
cd $HOME/devcontainer-scripts
./setup.sh
```

This script will:
- Create `~/bin` directory if it doesn't exist
- Create a symlink to `devcontainerctl` in `~/bin`
- Add `~/bin` to your PATH (in `~/.bashrc`)
- Configure a daily cron job (8:00 AM) to keep your image updated

After running the setup, either restart your terminal or run:
```bash
source ~/.bashrc
```

### Daily Usage

Once setup is complete, you can use the `devcontainerctl` command:

```bash
# Start your devcontainer (pulls latest matching image if needed)
devcontainerctl start

# Check status
devcontainerctl status

# Stop the container
devcontainerctl stop

# Restart the container
devcontainerctl restart

# Update to latest image and restart
devcontainerctl update

# Remove the container completely
devcontainerctl remove
```

### Automatic Features

The setup provides several automatic features:

1. **Daily Updates**: A cron job runs at 8:00 AM daily to sync your container image with the latest version matching your VS Code installation

2. **VS Code Tag Alignment**: The `devcontainerctl start` command automatically detects your installed VS Code version and pulls the matching container image tag (e.g., `vscode-abc1234`)

3. **Automatic Mounting**: Your home directory and `/safe_data` are automatically mounted when the container starts

4. **Proxy Configuration**: HTTP proxy settings are inherited from your environment automatically

## Prerequisites

Verify you have access to `ces-pull` and Podman within your TRE workspace.

```bash
which ces-pull
# Should respond with the path to the command
# e.g. /usr/local/bin/ces-pull

which podman
# Should respond with the path to the command
# e.g. /usr/bin/podman
```

## Configure VS Code

Before using dev containers in the SDF Trusted Research Environment, you need to obtain the container image and manually install the Dev Containers extension in VS Code:

### 1. Pull the Devcontainer Image

Pull the latest devcontainer image using the CES (Container Execution Service):

```bash
ces-pull a a ghcr.io/smartdatafoundry/devcontainer:latest
```

### 2. Extract the Dev Containers Extension

The Dev Containers extension VSIX is baked into the image for offline / restricted environments. Extract it:

```bash
podman run --rm -it \
  -v $PWD:$PWD \
  -w $PWD \
  ghcr.io/smartdatafoundry/devcontainer:latest \
  cp /opt/ms-vscode-remote.remote-containers.vsix .
```

### 3. Install the Extension

#### Option A: Via Command Line

```bash
code --install-extension ms-vscode-remote.remote-containers.vsix
```

#### Option B: Via VS Code Interface

- Open VS Code in your TRE environment
- Go to the Extensions tab
- Click on the 3-dot menu (⋯) in the Extensions panel
- Select "Install from VSIX..."
- Choose the `ms-vscode-remote.remote-containers.vsix` file you extracted

### 4. Configure VS Code for Podman

Add to your VS Code `settings.json` to configure Podman as the container runtime:

- Open VS Code
- Press `Ctrl+,` to open Settings
- Click the "Open Settings (JSON)" icon in the top-right corner
- Add the following configuration:

```json
{
    "dev.containers.dockerPath": "podman"
}
```

You now have the container image available and VS Code setup to be able to use it.

## Project configuration file

Whenever you want to use the devcontainer for a project, you will need to create a configuration file. This is a one-time setup per project.

Create a `.devcontainer/devcontainer.json` file in your project root:

```json
{
  "name": "Development Container",
  "image": "ghcr.io/smartdatafoundry/devcontainer:latest",

  "mounts": [
    "source=/safe_data,target=/safe_data,type=bind,consistency=cached",
    "type=tmpfs,target=/tmp"
  ],

  "runArgs": [
    "--userns=host",
    "-e HTTP_PROXY",
    "-e HTTPS_PROXY"
  ],

  "remoteUser": "root"
}
```

After creating this file you can reopen the project in VS Code using the Dev Containers extension.

### Configuration Explanation

- **`mounts`**:
  - Binds the `/safe_data` directory for access to project data
  - Creates a temporary filesystem for `/tmp` for TRE compatibility
  
- **`runArgs`**:
  - `--userns=host`: Uses the host user namespace for TRE compatibility
  - `-e HTTP_PROXY` and `-e HTTPS_PROXY`: **Essential** for `pip` and network calls to work within the TRE. These inherit proxy credentials from your TRE environment
  
- **`remoteUser`**: Set to `root` for TRE compatibility

## How It Works

When you create the devcontainer configuration:

1. VS Code will prompt you to "Reopen in Container"
2. Docker/Podman fires up the container and connects VS Code to it
3. Your project directory is automatically mounted into the container
4. Any changes made inside the container are preserved in your project files outside the container
5. This avoids the "chicken and egg" problem of having source code baked into containers

This approach leverages container technology directly while maintaining the ability to modify and iterate on your code seamlessly.

## Advanced Configuration

### VS Code Server Version Management

The container ships with VS Code Server pre-installed. To ensure reproducibility or to match an existing TRE host version, specify the commit hash:

1. Check your TRE VS Code version via _Help > About_
2. The VS Code commit value is declared in the [`Dockerfile`](../Dockerfile) and can be overridden via workflow inputs.

## Troubleshooting

### Extension Not Found

If you can't see "Dev Containers" in the VS Code command palette:

- Ensure you've followed the manual extension installation steps above
- Restart VS Code after installing the extension
- Check that the extension is enabled in the Extensions panel

### Container Runtime Issues

- If you get Docker-related errors, ensure VS Code is configured to use podman: `"dev.containers.dockerPath": "podman"`
- If you get "Error: reading blob" or "500 Internal Server Error" when pulling images:
  - Try using a different TRE workspace
  - Contact TRE support if the issue persists
  - Some workspaces may have image access restrictions

### Network Issues

If you experience network-related delays:

- Ensure your proxy settings are correctly configured in the `runArgs` (HTTP_PROXY and HTTPS_PROXY are essential)
- File system responsiveness may vary depending on TRE network conditions

### Script Issues

If `devcontainerctl` command is not found:

- Ensure you've run the setup script: `./setup.sh`
- Check that `~/bin` is in your PATH: `echo $PATH`
- Try restarting your terminal or running: `source ~/.bashrc`

If cron job is not running:

- Verify it's configured: `crontab -l`
- Check cron logs for errors
- Manually test the sync command: `devcontainerctl sync`

## Support

For any other issues:

- Check the troubleshooting section above
- Contact SDF TRE support for workspace or network-related problems
- Report container-specific issues on [our repo's GitHub Issues](https://github.com/smartdatafoundry/devcontainer/issues)
