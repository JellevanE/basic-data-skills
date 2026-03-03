# Basic Data Skills

Hands-on training material for learning Python + API fundamentals with a practical "Data Detective" storyline.

## What is in this repo

- 7 learner notebooks in `notebooks/` (0 to 6)
- 6 completed solution notebooks in `solutions/` (1 to 6)
- 1 quick reference in `cheatsheet/api_data_skills_cheatsheet.md`
- First-run guide in `docs/FIRST_TIME_SETUP.md`
- Optional helper script in `scripts/bootstrap.sh`
- Planning docs in `api-skills-plan.md` and `implementation-plan.md`

## Learning path

Start with notebook 0, then continue in order:

1. `0_setup_and_sneak_peek.ipynb` — setup + first live API demo
2. `1_python_values_and_variables.ipynb` — variables, types, f-strings, imports
3. `2_python_collections_and_loops.ipynb` — lists, dicts, `.get()`, nesting, loops
4. `3_your_first_api_calls.ipynb` — first `requests.get()`, status codes
5. `4_working_with_api_data.ipynb` — query params, Open-Meteo, auth concepts, pagination
6. `5_transforming_and_saving_data.ipynb` — loops → pandas, filter/sort, CSV/Excel export
7. `6_errors_troubleshooting_and_finale.ipynb` — error handling, debugging, finale certificate

## Data Detective thread (clues)

Each notebook ends with a clue challenge:

1. `52.37` (latitude)
2. `4.89` (longitude)
3. `~17` (population in millions)
4. `~53` (number of countries)
5. country name (full data pipeline)
6. finale validates clues, makes a live weather API call, prints certificate

---

## First-time setup (recommended)

If you prefer a dedicated setup document (outside notebooks), use:

- `docs/FIRST_TIME_SETUP.md` (manual steps + troubleshooting)
- `scripts/bootstrap.sh` (optional macOS/Linux helper, auto-opens Jupyter)

Quick run for the helper:

```bash
bash scripts/bootstrap.sh
```

If you want setup only (no auto-launch):

```bash
bash scripts/bootstrap.sh --setup-only
```

Then continue with the manual steps below (activate env + launch Jupyter), or directly open notebook 0.

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
pip install jupyter pandas requests openpyxl
```

### 4) Launch Jupyter

From the repo root:

```bash
jupyter notebook
```

Open `notebooks/0_setup_and_sneak_peek.ipynb` first.

---

## Daily workflow (after first setup)

Every time you come back:

1. Open terminal
2. `cd` to this repo
3. Activate env (`source .venv/bin/activate` on macOS/Linux)
4. Run `jupyter notebook`
5. Continue with the next notebook

---

## Tips for running this smoothly the first time

### Browser/Jupyter tips

- Chrome works well for notebook rendering and widget behavior.
- Use **Shift+Enter** to run the active cell.
- Run cells top-to-bottom; many examples depend on earlier variables.
- If outputs look stale, use **Kernel → Restart & Run All**.

### API/network tips

- First API calls may fail on corporate networks (VPN/proxy/certificates).
- If you see SSL/proxy/timeouts, retry once, then check VPN/proxy settings.
- Keep the exercises moving: if an API is temporarily down, continue with explanation cells and return later.

### Environment tips

- If `jupyter` is "not found", your env is likely not activated.
- If package install fails, upgrade pip first:

```bash
python -m pip install --upgrade pip
```

- Then reinstall required packages.

---

## Working with solutions

- Learners use notebooks in `notebooks/`
- Facilitators can validate answers with files in `solutions/`
- Notebook 0 intentionally has no separate solutions file

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

## Suggested facilitator smoke test

Before a training session, quickly run:

1. Notebook 0 demo cell (API + table + file save)
2. One API cell in notebook 3
3. One Open-Meteo cell in notebook 4
4. Finale cell in notebook 6

This verifies package setup, live API access, and end-to-end flow.
