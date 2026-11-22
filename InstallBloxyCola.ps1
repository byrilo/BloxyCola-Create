$ErrorActionPreference = 'Stop'
$plugin = Join-Path $PSScriptRoot 'PlaceTogether.rbxmx'
$audio = Join-Path $PSScriptRoot 'assets/bloxycola-can-opening.mp3'
if (-not (Test-Path -LiteralPath $plugin -PathType Leaf) -or
    -not (Test-Path -LiteralPath $audio -PathType Leaf)) {
    throw 'Extract the entire ZIP before running the installer.'
}

$roots = @($env:LOCALAPPDATA, ${env:ProgramFiles(x86)}) |
    Where-Object { $_ } |
    ForEach-Object { Join-Path $_ 'Roblox/Versions' }

$installedAudio = $false
foreach ($root in $roots) {
    if (-not (Test-Path -LiteralPath $root -PathType Container)) { continue }
    foreach ($version in Get-ChildItem -LiteralPath $root -Directory) {
        $studioExe = Join-Path $version.FullName 'RobloxStudioBeta.exe'
        if (-not (Test-Path -LiteralPath $studioExe -PathType Leaf)) { continue }
        try {
            $sounds = Join-Path $version.FullName 'content/sounds'
            New-Item -ItemType Directory -Path $sounds -Force | Out-Null
            Copy-Item -LiteralPath $audio -Destination (Join-Path $sounds 'bloxycola-can-opening.mp3') -Force
            $installedAudio = $true
        } catch {
            Write-Warning "Could not install sound into $($version.Name): $($_.Exception.Message)"
        }
    }
}

$plugins = Join-Path $env:LOCALAPPDATA 'Roblox/Plugins'
New-Item -ItemType Directory -Path $plugins -Force | Out-Null
Copy-Item -LiteralPath $plugin -Destination (Join-Path $plugins 'PlaceTogether.rbxmx') -Force

if (-not $installedAudio) {
    Write-Warning 'No writable Roblox Studio installation was found for the offline startup sound.'
}
Write-Output 'BloxyCola Create is installed. Open Roblox Studio, or restart it if it is already open.'
