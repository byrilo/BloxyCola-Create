$ErrorActionPreference = 'Stop'
$audio = Join-Path $PSScriptRoot 'assets/bloxy-cola.mp3'
$roots = @(
    (Join-Path $env:LOCALAPPDATA 'Roblox/Versions')
    (Join-Path ${env:ProgramFiles(x86)} 'Roblox/Versions')
)
$installed = $false
foreach ($root in $roots) {
    if (-not (Test-Path -LiteralPath $root -PathType Container)) { continue }
    foreach ($version in Get-ChildItem -LiteralPath $root -Directory) {
        $studioExe = Join-Path $version.FullName 'RobloxStudioBeta.exe'
        if (-not (Test-Path -LiteralPath $studioExe -PathType Leaf)) { continue }
        $target = Join-Path $version.FullName 'content/sounds'
        New-Item -ItemType Directory -Path $target -Force | Out-Null
        Copy-Item -LiteralPath $audio -Destination (Join-Path $target 'bloxy-cola.mp3') -Force
        Write-Output "Installed BloxyCola startup sound in $($version.Name)"
        $installed = $true
    }
}
if (-not $installed) { throw 'Roblox Studio was not found in the standard Windows installation folders.' }
