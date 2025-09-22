# Setting up Dev Containers in the SDF Trusted Research Environment

This guide provides step-by-step instructions for setting up and using dev containers within the SDF Trusted Research Environment (TRE).

## Prerequisites

Before using dev containers in the SDF Trusted Research Environment, you need to manually install the Dev Containers extension in VS Code:

### 1. Extract the Dev Containers Extension

The extension is baked into the container image. Extract it using:

```bash
podman run --rm -it \
  -v $PWD:$PWD \
  -w $PWD \
  ghcr.io/smartdatafoundry/devcontainer:latest \
  cp /opt/ms-vscode-remote.remote-containers.vsix .
```

### 2. Install the Extension

**Option A: Via Command Line**
```bash
code --install-extension ms-vscode-remote.remote-containers.vsix
```

**Option B: Via VS Code Interface**
- Open VS Code in your TRE environment
- Go to the Extensions tab
- Click on the 3-dot menu (⋯) in the Extensions panel
- Select "Install from VSIX..."
- Choose the `ms-vscode-remote.remote-containers.vsix` file you extracted

### 3. Configure VS Code for Podman

Add to your VS Code settings.json to configure Podman as the container runtime:

- Open VS Code
- Press `Ctrl+,` to open Settings
- Click the "Open Settings (JSON)" icon in the top-right corner
- Add the following configuration:

```json
{
    "dev.containers.dockerPath": "podman"
}
```

### 4. Ensure Container Access

Verify you have access to podman/docker within your TRE workspace.

## Configuration

Create a `.devcontainer/devcontainer.json` file in your project root with the TRE-specific configuration:

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

### Configuration Explanation

- **`mounts`**: 
  - Binds the `/safe_data` directory for access to TRE data
  - Creates a temporary filesystem for `/tmp` for TRE compatibility
  
- **`runArgs`**: 
  - `--userns=host`: Uses the host user namespace for TRE compatibility
  - `-e HTTP_PROXY` and `-e HTTPS_PROXY`: **Essential** for pip and network calls to work within the TRE. These inherit proxy credentials from your TRE environment.
  
- **`remoteUser`**: Set to `root` for TRE compatibility

## How It Works

When you create the devcontainer configuration:

1. VS Code will prompt you to "Reopen in Container"
2. Docker/Podman fires up the container and connects VS Code to it
3. Your project directory is automatically mounted into the container
4. Any changes made inside the container are preserved in your project files outside the container
5. This avoids the "chicken and egg" problem of having source code baked into containers

This approach leverages container technology directly while maintaining the ability to modify and iterate on your code seamlessly.

## Quick Start Workflow

1. **Install the Dev Containers extension** (follow Prerequisites section above)
2. **Create your project directory** in the TRE workspace
3. **Add the devcontainer configuration** - create `.devcontainer/devcontainer.json` with the TRE-specific configuration shown in the Configuration section above
4. **Open the project in VS Code**
5. **Open in Container**: 
    - **Option A**: Click "Reopen in Container" when prompted by VS Code
    - **Option B**: Open Command Palette (`Ctrl+Shift+P`) and run "Dev Containers: Reopen in Container"
6. **Wait for container setup** (first time may take a few minutes)
7. **Start developing** - your changes are automatically saved to the host filesystem

## Advanced Configuration

### VS Code Server Version Management

The container comes with VS Code Server pre-installed and to control the version to match your TRE environment, you can specify the commit hash of the VS Code Server version to use as follows:

1. Check your TRE VS Code version via _Help > About_
2. Specify the VS Code commit in this repository's `devcontainer.json` file which is used for building the container, not to be confused with TRE workspace settings:
   ```json
   {
     "build": {
       "dockerfile": "Dockerfile", 
       "args": {
         "VSCODE_COMMIT": "your_commit_hash_here"
       }
     }
   }
   ```
3. This is typically only needed for custom container builds, not when using the published container

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

## Support

For TRE-specific issues:
- Check the troubleshooting section above
- Contact SDF TRE support for workspace or network-related problems
- Report container-specific issues to the [devcontainer repository](https://github.com/smartdatafoundry/devcontainer)