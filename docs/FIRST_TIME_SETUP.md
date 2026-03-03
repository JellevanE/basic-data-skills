# First-time setup (outside notebooks)

Use this guide **before** working through the notebooks.

## Option A (recommended): run commands manually

### 1) Check Python

```bash
python3 --version
```

If `python3` is unavailable, try:

```bash
python --version
```

Target: Python 3.11+

### 2) Create a virtual environment

From the repo root:

```bash
python3 -m venv .venv
```

If your machine uses `python` instead:

```bash
python -m venv .venv
```

### 3) Activate the environment

macOS/Linux:

```bash
source .venv/bin/activate
```

Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

Windows CMD:

```bat
.venv\Scripts\activate
```

### 4) Install packages

```bash
pip install --upgrade pip
pip install jupyter pandas requests openpyxl
```

### 5) Launch Jupyter

```bash
jupyter notebook
```

Then open [notebooks/0_setup_and_sneak_peek.ipynb](../notebooks/0_setup_and_sneak_peek.ipynb).

---

## Option B: run the helper script (macOS/Linux)

From repo root:

```bash
bash scripts/bootstrap.sh
```

What it does:
- checks `python3`/`python`
- creates `.venv` if missing
- upgrades `pip`
- installs required packages
- launches Jupyter Notebook automatically

If you only want setup (no auto-launch), use:

```bash
bash scripts/bootstrap.sh --setup-only
```

Then run:

```bash
source .venv/bin/activate
jupyter notebook
```

---

## Option C: run the helper script (Windows PowerShell)

From repo root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1
```

What it does:
- checks `py -3` first, then `python`
- creates `.venv` if missing
- upgrades `pip`
- installs required packages
- launches Jupyter Notebook automatically

If you only want setup (no auto-launch), use:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1 -SetupOnly
```

Then run:

```powershell
.\.venv\Scripts\Activate.ps1
jupyter notebook
```

---

## Quick checks

Inside activated environment:

```bash
python -c "import requests, pandas, openpyxl; print('ok')"
jupyter --version
```

---

## Common first-run issues

- `python3: command not found` -> try `python`; if missing, install Python 3.11+
- `pip` not found -> run `python -m pip --version`
- SSL/proxy timeout on install -> connect VPN and retry, or ask IT for proxy config
- `jupyter: command not found` -> ensure environment is activated and reinstall jupyter
