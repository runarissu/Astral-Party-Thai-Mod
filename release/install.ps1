# Astral Party Thai Mod v1.4.0 - One-Click Installer
# Usage: Double-click install.bat
# Supports Astral Party 3.3.0+ (INT) — game 3.3.0 moved the Addressables
# cache from LocalLow into the game installation folder.

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
Write-Host "   Astral Party Thai Mod v1.4.0 - Installer" -ForegroundColor Cyan
Write-Host "  ==========================================" -ForegroundColor Cyan
Write-Host ""

# --- Detect game paths ---
$localLow = Join-Path $env:USERPROFILE "AppData\LocalLow\feimo\AstralParty_INT"

# Find game install dir (Steam libraries)
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

Write-Host "[1/6] Checking game installation..." -ForegroundColor Yellow
$gameDir = Find-GameDir

# Game 3.3.0+ stores downloaded Addressables inside the game install;
# older versions used LocalLow. Prefer the active in-game location.
$gameCache = $null
if ($gameDir) {
    $candidate = Join-Path $gameDir "8vJXnINT\AstralParty_INT_Data\com.unity.addressables\AssetBundles"
    if (Test-Path $candidate) { $gameCache = $candidate }
}
if (-not $gameCache) {
    $candidate = Join-Path $localLow "com.unity.addressables\AssetBundles"
    if (Test-Path $candidate) { $gameCache = $candidate }
}
if (-not $gameCache) {
    Write-Host "  ERROR: Game data not found." -ForegroundColor Red
    Write-Host "  Make sure Astral Party 3.3.0+ is installed and has been run at least once." -ForegroundColor Red
    exit 1
}
Write-Host "  OK ($gameCache)" -ForegroundColor Green

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

# --- [3/6] Install TSV + FairyGUI XML ---
Write-Host ""
Write-Host "[3/6] Installing translation data..." -ForegroundColor Yellow
$tsvFile = Join-Path $scriptDir "data\clean_thai.tsv"
$tsvDest = Join-Path $localLow "clean_thai.tsv"

if (-not (Test-Path $tsvFile)) {
    Write-Host "  ERROR: Translation file missing" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $localLow)) { New-Item -ItemType Directory -Path $localLow -Force | Out-Null }
Copy-Item $tsvFile $tsvDest -Force
Write-Host "  clean_thai.tsv: Done" -ForegroundColor Green

# The patched runtime reads this XML from persistentDataPath for FairyGUI
# (menu/guild/settings text) — required for full UI translation.
$thaiXmlFile = Join-Path $scriptDir "data\localization_Thai.xml"
$thaiXmlDest = Join-Path $localLow "localization_Thai.xml"
if (-not (Test-Path $thaiXmlFile)) {
    Write-Host "  ERROR: localization_Thai.xml missing" -ForegroundColor Red
    exit 1
}
Copy-Item $thaiXmlFile $thaiXmlDest -Force
Write-Host "  localization_Thai.xml: Done" -ForegroundColor Green

# --- [4/6] Install modded bundles (DLL + localization) ---
Write-Host ""
Write-Host "[4/6] Installing modded game bundles..." -ForegroundColor Yellow

# DLL bundle (hotupdate) - font redirect + translation cache + pair adjustments
# Read cache paths from manifest (supports game updates that change cache paths)
$dllManifest = Join-Path $scriptDir "bundles\hotupdate_dll\_cache_paths.txt"
if (Test-Path $dllManifest) {
    $dllPaths = Get-Content $dllManifest | Where-Object { $_.Trim() } | ForEach-Object { $_.Trim() }
} else {
    # Fallback to known paths
    $dllPaths = @(
        "57a198703b66364d5420d39c0d251747\8cc684d4b3b979e86b5788b7f1814132"
    )
}
$dllInstalled = 0
foreach ($relPath in $dllPaths) {
    $dllBundleSrc = Join-Path $scriptDir "bundles\hotupdate_dll\$relPath\__data"
    $dllBundleDst = Join-Path $gameCache "$relPath\__data"
    if (Test-Path $dllBundleSrc) {
        if (-not (Test-Path $dllBundleDst)) {
            Write-Host "  ERROR: Game bundle not found: $relPath" -ForegroundColor Red
            Write-Host "  Your game version may not match this mod (requires Astral Party 3.3.0)." -ForegroundColor Yellow
            Write-Host "  Update the game on Steam, launch it once, then re-run the installer." -ForegroundColor Yellow
            exit 1
        }
        # Backup original on first install
        $origBackup = Join-Path (Split-Path -Parent $dllBundleDst) "__data.original.bak"
        if (-not (Test-Path $origBackup)) {
            Copy-Item $dllBundleDst $origBackup -Force
        }
        Copy-Item $dllBundleSrc $dllBundleDst -Force
        $dllInstalled++
    }
}
if ($dllInstalled -gt 0) {
    Write-Host "  DLL bundle: Done ($dllInstalled paths)" -ForegroundColor Green
} else {
    Write-Host "  ERROR: DLL bundle missing" -ForegroundColor Red
    exit 1
}

# Localization bundle (Thai XML) - install to all available paths
$locBundleSrc = Join-Path $scriptDir "bundles\localization"
$locFiles = Get-ChildItem $locBundleSrc -Recurse -Filter "__data" -ErrorAction SilentlyContinue
$locInstalled = 0
foreach ($f in $locFiles) {
    $relPath = $f.FullName.Substring($locBundleSrc.Length + 1)
    $locBundleDst = Join-Path $gameCache $relPath
    if (-not (Test-Path $locBundleDst)) {
        Write-Host "  WARNING: Localization cache target not found: $relPath (skipped)" -ForegroundColor Yellow
        continue
    }
    $origBackup = Join-Path (Split-Path -Parent $locBundleDst) "__data.original.bak"
    if (-not (Test-Path $origBackup)) {
        Copy-Item $locBundleDst $origBackup -Force
    }
    Copy-Item $f.FullName $locBundleDst -Force
    $locInstalled++
}
if ($locInstalled -gt 0) {
    Write-Host "  Localization bundle: Done ($locInstalled paths)" -ForegroundColor Green
} else {
    Write-Host "  WARNING: No localization bundles installed" -ForegroundColor Yellow
}

# --- [5/6] Inject Thai fonts into Addressables cache ---
# Game 3.3.0 delivers 3 TMP fonts via the remote catalog. We pre-place our
# Thai clones in the cache so the game loads them instead of downloading.
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

# --- [6/6] Install local TMP font bundles (StreamingAssets) ---
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
        # Game 3.3.0 uses hash-named local bundles; install only where the
        # original file exists so we never add stale files for other versions.
        $fontBundles = Get-ChildItem $tmpFontsSrc -Filter "*.bundle"
        $installed = 0
        foreach ($b in $fontBundles) {
            $bundleDst = "$aaDir\$($b.Name)"
            $backup = "$bundleDst.original.bak"
            if (-not (Test-Path $bundleDst)) {
                Write-Host "  Skip (not in game): $($b.Name)" -ForegroundColor DarkGray
                continue
            }
            # Backup original on first install
            if (-not (Test-Path $backup)) {
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
