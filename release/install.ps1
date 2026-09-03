# Astral Party Thai Mod v1.2.0 - One-Click Installer
# Usage: Double-click install.bat

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Check admin rights - exit if not admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "This installer requires Administrator privileges." -ForegroundColor Red
    Write-Host "Right-click install.bat and select 'Run as administrator'." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "  ==========================================" -ForegroundColor Cyan
Write-Host "   Astral Party Thai Mod v1.2.0 - Installer" -ForegroundColor Cyan
Write-Host "  ==========================================" -ForegroundColor Cyan
Write-Host ""

# --- Detect game paths ---
$localLow = Join-Path $env:USERPROFILE "AppData\LocalLow\feimo\AstralParty_INT"
$gameCache = Join-Path $localLow "com.unity.addressables\AssetBundles"

Write-Host "[1/6] Checking game installation..." -ForegroundColor Yellow
if (-not (Test-Path $gameCache)) {
    Write-Host "  ERROR: Game data not found." -ForegroundColor Red
    Write-Host "  Make sure Astral Party is installed and has been run at least once." -ForegroundColor Red
    exit 1
}
Write-Host "  OK" -ForegroundColor Green

# Find game install dir (for TMP font bundles)
function Find-GameDir {
    $steamRoots = @()
    foreach ($envName in @("PROGRAMFILES(X86)", "PROGRAMFILES")) {
        $p = (Get-Content "env:$envName" -ErrorAction SilentlyContinue)
        if ($p) { $steamRoots += "$p\Steam" }
    }
    $steamRoots += @("D:\Steam", "E:\Steam", "F:\Steam", "G:\Steam", "D:\SteamLibrary", "E:\SteamLibrary")
    $commons = @()
    foreach ($s in $steamRoots) {
        if (Test-Path "$s\steamapps\libraryfolders.vdf") {
            Get-Content "$s\steamapps\libraryfolders.vdf" | ForEach-Object {
                if ($_ -match '"path"\s+"([^"]+)"') { $commons += ($matches[1] -replace '\\\\', '\') + "\steamapps\common" }
            }
        }
        $commons += "$s\steamapps\common"
    }
    foreach ($c in $commons) {
        if (Test-Path "$c\Astral Party\8vJXnINT") { return "$c\Astral Party" }
    }
    return $null
}

$gameDir = Find-GameDir

# --- [2/6] Install font ---
Write-Host ""
Write-Host "[2/6] Installing Thai font (Prompt-Regular)..." -ForegroundColor Yellow
$fontFile = Join-Path $scriptDir "fonts\Prompt-Regular.ttf"
$fontDest = Join-Path $env:WINDIR "Fonts\Prompt-Regular.ttf"

if (-not (Test-Path $fontFile)) {
    Write-Host "  ERROR: Font file missing" -ForegroundColor Red
    exit 1
}

if (Test-Path $fontDest) {
    Write-Host "  Already installed, skipping" -ForegroundColor DarkGray
} else {
    Copy-Item $fontFile $fontDest -Force
    New-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "Prompt Regular (TrueType)" -Value "Prompt-Regular.ttf" -Force | Out-Null
    Write-Host "  Done (font family: Prompt)" -ForegroundColor Green
}

# --- [3/6] Install TSV ---
Write-Host ""
Write-Host "[3/6] Installing translation data..." -ForegroundColor Yellow
$tsvFile = Join-Path $scriptDir "data\clean_thai.tsv"
$tsvDest = Join-Path $localLow "clean_thai.tsv"

if (-not (Test-Path $tsvFile)) {
    Write-Host "  ERROR: Translation file missing" -ForegroundColor Red
    exit 1
}

Copy-Item $tsvFile $tsvDest -Force
Write-Host "  Done" -ForegroundColor Green

# --- [4/6] Install modded bundles (DLL + localization) ---
Write-Host ""
Write-Host "[4/6] Installing modded game bundles..." -ForegroundColor Yellow

# DLL bundle (hotupdate) - font redirect + translation cache + pair adjustments
# Install to ALL known cache paths (the game may use either after updates)
$dllPaths = @(
    "57a198703b66364d5420d39c0d251747\ff3e9df1d11d8ce42fbc742247cefac2",
    "57a198703b66364d5420d39c0d251747\0b399499735aedaf7407a6231d28b0d8"
)
$dllInstalled = 0
foreach ($relPath in $dllPaths) {
    $dllBundleSrc = Join-Path $scriptDir "bundles\hotupdate_dll\$relPath\__data"
    $dllBundleDst = Join-Path $gameCache "$relPath\__data"
    if (Test-Path $dllBundleSrc) {
        $dllDstDir = Split-Path -Parent $dllBundleDst
        if (-not (Test-Path $dllDstDir)) { New-Item -ItemType Directory -Path $dllDstDir -Force | Out-Null }
        Copy-Item $dllBundleSrc $dllBundleDst -Force
        $dllInstalled++
    }
}
if ($dllInstalled -gt 0) {
    Write-Host "  DLL bundle: Done ($dllInstalled paths)" -ForegroundColor Green
} else {
    Write-Host "  ERROR: DLL bundle missing" -ForegroundColor Red
}

# Localization bundle (Thai XML) - install to all available paths
$locBundleSrc = Join-Path $scriptDir "bundles\localization"
$locFiles = Get-ChildItem $locBundleSrc -Recurse -Filter "__data" -ErrorAction SilentlyContinue
$locInstalled = 0
foreach ($f in $locFiles) {
    $relPath = $f.FullName.Substring($locBundleSrc.Length + 1)
    $locBundleDst = Join-Path $gameCache $relPath
    $locDstDir = Split-Path -Parent $locBundleDst
    if (-not (Test-Path $locDstDir)) { New-Item -ItemType Directory -Path $locDstDir -Force | Out-Null }
    Copy-Item $f.FullName $locBundleDst -Force
    $locInstalled++
}
if ($locInstalled -gt 0) {
    Write-Host "  Localization bundle: Done ($locInstalled paths)" -ForegroundColor Green
} else {
    Write-Host "  ERROR: Localization bundle missing" -ForegroundColor Red
}

# --- [5/6] Inject Thai fonts into Addressables cache ---
# The game update moved 5 TMP fonts to CDN delivery (contentupdate_* bundles).
# We pre-place our Thai font clones in the cache so the game loads them
# instead of downloading the originals.
Write-Host ""
Write-Host "[5/6] Injecting Thai fonts into Addressables cache..." -ForegroundColor Yellow

$fontCacheSrc = Join-Path $scriptDir "bundles\font_cache"
$fontCacheFiles = Get-ChildItem $fontCacheSrc -Recurse -Filter "__data" -ErrorAction SilentlyContinue
$fontCacheInstalled = 0
foreach ($f in $fontCacheFiles) {
    $relPath = $f.FullName.Substring($fontCacheSrc.Length + 1)
    $dst = Join-Path $gameCache $relPath
    $dstDir = Split-Path -Parent $dst
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
    # Backup original on first install
    $origBackup = Join-Path $dstDir "__data.original_font"
    if (-not (Test-Path $origBackup) -and (Test-Path $dst)) {
        Copy-Item $dst $origBackup -Force
    }
    Copy-Item $f.FullName $dst -Force
    $fontCacheInstalled++
}
Write-Host "  Injected $fontCacheInstalled Thai font cache entries" -ForegroundColor Green

# --- [5/6] Install TMP font bundles ---
Write-Host ""
Write-Host "[6/6] Installing Thai TMP font bundles..." -ForegroundColor Yellow

$tmpFontsSrc = Join-Path $scriptDir "bundles\tmp_fonts"

if (-not (Test-Path $tmpFontsSrc)) {
    Write-Host "  ERROR: TMP font bundles folder missing" -ForegroundColor Red
} elseif (-not $gameDir) {
    Write-Host "  WARNING: Could not locate Astral Party install dir." -ForegroundColor Red
    Write-Host "  TMP font bundles skipped. Non-TMP fonts will still use Prompt OS font." -ForegroundColor Yellow
} else {
    $aaDir = "$gameDir\8vJXnINT\AstralParty_INT_Data\StreamingAssets\aa\StandaloneWindows64"
    if (-not (Test-Path $aaDir)) {
        Write-Host "  WARNING: StreamingAssets/aa/StandaloneWindows64 not found in: $gameDir" -ForegroundColor Red
    } else {
        $fontBundles = Get-ChildItem $tmpFontsSrc -Filter "font_tmp_assets_*.bundle"
        $installed = 0
        foreach ($b in $fontBundles) {
            $bundleDst = "$aaDir\$($b.Name)"
            $backup = "$bundleDst.original.bak"
            # Backup original on first install
            if (-not (Test-Path $backup) -and (Test-Path $bundleDst)) {
                Copy-Item $bundleDst $backup -Force
            }
            Copy-Item $b.FullName $bundleDst -Force
            $installed++
        }
        Write-Host "  Installed $installed TMP font bundles" -ForegroundColor Green
    }
}

# --- Done ---
Write-Host ""
Write-Host "  ==========================================" -ForegroundColor Green
Write-Host "   Installation Complete!" -ForegroundColor Green
Write-Host "  ==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Launch Astral Party to see Thai translations." -ForegroundColor Cyan
Write-Host ""
