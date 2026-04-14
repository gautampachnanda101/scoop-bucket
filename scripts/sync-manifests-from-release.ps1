param(
    [Parameter(Mandatory = $true)]
    [string]$Repository,
    [Parameter(Mandatory = $true)]
    [string]$TagName,
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)) {
    throw 'GITHUB_TOKEN is required for GitHub API access.'
}

$normalizedVersion = $TagName -replace '^[vV]', ''
$apiUrl = "https://api.github.com/repos/$Repository/releases/tags/$TagName"
$headers = @{
    Authorization = "Bearer $env:GITHUB_TOKEN"
    Accept = 'application/vnd.github+json'
}

$release = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
$assetMap = @{}
foreach ($asset in $release.assets) {
    $assetMap[$asset.name.ToLowerInvariant()] = $asset
}

function Get-RepoFromGitHubUrl {
    param([string]$Url)

    if ([string]::IsNullOrWhiteSpace($Url)) { return '' }
    $repoMatch = [regex]::Match($Url, '^https://github\.com/([^/]+/[^/]+)')
    if ($repoMatch.Success) {
        return $repoMatch.Groups[1].Value
    }

    return ''
}

function Get-ManifestCandidates {
    param([string]$Root)

    $rootJson = Get-ChildItem -Path $Root -File -Filter '*.json' -ErrorAction SilentlyContinue
    $bucketPath = Join-Path $Root 'bucket'
    $bucketJson = @()
    if (Test-Path $bucketPath) {
        $bucketJson = Get-ChildItem -Path $bucketPath -File -Filter '*.json' -ErrorAction SilentlyContinue
    }

    return (@($rootJson) + @($bucketJson)) | Sort-Object -Property FullName -Unique
}

function Get-MatchingZipAsset {
    param(
        [string]$PackageName,
        [object[]]$Assets
    )

    $assetMatches = @()
    foreach ($a in $Assets) {
        $name = [string]$a.name
        if (-not $name.ToLowerInvariant().EndsWith('.zip')) { continue }
        if ($name.ToLowerInvariant().StartsWith(($PackageName + '_').ToLowerInvariant()) -or
            $name.ToLowerInvariant().StartsWith(($PackageName + '-').ToLowerInvariant()) -or
            $name.ToLowerInvariant().StartsWith($PackageName.ToLowerInvariant())) {
            $assetMatches += $a
        }
    }

    if ($assetMatches.Count -eq 0) { return $null }
    return $assetMatches[0]
}

function Get-HashForAsset {
    param([string]$DownloadUrl)

    $tmpFile = Join-Path $env:RUNNER_TEMP ([System.IO.Path]::GetRandomFileName())
    try {
        Invoke-WebRequest -Uri $DownloadUrl -Headers $headers -OutFile $tmpFile
        return (Get-FileHash -Path $tmpFile -Algorithm SHA256).Hash.ToLowerInvariant()
    } finally {
        if (Test-Path $tmpFile) {
            Remove-Item -Path $tmpFile -Force -ErrorAction SilentlyContinue
        }
    }
}

$updated = 0
foreach ($manifestFile in Get-ManifestCandidates -Root $RepoRoot) {
    try {
        $manifest = Get-Content -Path $manifestFile.FullName -Raw | ConvertFrom-Json -AsHashtable -ErrorAction Stop
    } catch {
        continue
    }

    if (-not $manifest.ContainsKey('version')) { continue }

    if (-not $manifest.ContainsKey('checkver') -or -not $manifest.checkver.ContainsKey('github')) {
        continue
    }

    $manifestRepo = Get-RepoFromGitHubUrl -Url ([string]$manifest.checkver.github)
    if ($manifestRepo -ne $Repository) {
        continue
    }

    $packageName = [System.IO.Path]::GetFileNameWithoutExtension($manifestFile.Name)
    $matchingAsset = Get-MatchingZipAsset -PackageName $packageName -Assets $release.assets
    if ($null -eq $matchingAsset) {
        continue
    }

    $downloadUrl = [string]$matchingAsset.browser_download_url
    $newHash = Get-HashForAsset -DownloadUrl $downloadUrl

    $changed = $false
    $oldVersion = [string]$manifest.version
    if ($oldVersion -ne $normalizedVersion) {
        $manifest.version = $normalizedVersion
        $changed = $true
    }

    if ($manifest.ContainsKey('url')) {
        if ([string]$manifest.url -ne $downloadUrl) {
            $manifest.url = $downloadUrl
            $changed = $true
        }
        if ($manifest.ContainsKey('hash') -and ([string]$manifest.hash).ToLowerInvariant() -ne $newHash) {
            $manifest.hash = $newHash
            $changed = $true
        }
    }

    if ($manifest.ContainsKey('architecture') -and $manifest.architecture.ContainsKey('64bit')) {
        $arch = $manifest.architecture['64bit']
        if ($arch.ContainsKey('url') -and ([string]$arch.url -ne $downloadUrl)) {
            $arch.url = $downloadUrl
            $changed = $true
        }
        if ($arch.ContainsKey('hash') -and ([string]$arch.hash).ToLowerInvariant() -ne $newHash) {
            $arch.hash = $newHash
            $changed = $true
        }
    }

    if ($manifest.ContainsKey('post_install')) {
        $newPostInstall = @()
        foreach ($line in $manifest.post_install) {
            $updatedLine = [string]$line -replace '([a-z0-9_-]+-vscode-)[^"''\\]+(\.vsix)', ('$1' + $normalizedVersion + '$2')
            $newPostInstall += $updatedLine
        }

        $originalJoined = ($manifest.post_install | ForEach-Object { [string]$_ }) -join "`n"
        $newJoined = ($newPostInstall | ForEach-Object { [string]$_ }) -join "`n"
        if ($originalJoined -ne $newJoined) {
            $manifest.post_install = $newPostInstall
            $changed = $true
        }
    }

    if ($changed) {
        $json = $manifest | ConvertTo-Json -Depth 100
        $json | Out-File -FilePath $manifestFile.FullName -Encoding utf8
        Write-Host "Updated $($manifestFile.Name) -> version $normalizedVersion"
        $updated++
    }
}

Write-Host "Manifest sync complete. Updated $updated file(s)."
