# Scoop Bucket by @gautampachnanda101

Official Scoop bucket for various cross-platform development tools and utilities.

## Available Packages

### k3d-local

Cross-platform local Kubernetes development environment with k3d.

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
