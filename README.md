# Basic Data Skills

Hands-on training material for learning Python + API fundamentals with a storyline.

## What's in this repo

- 7 learner notebooks in `notebooks/` (0–6, all available)
- 6 completed solution notebooks in `solutions/` (notebooks 1–6; notebook 0 is setup-only)
- 1 quick reference in `cheatsheet/api_data_skills_cheatsheet.md`
- First-run guide in `docs/FIRST_TIME_SETUP.md`
- Optional helper scripts in `scripts/bootstrap.sh` (macOS/Linux) and `scripts/bootstrap.ps1` (Windows)

## Learning path

Start with notebook 0, then continue in order:

1. `0_setup_and_sneak_peek.ipynb` — setup + first live API demo
2. `1_python_values_and_variables.ipynb` — variables, types, f-strings, imports
3. `2_python_collections_and_loops.ipynb` — lists, dicts, `.get()`, nesting, loops
4. `3_your_first_api_calls.ipynb` — first `requests.get()`, status codes
5. `4_working_with_api_data.ipynb` — query params, Open-Meteo, auth concepts, pagination
6. `5_transforming_and_saving_data.ipynb` — loops → pandas DataFrames, select/filter/sort, derived columns, CSV/Excel/JSON export
7. `6_errors_troubleshooting_and_finale.ipynb` — error handling, debugging, case-closing finale

Optional extra, outside the storyline:

- `A_reading_swagger_api_docs.ipynb` — appendix: reading a Swagger/OpenAPI documentation page

---

## Get the files (one-time)

If you do not have the files locally yet:

```bash
git clone https://github.com/JellevanE/basic-data-skills.git
cd basic-data-skills
```

If `git` is not installed, install Git first, then rerun the commands above.
See: [Install Git](https://git-scm.com/install/)

---

## Quick start (recommended)

Use one command, then open notebook 0.

### macOS/Linux

```bash
bash scripts/bootstrap.sh
```

### Windows PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1
```

The helper script will:
- create `.venv` if needed
- install required packages
- launch Jupyter Notebook

Then open:
- `notebooks/0_setup_and_sneak_peek.ipynb`

---

## Full manual setup (step-by-step)

If you prefer to run each step yourself, follow this section.

For an expanded version with troubleshooting, also see:
- `docs/FIRST_TIME_SETUP.md`

### 1) Install Python

Use Python 3.11+.

Check installation:

```bash
python3 --version
```

If `python3` is not available, try:

```bash
python --version
```

### 2) Create and activate a virtual environment

From the repo root:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

On Windows (PowerShell), activation is:

```powershell
.venv\Scripts\Activate.ps1
```

### 3) Install dependencies

```bash
pip install --upgrade pip
pip install notebook pandas requests openpyxl nbstripout
```

### 4) Launch Jupyter

From the repo root:

```bash
python -m notebook
```

Open `notebooks/0_setup_and_sneak_peek.ipynb` first.

---

## Optional setup-only mode (no auto-launch)

Use this if you want the script to install only and not start Jupyter.

### macOS/Linux

```bash
bash scripts/bootstrap.sh --setup-only
```

### Windows PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1 -SetupOnly
```

Then start manually:

```bash
source .venv/bin/activate
python -m notebook
```

---

## Daily workflow (after first setup)

Each time you return:

1. Open terminal
2. `cd` to this repo
3. Activate env (`source .venv/bin/activate` on macOS/Linux)
4. Run `python -m notebook`
5. Continue with the next notebook

---

## Quick troubleshooting

| Problem | What to check |
|---|---|
| `python3` not found | Try `python`, verify Python installation |
| `pip`/`jupyter` not found | Activate virtual environment first |
| Notebook kernel won’t start | Restart Jupyter, reselect Python kernel |
| API call fails | Check internet/VPN/proxy and retry |
| Excel export fails | Ensure `openpyxl` is installed |

---

## Tips for a smooth first run

### Browser/Jupyter tips

- Chrome works well for notebook rendering and widget behavior.
- Use **Shift+Enter** to run the active cell.
- Run cells top-to-bottom; many examples depend on earlier variables.
- If outputs look stale, use **Kernel → Restart & Run All**.

### API/network tips

- First API calls may fail on corporate networks (VPN/proxy/certificates).
- If you see SSL/proxy/timeouts, retry once, then check VPN/proxy settings.
- If an API is temporarily down, continue with explanation cells and return later.

### Environment tips

- If `python -m notebook` fails, your env is likely not activated.
- If package install fails, upgrade pip first:

```bash
python -m pip install --upgrade pip
```

- Then reinstall required packages.

---

## Keeping notebooks clean (nbstripout)

Jupyter saves cell outputs (printed text, tables, images) inside the `.ipynb` JSON. Once a notebook has been executed, the file carries all of that output — which makes git diffs noisy and inflates file size. [`nbstripout`](https://github.com/kynan/nbstripout) removes outputs in place, leaving just the source cells. It's already listed in the dependency install above.

### Strip outputs from every notebook in the repo

From the repo root:

```bash
nbstripout notebooks/*.ipynb solutions/*.ipynb
```

Safe to run repeatedly — only files that actually contain outputs get rewritten. Useful right before staging notebook changes, or after running a notebook end-to-end to validate it.

### Make it automatic (recommended)

Install `nbstripout` once as a git filter so outputs are stripped on every commit, with no manual step:

```bash
nbstripout --install
```

This adds a clean filter to your `.git/config` and a `.gitattributes` entry. After that, committed `.ipynb` files will never carry outputs — your working copy stays as you ran it, but the version git sees is always stripped.
