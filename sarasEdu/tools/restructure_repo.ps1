<#
Safe repo restructure script for SarasEdu

What it does (when you run it):
- Creates `frontend/` and `backend/` directories
- Moves likely frontend files into `frontend/` (index.html, package.json, vite.config.js, jsconfig.json, src/)
- Moves existing `database/` into `backend/database/` (if present)
- Leaves `docs/` where it is (docs/ already exists)

Important: This script only moves files that exist and prints actions. Review the output before confirming.
Run it from the repo root (where this script is located):
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; .\restructure_repo.ps1
#>

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $repoRoot

$frontendDir = Join-Path $repoRoot 'frontend'
$backendDir = Join-Path $repoRoot 'backend'

Write-Host "Creating folders if missing..."
New-Item -ItemType Directory -Force -Path $frontendDir | Out-Null
New-Item -ItemType Directory -Force -Path $backendDir | Out-Null

$moveList = @(
    'index.html',
    'package.json',
    'package-lock.json',
    'vite.config.js',
    'jsconfig.json',
    'src',
    'src\assets',
    'src\components',
    'src\contexts',
    'src\styles',
    'src\main.jsx',
    'src\App.jsx',
    'README.md'
)

foreach ($item in $moveList) {
    $src = Join-Path $repoRoot $item
    if (Test-Path $src) {
        $dest = Join-Path $frontendDir (Split-Path $item -Leaf)
        Write-Host "Moving $item -> frontend/"
        Move-Item -Force -Path $src -Destination $frontendDir
    } else {
        Write-Host "Skipping (not found): $item"
    }
}

# Move database/ into backend/
if (Test-Path (Join-Path $repoRoot 'database')) {
    Write-Host "Moving existing 'database/' to 'backend/database/'"
    New-Item -ItemType Directory -Force -Path (Join-Path $backendDir 'database') | Out-Null
    Move-Item -Force -Path (Join-Path $repoRoot 'database') -Destination (Join-Path $backendDir 'database')
} else {
    Write-Host "No 'database/' folder found to move."
}

# Create helpful README files if missing
$feReadme = Join-Path $frontendDir 'README.md'
if (-not (Test-Path $feReadme)) {
    @"
# frontend

This folder contains the frontend application (React + Vite). After running the restructure script, frontend resources are moved here.

- To run locally (from repo root):
  1) cd frontend
  2) npm install
  3) npm run dev

"@" | Out-File -FilePath $feReadme -Encoding UTF8
    Write-Host "Created frontend/README.md"
}

$beReadme = Join-Path $backendDir 'README.md'
if (-not (Test-Path $beReadme)) {
    @"
# backend

This folder is reserved for backend work (Django + MySQL recommended).
Place backend code here. I created a `backend/db/schema.sql` file that sources the SQL in `docs/`.

"@" | Out-File -FilePath $beReadme -Encoding UTF8
    Write-Host "Created backend/README.md"
}

Write-Host "Restructure script finished. Review moved files in the 'frontend' and 'backend' folders."
Pop-Location
