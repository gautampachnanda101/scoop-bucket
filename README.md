# Scoop Bucket by @gautampachnanda101

Official Scoop bucket for various cross-platform development tools and utilities.

## Available Packages

### k3d-local

Cross-platform local Kubernetes development environment with k3d.

**Prerequisites (Windows):**

k3d requires **Docker Desktop** with Linux containers mode enabled:

```powershell
# Install Docker Desktop via winget
winget install -e --id Docker.DockerDesktop

# After installation, ensure "Use WSL 2 based engine" is enabled in Docker Desktop settings
# Docker must be running with Linux containers mode (not Windows containers)
```

> **Note:** k3d runs Kubernetes (k3s) in Linux containers. On Windows, Docker Desktop with WSL2 backend is required.
>
> **For Linux users:** You can use Podman instead of Docker as an alternative container runtime.

**Installation:**

```powershell
scoop bucket add gautampachnanda101 https://github.com/gautampachnanda101/scoop-bucket
scoop install k3d-local
```

**Quick Start:**

```powershell
# Create cluster with defaults
k3d-local create

# Create cluster with Traefik and sample apps
k3d-local create --with-traefik --with-apps

# Create full stack with all components
k3d-local create --with-traefik --with-core --with-telemetry --with-apps

# Check cluster status
k3d-local status

# Delete cluster
k3d-local delete

# Advanced: Use k3d pass-through for direct k3d access
k3d-local k3d cluster list
k3d-local k3d node list
k3d-local k3d version
```

**Advanced Usage - k3d Pass-through:**

k3d-local provides direct access to k3d commands via pass-through mode:

```powershell
# Any k3d command works
k3d-local k3d cluster create mycluster --agents 2
k3d-local k3d cluster delete mycluster
k3d-local k3d registry create myregistry
```

**Links:**

- [Repository](https://github.com/gautampachnanda101/local-cluster-k3d)
- [Documentation](https://github.com/gautampachnanda101/local-cluster-k3d/tree/main/docs)
- [Releases](https://github.com/gautampachnanda101/local-cluster-k3d/releases)

---

## General Usage

> macOS prerequisite: some scripts and tests call PowerShell (`pwsh`). If you're on macOS and `pwsh` isn't installed, install PowerShell via Homebrew:

```bash
brew install --cask powershell
```

You can quickly verify prerequisites for this repository by running the included prereq checker from a PowerShell session (or from macOS after installing PowerShell):

```powershell
pwsh ./scripts/check-prereqs.ps1
```

### List Available Packages

```powershell
scoop bucket add gautampachnanda101 https://github.com/gautampachnanda101/scoop-bucket
scoop search gautampachnanda101/
```

### Update Packages

```powershell
scoop update
scoop update <package-name>
```

### Uninstall

```powershell
scoop uninstall <package-name>
scoop bucket rm gautampachnanda101  # Remove bucket entirely
```

## About

This bucket is automatically maintained via GoReleaser for automated manifest updates.

All manifests are verified on Windows via GitHub Actions CI.

## Contributing

Manifests are auto-generated from upstream releases. For package-specific issues, please visit the respective project repository.
