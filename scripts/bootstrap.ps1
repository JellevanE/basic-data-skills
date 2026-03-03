Param(
    [switch]$SetupOnly
)

$ErrorActionPreference = 'Stop'

$RootDir = Split-Path -Parent $PSScriptRoot
Set-Location $RootDir

Write-Host "==> Basic Data Skills bootstrap"
Write-Host "Repo root: $RootDir"

$PythonCmd = $null

# Prefer Python Launcher on Windows
if (Get-Command py -ErrorAction SilentlyContinue) {
    $PythonCmd = "py -3"
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $PythonCmd = "python"
} else {
    Write-Error "Python not found. Install Python 3.11+ first."
}

Write-Host "==> Using Python command: $PythonCmd"
Invoke-Expression "$PythonCmd --version"

if (-not (Test-Path ".venv")) {
    Write-Host "==> Creating virtual environment (.venv)"
    Invoke-Expression "$PythonCmd -m venv .venv"
} else {
    Write-Host "==> Virtual environment already exists (.venv)"
}

$VenvPython = Join-Path $RootDir ".venv\Scripts\python.exe"

Write-Host "==> Installing dependencies into .venv"
& $VenvPython -m pip install --upgrade pip
& $VenvPython -m pip install notebook pandas requests openpyxl

if (-not $SetupOnly) {
    Write-Host "==> Launching Jupyter Notebook..."
    Write-Host "(Close this terminal or press Ctrl+C to stop Jupyter later.)"
    & $VenvPython -m notebook
} else {
    Write-Host ""
    Write-Host "Setup complete. Next steps:"
    Write-Host "  .\.venv\Scripts\Activate.ps1"
    Write-Host "  python -m notebook"
}
