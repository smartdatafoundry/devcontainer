<div align="center">
  <img src="assets/ouroboros-chicken-logo.png" alt="devcontainer logo" width="200" height="200">
</div>

# devcontainer

Development container focused on Python (with first-class R support) providing a reproducible, batteries‑included environment. It ships with the VS Code Dev Containers extension assets, curated tooling, and a consistent tagging strategy for deterministic rebuilds.

## Table of Contents
1. Published Container
2. Quick Start
3. Using in SDF TRE
4. Documentation
5. What's Included
6. R Language Support
7. VS Code Server
8. Adding Extensions
9. Automated Builds & Tag Strategy
10. Contributing
11. License

[![Build and Publish Dev Container](https://github.com/smartdatafoundry/devcontainer/actions/workflows/build-devcontainer.yml/badge.svg)](https://github.com/smartdatafoundry/devcontainer/actions/workflows/build-devcontainer.yml)

## 📦 Published Container

Built and published automatically to GitHub Container Registry (GHCR):

* **Registry**: `ghcr.io`
* **Image**: `ghcr.io/smartdatafoundry/devcontainer`
* **Tag Families**:
  * `latest` – Most recent stable main build
  * `main` – Moving pointer to HEAD of main
  * `main-<branch-sha>` – Immutable build for a specific main commit
  * `pr-<number>` – Ephemeral preview for a pull request
  * `vscode-<vscode-sha>` – Locks VS Code Server version (container content may still move)
  * `vscode-<vscode-sha>-<branch-sha>` – Fully reproducible (VS Code Server + container commit)

Recommended:
* Daily development: `latest`
* CI / Reproducibility: `vscode-<vscode-sha>-<branch-sha>`
* VS Code Server pin only: `vscode-<vscode-sha>`

## 🚀 Quick Start

### Using the Published Container

Add this to your `.devcontainer/devcontainer.json`:

```json
{
  "name": "Python Development",
  "image": "ghcr.io/smartdatafoundry/devcontainer:latest"
}
```

### Using in SDF Trusted Research Environment

#### Quick Setup with Included Scripts (Recommended)

The devcontainer includes setup scripts for easy deployment in the SDF TRE:

```bash
# 1. Pull the container image
ces-pull a a ghcr.io/smartdatafoundry/devcontainer:latest

# 2. Extract the setup scripts
podman run --rm -v $HOME:$HOME -w $HOME \
  ghcr.io/smartdatafoundry/devcontainer:latest \
  cp -r /opt/scripts $HOME/devcontainer-scripts

# 3. Run the setup script (one-time setup)
cd $HOME/devcontainer-scripts
./setup.sh

# 4. Start your devcontainer
devcontainerctl start
```

The setup script will:
- Create a symlink to `devcontainerctl` in `~/bin`
- Add `~/bin` to your PATH
- Configure a daily cron job (8:00 AM) to update your container with the latest version

Available `devcontainerctl` commands:
- `devcontainerctl start` - Pull latest image and start container
- `devcontainerctl stop` - Stop the container
- `devcontainerctl restart` - Restart the container
- `devcontainerctl status` - Check container status
- `devcontainerctl sync` - Update the container image
- `devcontainerctl update` - Update and restart with new image
- `devcontainerctl remove` - Stop and remove the container

#### Manual Setup

For detailed manual setup instructions, see the **[SDF TRE Setup Guide](docs/SDF_TRE_SETUP.md)**.

### Using This Repository Directly

1. Clone this repository
2. Open in VS Code
3. Select "Reopen in Container" when prompted

## 📚 Documentation

| Topic | Reference |
|-------|-----------|
| SDF TRE usage | [`docs/SDF_TRE_SETUP.md`](docs/SDF_TRE_SETUP.md) |
| Full container internals | [`docs/DEVCONTAINER.md`](docs/DEVCONTAINER.md) |
| Setup scripts | [`scripts/`](scripts/) directory |
| Reusable publish workflow | [`docs/BUILD_PUBLISH_CONTAINER.md`](docs/BUILD_PUBLISH_CONTAINER.md) |
| Dev Container Specification | https://containers.dev |

## 🛠️ What's Included

- **Base**: Ubuntu 24.04 (Noble) via Microsoft's devcontainers base image
- **Python**: System Python with development tools (via devcontainer feature)
- **R**: Full R language support with development tools (via Rocker Project devcontainer feature)
- **Git**: Latest version with configuration support
- **Shell**: Zsh with Oh My Zsh (via common-utils feature)
- **Quarto**: Document publishing platform (latest version)
- **Marimo**: Markdown presentation tool, alternative to Jupyter Notebooks
- **User Setup Scripts**: Automated deployment and management tools ([`scripts/`](scripts/))
- **VS Code Extensions (curated)**:
  - Continue (AI assistant)
  - Black (Python formatting)
  - Jupyter
  - Marimo
  - Markdown All in One
  - Rainbow CSV
  - (See [`.devcontainer/vscode-init/extensions-to-install.txt`](.devcontainer/vscode-init/extensions-to-install.txt) for authoritative list)
- **VS Code Server**: Pre-installed for immediate development

## 📊 R Language Support

This dev container includes comprehensive R language support through the [Rocker Project's devcontainer features](https://github.com/rocker-org/devcontainer-features). The R feature provides:

### Features Available
- **R Installation**: Latest R version via apt package manager
- **Development Tools**: devtools, renv for package management
- **IDE Integration**: 
  - languageserver package for VS Code R extension support
  - httpgd package for interactive graphics
  - rmarkdown for document generation
- **Jupyter Integration**: R kernel for Jupyter notebooks
- **Interactive Console**: radian (enhanced R console with syntax highlighting)
- **Debugging Support**: vscDebugger package for VS Code R debugging

## ⚙️ VS Code Server

Pre-installed. Pin a version using the tag families described above or via build arg `VSCODE_COMMIT` (default: `7d842fb85a0275a4a8e4d7e040d2625abbf7f084`). For environment-specific considerations (e.g. TRE) see [`docs/SDF_TRE_SETUP.md`](docs/SDF_TRE_SETUP.md).

## Adding New Extensions
To add new VS Code extensions to the container, follow these steps:
1. Open the appropriate file in [`.devcontainer/vscode-init/`](.devcontainer/vscode-init/):
   - [`extensions-to-install.txt`](.devcontainer/vscode-init/extensions-to-install.txt) for extensions to install directly
   - [`extensions-to-download.txt`](.devcontainer/vscode-init/extensions-to-download.txt) for extensions that you want to be downloaded
2. Add the identifier of the desired extension in the format `publisher.extensionName` on a new line.
3. Save the changes to the extension file.
4. Commit and push the changes to your repository to trigger the build workflow with the updated extensions

## 🔄 Automated Builds & Tag Strategy

### Build Workflow

Workflow: [`.github/workflows/build-devcontainer.yml`](.github/workflows/build-devcontainer.yml)

Triggers:
* Pull Requests touching devcontainer/workflow files → build + `pr-<number>` tag
* Manual dispatch (with required `vscode_commit` input) → publish full tag set

Outputs per production run:
* `latest`, `main`, `main-<branch-sha>`
* `vscode-<vscode-sha>`, `vscode-<vscode-sha>-<branch-sha>`

Manual build steps:
1. Open Actions → Build and Publish Dev Container
2. Run workflow, supplying VS Code Server commit hash
3. Await completion & verify tags on GHCR package page

Tag usage quick reference:
| Need | Tag |
|------|-----|
| Stable rolling | `latest` |
| Immutable main snapshot | `main-<sha>` |
| Test PR | `pr-<number>` |
| Pin VS Code Server only | `vscode-<vscode-sha>` |
| Full reproducibility | `vscode-<vscode-sha>-<sha>` |

Reusable generic Docker workflow documentation: see [`docs/BUILD_PUBLISH_CONTAINER.md`](docs/BUILD_PUBLISH_CONTAINER.md).

### VS Code Auto-Update Workflow

[![Update VS Code Version](https://github.com/smartdatafoundry/devcontainer/actions/workflows/update-vscode.yml/badge.svg)](https://github.com/smartdatafoundry/devcontainer/actions/workflows/update-vscode.yml)

Workflow: [`.github/workflows/update-vscode.yml`](.github/workflows/update-vscode.yml)

An automated workflow that:
* Runs daily at 2:00 AM UTC to check for new VS Code releases
* Compares the latest stable VS Code commit hash with the current version in the Dockerfile
* Automatically creates a PR when a new version is available
* Enables auto-merge to update the container once all checks pass

This ensures the devcontainer stays up-to-date with the latest VS Code releases without manual intervention.

For detailed configuration and usage information, see [`docs/VSCODE_AUTO_UPDATE.md`](docs/VSCODE_AUTO_UPDATE.md).

---
## 🤝 Contributing & License

Contribution workflow is standard GitHub Flow. See section above plus open issues for opportunities.

License: [MIT](LICENSE)

---
