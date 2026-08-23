# Astral Party Thai Mod - One-Click Installer
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
Write-Host "   Astral Party Thai Mod - Installer" -ForegroundColor Cyan
Write-Host "  ==========================================" -ForegroundColor Cyan
Write-Host ""

# --- Detect game path ---
$localLow = Join-Path $env:USERPROFILE "AppData\LocalLow\feimo\AstralParty_INT"
$gameCache = Join-Path $localLow "com.unity.addressables\AssetBundles"

Write-Host "[1/4] Checking game installation..." -ForegroundColor Yellow
if (-not (Test-Path $gameCache)) {
    Write-Host "  ERROR: Game data not found." -ForegroundColor Red
    Write-Host "  Make sure Astral Party is installed and has been run at least once." -ForegroundColor Red
    exit 1
}
Write-Host "  OK" -ForegroundColor Green

# --- Install font ---
Write-Host ""
Write-Host "[2/4] Installing Thai font..." -ForegroundColor Yellow
$fontFile = Join-Path $scriptDir "fonts\Prompt-Thai-Stacked.ttf"
$fontDest = Join-Path $env:WINDIR "Fonts\Prompt-Thai-Stacked.ttf"

if (-not (Test-Path $fontFile)) {
    Write-Host "  ERROR: Font file missing" -ForegroundColor Red
    exit 1
}

if (Test-Path $fontDest) {
    Write-Host "  Already installed, skipping" -ForegroundColor DarkGray
} else {
    Copy-Item $fontFile $fontDest -Force
    New-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "Prompt Thai Stacked (TrueType)" -Value "Prompt-Thai-Stacked.ttf" -Force | Out-Null
    Write-Host "  Done" -ForegroundColor Green
}

# --- Install TSV ---
Write-Host ""
Write-Host "[3/4] Installing translation data..." -ForegroundColor Yellow
$tsvFile = Join-Path $scriptDir "data\thai_tab.tsv"
$tsvDest = Join-Path $localLow "thai_tab.tsv"

if (-not (Test-Path $tsvFile)) {
    Write-Host "  ERROR: Translation file missing" -ForegroundColor Red
    exit 1
}

Copy-Item $tsvFile $tsvDest -Force
Write-Host "  Done" -ForegroundColor Green

# --- Install bundles ---
Write-Host ""
Write-Host "[4/4] Installing modded game bundles..." -ForegroundColor Yellow

# DLL bundle (hotupdate) - font redirect + translation cache
$dllBundleSrc = Join-Path $scriptDir "bundles\hotupdate_dll\__data"
$dllBundleDst = Join-Path $gameCache "57a198703b66364d5420d39c0d251747\0b399499735aedaf7407a6231d28b0d8\__data"

if (Test-Path $dllBundleSrc) {
    $dllDstDir = Split-Path -Parent $dllBundleDst
    if (-not (Test-Path $dllDstDir)) { New-Item -ItemType Directory -Path $dllDstDir -Force | Out-Null }
    Copy-Item $dllBundleSrc $dllBundleDst -Force
    Write-Host "  DLL bundle: Done" -ForegroundColor Green
} else {
    Write-Host "  ERROR: DLL bundle missing" -ForegroundColor Red
}

# Localization bundle (Thai XML)
$locBundleSrc = Join-Path $scriptDir "bundles\localization\__data"
$locBundleDst = Join-Path $gameCache "f138d1971657be74d0155ab4d3cae489\c46f44479ac51ea2599b923ef9727291\__data"

if (Test-Path $locBundleSrc) {
    $locDstDir = Split-Path -Parent $locBundleDst
    if (-not (Test-Path $locDstDir)) { New-Item -ItemType Directory -Path $locDstDir -Force | Out-Null }
    Copy-Item $locBundleSrc $locBundleDst -Force
    Write-Host "  Localization bundle: Done" -ForegroundColor Green
} else {
    Write-Host "  ERROR: Localization bundle missing" -ForegroundColor Red
}

# --- Done ---
Write-Host ""
Write-Host "  ==========================================" -ForegroundColor Green
Write-Host "   Installation Complete!" -ForegroundColor Green
Write-Host "  ==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Launch Astral Party to see Thai translations." -ForegroundColor Cyan
Write-Host ""
