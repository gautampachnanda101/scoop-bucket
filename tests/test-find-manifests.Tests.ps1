Import-Module Pester -ErrorAction SilentlyContinue

Describe 'find-manifests.ps1' {

  It 'finds manifest by normalized version (strips leading v)' {
    # Arrange
    $tempDir = Join-Path $PSScriptRoot 'fixtures'
    Push-Location $tempDir
    try {
      # Act
      $out = & pwsh -NoProfile -NoLogo -NonInteractive -File "../../.github/scripts/find-manifests.ps1" -Version '1.2.3' -AsJson
      $matches = $out | ConvertFrom-Json

      # Assert
      $matches | Should -Not -BeNullOrEmpty
      $matches[0].id | Should -Be 'k3d-local-alpha'
      $matches[0].version | Should -Be '1.2.3'
    } finally {
      Pop-Location
    }
  }

  It 'returns no matches for different version' {
    $tempDir = Join-Path $PSScriptRoot 'fixtures'
    Push-Location $tempDir
    try {
      $out = & pwsh -NoProfile -NoLogo -NonInteractive -File "../../.github/scripts/find-manifests.ps1" -Version '2.0.0' -AsJson
      $matches = $out | ConvertFrom-Json
      $matches.Count | Should -Be 0
    } finally {
      Pop-Location
    }
  }
}

