#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

LAUNCH_JUPYTER=true
if [[ "${1:-}" == "--setup-only" ]]; then
  LAUNCH_JUPYTER=false
fi

echo "==> Basic Data Skills bootstrap"
echo "Repo root: $ROOT_DIR"

PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="python"
else
  echo "ERROR: Python not found. Install Python 3.11+ first."
  exit 1
fi

echo "==> Using Python: $PYTHON_BIN"
"$PYTHON_BIN" --version

if [[ ! -d ".venv" ]]; then
  echo "==> Creating virtual environment (.venv)"
  "$PYTHON_BIN" -m venv .venv
else
  echo "==> Virtual environment already exists (.venv)"
fi

echo "==> Installing dependencies into .venv"
"$ROOT_DIR/.venv/bin/python" -m pip install --upgrade pip
"$ROOT_DIR/.venv/bin/python" -m pip install notebook pandas requests openpyxl

echo
if [[ "$LAUNCH_JUPYTER" == true ]]; then
  echo "==> Launching Jupyter Notebook..."
  echo "(Use Ctrl+C in this terminal to stop Jupyter later.)"
  exec "$ROOT_DIR/.venv/bin/python" -m notebook
else
  echo "Setup complete. Next steps:"
  echo "  source .venv/bin/activate"
  echo "  python -m notebook"
fi
