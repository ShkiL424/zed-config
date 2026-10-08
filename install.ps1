#Requires -Version 5.1
<#
  Windows counterpart of install.sh.

  Usage (from the repo root):
    powershell -ExecutionPolicy Bypass -File .\install.ps1

  File symlinks on Windows require either Developer Mode
  (Settings > System > For developers) or an elevated (admin) shell.
  Directories are linked as junctions, which need no special rights.
#>
$ErrorActionPreference = 'Stop'

$DotfilesDir = $PSScriptRoot
$ZedDotfiles = Join-Path $DotfilesDir 'zed'
$ZedConfig   = Join-Path $env:APPDATA 'Zed'

New-Item -ItemType Directory -Force -Path $ZedConfig | Out-Null

function Test-IsLink([string]$Path) {
  $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
  return $item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

function Backup-IfRealFile([string]$Target) {
  if ((Test-Path -LiteralPath $Target) -and -not (Test-IsLink $Target)) {
    $stamp = Get-Date -Format 'yyyyMMddHHmmss'
    Move-Item -LiteralPath $Target -Destination "$Target.backup.$stamp"
  }
}

# Remove an existing link without following it into the repo.
function Remove-Link([string]$Target) {
  $item = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
  if (-not $item) { return }
  if ($item.PSIsContainer) {
    [IO.Directory]::Delete($Target)
  } else {
    [IO.File]::Delete($Target)
  }
}

function Install-Link([string]$Name) {
  $source = Join-Path $ZedDotfiles $Name
  $target = Join-Path $ZedConfig $Name

  if (-not (Test-Path -LiteralPath $source)) {
    Write-Warning "Skipping $Name : not found in $ZedDotfiles"
    return
  }

  Backup-IfRealFile $target
  Remove-Link $target

  if ((Get-Item -LiteralPath $source).PSIsContainer) {
    New-Item -ItemType Junction -Path $target -Target $source | Out-Null
  } else {
    try {
      New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
    } catch {
      Write-Error ("Cannot create symlink for $Name. Enable Developer Mode " +
        "(Settings > System > For developers) or run PowerShell as Administrator.")
    }
  }
  Write-Host "Linked $target -> $source"
}

Install-Link 'settings.json'
Install-Link 'keymap.json'
Install-Link 'snippets'
Install-Link 'themes'

Write-Host 'Zed config installed successfully.'
Write-Host 'Restart Zed if themes or snippets do not appear immediately.'
