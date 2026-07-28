<div align="center">
  <img src="assets/ouroboros-chicken-logo.png" alt="devcontainer logo" width="200" height="200">
</div>

# devcontainer

A pre-built container image designed for use with the [VS Code Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) inside the SDF Trusted Research Environment. It gives researchers a full, self-contained VS Code development experience — with a curated set of tools, languages, and extensions baked in — without depending on what the TRE host system provides.

[![Build and Publish Dev Container](https://github.com/smartdatafoundry/devcontainer/actions/workflows/build-devcontainer.yml/badge.svg)](https://github.com/smartdatafoundry/devcontainer/actions/workflows/build-devcontainer.yml)

## Table of Contents
- [devcontainer](#devcontainer)
  - [Table of Contents](#table-of-contents)
  - [💡 Why a Dev Container?](#-why-a-dev-container)
  - [📦 Published Container](#-published-container)
  - [🚀 Quick Start in the SDF TRE](#-quick-start-in-the-sdf-tre)
    - [Step 1 — Pull the image and set up auto-update](#step-1--pull-the-image-and-set-up-auto-update)
    - [Step 2 — Open your project in VS Code](#step-2--open-your-project-in-vs-code)
  - [🔧 Using in Other Environments](#-using-in-other-environments)
    - [Using the published image directly](#using-the-published-image-directly)
    - [Using this repository directly](#using-this-repository-directly)
  - [📚 Documentation](#-documentation)
  - [🛠️ What's Included](#️-whats-included)
  - [📊 R Language Support](#-r-language-support)
  - [⚙️ VS Code Server](#️-vs-code-server)
  - [Adding New Extensions](#adding-new-extensions)
  - [🔄 Automated Builds \& Tag Strategy](#-automated-builds--tag-strategy)
    - [Build Workflow](#build-workflow)
    - [VS Code Auto-Update Workflow](#vs-code-auto-update-workflow)
  - [🤝 Contributing \& License](#-contributing--license)

---

## 💡 Why a Dev Container?

The SDF TRE is a controlled environment where the host system's software stack is managed centrally and may not include the languages, tools, or VS Code extensions your project needs. Rather than negotiating host-level changes, this container provides a complete, self-describing development environment that VS Code's Dev Containers extension loads directly.

When you open a project that references this image, VS Code connects to the running container and executes everything — terminal sessions, language servers, linters, debuggers, and extensions — inside it. From your perspective the experience is identical to working locally; from the TRE's perspective you are running a single, auditable container image.

This approach gives you:

- **Freedom from host limitations** — Python, R, Quarto, Marimo, Zsh, and all required dev tools are inside the container, not sourced from the host.
- **Controlled extension delivery** — VS Code extensions are pre-installed in the image at build time. There is no need for outbound Marketplace access at runtime, which is essential in a network-restricted environment.
- **Granular environment control** — Pin the exact container image tag (down to the VS Code Server commit and container build SHA) to reproduce a known-good environment across any number of users or sessions.
- **Instant onboarding** — New researchers pull one image and open their project; VS Code handles the rest automatically.

---

## 📦 Published Container

Built and published automatically to GitHub Container Registry (GHCR):

- **Registry**: `ghcr.io`
- **Image**: `ghcr.io/smartdatafoundry/devcontainer`
- **Tag Families**:
  - `latest` – Most recent stable main build
  - `main-<branch-sha>` – Immutable snapshot of a specific main commit
  - `pr-<number>` – Ephemeral preview for a pull request
  - `vscode-<vscode-sha>` – Locks the VS Code Server version
  - `vscode-<vscode-sha>-<branch-sha>` – Fully reproducible (VS Code Server + container commit)

| Need | Tag |
|------|-----|
| Stable rolling | `latest` |
| Immutable snapshot | `main-<sha>` |
| Test a PR | `pr-<number>` |
| Pin VS Code Server only | `vscode-<vscode-sha>` |
| Full reproducibility | `vscode-<vscode-sha>-<branch-sha>` |

---

## 🚀 Quick Start in the SDF TRE

### Step 1 — Pull the image and set up auto-update

```bash
# Pull the container image
ces-pull a a ghcr.io/smartdatafoundry/devcontainer:latest

# Extract the bundled management scripts
podman run --rm -v $HOME:$HOME -w $HOME \
  ghcr.io/smartdatafoundry/devcontainer:latest \
  cp -r /opt/devcontainerctl $HOME/devcontainerctl

# One-time setup: adds devcontainerctl to PATH and configures daily auto-update
cd $HOME/devcontainerctl
./setup.sh
```

The setup script configures a daily cron job (8:00 AM) so your image stays current automatically. To sync manually at any time:

```bash
devcontainerctl sync
```

### Step 2 — Open your project in VS Code

Add a `devcontainer.json` to your project at `.devcontainer/devcontainer.json`:

```json
{
  "name": "My Project",
  "image": "ghcr.io/smartdatafoundry/devcontainer:latest"
}
```

Open the project folder in VS Code. The Dev Containers extension will prompt **"Reopen in Container"** — click it, or use the Command Palette (`Ctrl+Shift+P`) → **Dev Containers: Reopen in Container**.

VS Code will attach to the container and your workspace, terminal, extensions, and language tooling will all run inside it.

For detailed TRE-specific instructions, see [docs/SDF_TRE_SETUP.md](docs/SDF_TRE_SETUP.md).

---

## 🔧 Using in Other Environments

### Using the published image directly

Add a `devcontainer.json` to any project:

```json
{
  "name": "Python Development",
  "image": "ghcr.io/smartdatafoundry/devcontainer:latest"
}
```

### Using this repository directly

1. Clone this repository
2. Open in VS Code
3. Select **"Reopen in Container"** when prompted

---

## 📚 Documentation

| Topic | Reference |
|-------|-----------|
| SDF TRE setup | [docs/SDF_TRE_SETUP.md](docs/SDF_TRE_SETUP.md) |
| Container internals | [docs/DEVCONTAINER.md](docs/DEVCONTAINER.md) |
| Reusable publish workflow | [docs/BUILD_PUBLISH_CONTAINER.md](docs/BUILD_PUBLISH_CONTAINER.md) |
| VS Code Auto-Update | [docs/VSCODE_AUTO_UPDATE.md](docs/VSCODE_AUTO_UPDATE.md) |
| Dev Container Specification | https://containers.dev |
| VS Code Dev Containers docs | https://code.visualstudio.com/docs/devcontainers/containers |

---

## 🛠️ What's Included

| Category | Detail |
|----------|--------|
| **Base** | Ubuntu 24.04 (Noble) via Microsoft's devcontainers base image |
| **Python** | System Python with dev tools (via devcontainer feature) |
| **R** | Full R language support (via Rocker Project devcontainer feature) |
| **Git** | Latest version with configuration support |
| **Shell** | Zsh with Oh My Zsh (via common-utils feature) |
| **Quarto** | Document publishing platform (latest) |
| **Marimo** | Reactive notebook environment, alternative to Jupyter |
| **VS Code Server** | Pre-installed — no Marketplace access needed at runtime |
| **Extensions** | Curated set pre-installed in the image (see below) |

**Pre-installed VS Code Extensions:**
- Continue (AI assistant)
- Black (Python formatter)
- Jupyter
- Marimo
- Markdown All in One
- Rainbow CSV

See [`.devcontainer/vscode-init/extensions-to-install.txt`](.devcontainer/vscode-init/extensions-to-install.txt) for the authoritative list.

---

## 📊 R Language Support

Provided via the [Rocker Project's devcontainer features](https://github.com/rocker-org/devcontainer-features):

- **R** via apt package manager
- **devtools** and **renv** for package management
- **languageserver** for VS Code R extension support
- **httpgd** for interactive graphics
- **rmarkdown** for document generation
- **R kernel** for Jupyter notebooks
- **radian** — enhanced interactive R console
- **vscDebugger** for VS Code R debugging

---

## ⚙️ VS Code Server

The VS Code Server is pre-installed at image build time using a specific commit hash, ensuring that the server version inside the container matches the VS Code client version used in the TRE. This eliminates the version negotiation that normally requires internet access when a container first starts.

Pin a specific version via the `VSCODE_COMMIT` build argument, or use the `vscode-<vscode-sha>` tag families to select an image built against a known server version.

See [docs/VSCODE_AUTO_UPDATE.md](docs/VSCODE_AUTO_UPDATE.md) for the automated update workflow.

---

## Adding New Extensions

Extensions are baked into the image at build time, making them available without any runtime network access.

1. Open the relevant file in [`.devcontainer/vscode-init/`](.devcontainer/vscode-init/):
   - [`extensions-to-install.txt`](.devcontainer/vscode-init/extensions-to-install.txt) — installed into the VS Code Server
   - [`extensions-to-download.txt`](.devcontainer/vscode-init/extensions-to-download.txt) — downloaded to `/opt/vscode-extensions` for manual installation
2. Add the extension identifier (`publisher.extensionName`) on a new line.
3. Commit and push — the build workflow will produce a new image with the extension included.

---

## 🔄 Automated Builds & Tag Strategy

### Build Workflow

Workflow: [`.github/workflows/build-devcontainer.yml`](.github/workflows/build-devcontainer.yml)

**Triggers:**
- Pull Requests touching devcontainer/workflow files → build only, tagged `pr-<number>`
- Manual dispatch (supply `vscode_commit`) → full publish

**Outputs per production run:** `latest`, `main`, `main-<branch-sha>`, `vscode-<vscode-sha>`, `vscode-<vscode-sha>-<branch-sha>`

**Manual build steps:**
1. Open Actions → **Build and Publish Dev Container**
2. Run workflow, supplying the VS Code Server commit hash
3. Verify tags on the GHCR package page

### VS Code Auto-Update Workflow

[![Update VS Code Version](https://github.com/smartdatafoundry/devcontainer/actions/workflows/update-vscode.yml/badge.svg)](https://github.com/smartdatafoundry/devcontainer/actions/workflows/update-vscode.yml)

Workflow: [`.github/workflows/update-vscode.yml`](.github/workflows/update-vscode.yml)

Runs daily at 2:00 AM UTC, compares the latest stable VS Code commit hash against the Dockerfile, and automatically opens a PR (with auto-merge enabled) when a new version is available.

---

## 🤝 Contributing & License

Contribution workflow is standard GitHub Flow. See open issues for opportunities.

License: [MIT](LICENSE)

---
