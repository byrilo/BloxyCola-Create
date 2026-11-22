[CmdletBinding()]
param([switch]$InstallPlugin)

$ErrorActionPreference = 'Stop'
$audio = Join-Path $PSScriptRoot 'assets/bloxy-cola.mp3'
$plugin = Join-Path $PSScriptRoot 'PlaceTogether.rbxmx'
if (-not (Test-Path -LiteralPath $audio -PathType Leaf)) {
    throw 'Missing assets/bloxy-cola.mp3. Extract the entire ZIP before running the installer.'
}
if ($InstallPlugin -and -not (Test-Path -LiteralPath $plugin -PathType Leaf)) {
    throw 'Missing PlaceTogether.rbxmx. Extract the entire ZIP before running the installer.'
}

$roots = @($env:LOCALAPPDATA, ${env:ProgramFiles(x86)}) |
    Where-Object { $_ } |
    ForEach-Object { Join-Path $_ 'Roblox/Versions' }

$foundStudio = $false
$installedSound = $false
foreach ($root in $roots) {
    if (-not (Test-Path -LiteralPath $root -PathType Container)) { continue }
    foreach ($version in Get-ChildItem -LiteralPath $root -Directory) {
        $studioExe = Join-Path $version.FullName 'RobloxStudioBeta.exe'
        if (-not (Test-Path -LiteralPath $studioExe -PathType Leaf)) { continue }
        $foundStudio = $true
        $target = Join-Path $version.FullName 'content/sounds'
        try {
            New-Item -ItemType Directory -Path $target -Force | Out-Null
            Copy-Item -LiteralPath $audio -Destination (Join-Path $target 'bloxy-cola.mp3') -Force
            $installedSound = $true
            Write-Output "Installed BloxyCola startup sound in $($version.Name)"
        } catch {
            Write-Warning "Could not install sound in $($version.FullName): $($_.Exception.Message)"
        }
    }
}

if (-not $foundStudio) { throw 'Roblox Studio was not found. Install Studio before running this installer.' }
if (-not $installedSound) { throw 'Could not copy the sound to a Roblox Studio content folder.' }

if ($InstallPlugin) {
    $pluginsFolder = Join-Path $env:LOCALAPPDATA 'Roblox/Plugins'
    New-Item -ItemType Directory -Path $pluginsFolder -Force | Out-Null
    Copy-Item -LiteralPath $plugin -Destination (Join-Path $pluginsFolder 'PlaceTogether.rbxmx') -Force
    Write-Output 'BloxyCola Create is installed. Open Roblox Studio, or restart it if it is already open.'
}
