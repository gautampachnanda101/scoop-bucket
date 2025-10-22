<#
scripts/check-prereqs.ps1

Checks basic prerequisites for running repository scripts and tests.
Exits non-zero with a helpful message if a prerequisite is missing.
#>

$errors = @()

# Ensure we're running PowerShell Core / pwsh (PowerShell 6+)
if ($PSVersionTable.PSVersion.Major -lt 6) {
    $errors += "PowerShell 6+ (pwsh) is required. Detected: $($PSVersionTable.PSVersion). Install PowerShell Core: https://aka.ms/powershell"
}

# On Windows, ensure Chocolatey exists (used by some CI flows)
if ($IsWindows) {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        $errors += "Chocolatey (choco) is not installed or not on PATH. If you expect Chocolatey to be available on the runner, install it or ensure it's on PATH."
    }
}

if ($errors.Count -gt 0) {
    Write-Host "Prerequisite check failed:" -ForegroundColor Red
    foreach ($e in $errors) { Write-Host "- $e" }
    exit 1
} else {
    Write-Host "Prerequisite check passed: PowerShell $($PSVersionTable.PSVersion) detected." -ForegroundColor Green
    exit 0
}

