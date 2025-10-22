<#
Finds Scoop JSON manifests matching a version.
Outputs newline-delimited JSON objects or a JSON array when invoked with -AsJson.
#>
param(
  [Parameter(Mandatory=$true)]
  [string] $Version,

  [string] $BucketPath = 'bucket',

  [switch] $AsJson
)

function Get-JsonFilesInRepo {
  param([string]$bucketPath)
  $files = @()
  if (Test-Path -Path $bucketPath) {
    $files += Get-ChildItem -Path $bucketPath -Recurse -File -Include *.json -ErrorAction SilentlyContinue
  }
  $files += Get-ChildItem -Path . -File -Include *.json -ErrorAction SilentlyContinue
  return $files | Sort-Object -Property FullName -Unique
}

function NormalizeVersion([string]$v) { if (-not $v) { return $v }; return $v -replace '^[vV]','' }

$norm = NormalizeVersion($Version)
$files = Get-JsonFilesInRepo -bucketPath $BucketPath
$matches = @()
foreach ($f in $files) {
  try {
    $j = Get-Content $f.FullName -Raw | ConvertFrom-Json -ErrorAction Stop
  } catch {
    continue
  }
  $ver = $null
  if ($j.PSObject.Properties.Name -contains 'version') { $ver = $j.version }
  if (-not $ver) { continue }
  $verNorm = NormalizeVersion($ver)
  if ($verNorm -ne $norm) { continue }
  if ($j.PSObject.Properties.Name -contains 'chocoId') { $id = $j.chocoId }
  elseif ($j.PSObject.Properties.Name -contains 'name') { $id = $j.name }
  else { $id = $f.BaseName }
  $matches += [pscustomobject]@{ path = $f.FullName; id = $id; version = $verNorm }
}

if ($AsJson) {
  $matches | ConvertTo-Json -Compress
} else {
  foreach ($m in $matches) { $m | ConvertTo-Json -Compress; "" }
}
