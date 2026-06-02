# Safe `.ipynb` editing + validation

Notebooks are JSON. The `source` of every cell is a list of strings (one per line, with `\n` baked into all but the last). Hand-editing via byte-level tools (`Edit` with escaped JSON, sed, manual quoting) is brittle: one missing `\n` or unescaped quote corrupts the file in ways that surface only when Jupyter tries to open it.

**The rule:** edit `.ipynb` files only via a Python script that uses `json.loads` and `json.dumps`. That way the JSON layer is the JSON library's problem, not yours.

## The template

This template is what's been used across this repo's review sessions. Copy it, replace the cell content, run it.

```python
"""Apply edits to notebook N (learner + solutions)."""
import json
from pathlib import Path

LEARNER = Path("/abs/path/to/notebooks/N_xxx.ipynb")
SOLUTIONS = Path("/abs/path/to/solutions/N_xxx_solutions.ipynb")

# --- New cell sources (plain strings; converted to source arrays below) ---

NEW_CELL_X = """\
---
## X.Y Section title

Theory paragraph here.

```python
example_code()
```

Continuation prose."""

NEW_CELL_Y_CODE = """\
# Runnable demo code
response = requests.get("https://example.com/api")
print(response.status_code)"""


def to_source_array(text: str) -> list[str]:
    """Convert a plain string to Jupyter's source-array format:
    a list of lines, each ending with \\n except the last."""
    lines = text.split("\n")
    return [line + "\n" for line in lines[:-1]] + [lines[-1]]


def make_markdown_cell(text: str) -> dict:
    return {
        "cell_type": "markdown",
        "metadata": {},
        "source": to_source_array(text),
    }


def make_code_cell(text: str) -> dict:
    return {
        "cell_type": "code",
        "execution_count": None,
        "metadata": {},
        "outputs": [],
        "source": to_source_array(text),
    }


def replace_cell(nb: dict, idx: int, new_text: str) -> str:
    """Replace a cell's source in place. Clears outputs on code cells."""
    cell = nb["cells"][idx]
    old_first = (
        cell["source"][0]
        if isinstance(cell["source"], list)
        else cell["source"].splitlines()[0]
    )
    cell["source"] = to_source_array(new_text)
    if cell["cell_type"] == "code":
        cell["outputs"] = []
        cell["execution_count"] = None
    return old_first[:60]


REPLACEMENTS = {
    5: NEW_CELL_X,        # markdown cell
    6: NEW_CELL_Y_CODE,   # code cell
}


def apply(path: Path) -> None:
    nb = json.loads(path.read_text())
    for idx, new_text in REPLACEMENTS.items():
        old = replace_cell(nb, idx, new_text)
        print(f"  cell {idx}: was {old!r}")
    # Write with same formatting as Jupyter (indent=1, trailing newline)
    path.write_text(json.dumps(nb, indent=1, ensure_ascii=False) + "\n")
    print(f"  saved {path.name}")


print(f"Editing {LEARNER}")
apply(LEARNER)
print(f"Editing {SOLUTIONS}")
apply(SOLUTIONS)
```

Run it: `python3 /tmp/my_edit.py`.

## Cell schema (nbformat 4.4)

Existing cells in this repo's notebooks use this minimal schema (no `id` field):

**Markdown cell:**
```json
{
  "cell_type": "markdown",
  "metadata": {},
  "source": ["line 1\n", "line 2\n", "last line without newline"]
}
```

**Code cell:**
```json
{
  "cell_type": "code",
  "execution_count": null,
  "metadata": {},
  "outputs": [],
  "source": ["import foo\n", "foo.bar()"]
}
```

Other nbformat versions (4.5+) require an `id` field on every cell. If the notebook you're editing has `id` fields on existing cells, add one to your new cells too (any unique string is fine — a short slug works).

## Inserting cells without breaking indices

If you're inserting AND replacing in the same script, replace at the original indices FIRST, then insert. That way the replacement targets don't shift while you're working.

```python
# Step 1: replace cells 5 and 28 in place (indices stay 5 and 28)
replace_cell(nb, 5, NEW_INTRO)
replace_cell(nb, 28, NEW_CHECKPOINT)

# Step 2: insert two new cells between 6 and 7
# After this, what was cell 7 becomes 9, what was cell 28 becomes 30
nb["cells"].insert(7, make_markdown_cell(EXERCISE_MARKDOWN))
nb["cells"].insert(8, make_code_cell(EXERCISE_STARTER))
```

If you absolutely must replace at an index AFTER inserting, do the inserts first and recompute the new indices yourself.

## Asymmetric edits (learner vs. solutions)

Some cells diverge: the learner has a starter with `# YOUR CODE HERE`, the solutions has working code. Pattern:

```python
COMMON = {
    5: NEW_INTRO,           # markdown — same in both
    28: NEW_CHECKPOINT,     # checkpoint — same in both
}
LEARNER_ONLY = {
    7: STARTER_CODE,        # placeholder version
}
SOLUTIONS_ONLY = {
    7: WORKING_CODE,        # actual solution
}

def apply_set(path, replacements):
    ...

apply_set(LEARNER, {**COMMON, **LEARNER_ONLY})
apply_set(SOLUTIONS, {**COMMON, **SOLUTIONS_ONLY})
```

The markdown cells around the exercise (prompts, headings) should always be COMMON. Only the code starter ↔ solution differs.

## Validation workflow

After every edit, run two checks. Both are fast.

### 1. JSON parses

```bash
python3 -c "import json; json.loads(open('path/to/notebook.ipynb').read()); print('OK')"
```

If this fails, the edit script corrupted something — undo and investigate before going further.

### 2. Solutions notebook executes end-to-end

```bash
source .venv/bin/activate
jupyter nbconvert --to notebook --execute solutions/N_xxx_solutions.ipynb \
    --output /tmp/validate.ipynb 2>&1 | tail -5
```

Then grep the executed output for the success markers:

```bash
jq -r '.cells[] | select(.cell_type=="code") | .outputs[]? | select(.output_type=="stream") | .text | if type=="array" then join("") else . end' /tmp/validate.ipynb | grep -E "All checks passed|Clue [0-9]+ collected"
```

You should see:
```
All checks passed — you're ready for the clue.
>>> Clue N collected!
```

If either is missing, the checkpoint or clue failed — re-run with `tail -50` to see the actual stack trace.

### Inspecting a specific cell's output

To see what a specific cell printed during validation:

```bash
jq -r '.cells[INDEX].outputs[]? | select(.output_type=="stream") | .text | if type=="array" then join("") else . end' /tmp/validate.ipynb
```

Useful for sanity-checking that a demo printed what you expected (e.g., "Got data for Netherlands" — not "Caribbean Netherlands").

## Structural diff between learner and solutions

After editing both, confirm they still mirror each other:

```bash
# Cell-type sequence should be identical
diff <(jq -r '.cells | map(.cell_type) | .[]' notebooks/N_xxx.ipynb) \
     <(jq -r '.cells | map(.cell_type) | .[]' solutions/N_xxx_solutions.ipynb)

# Markdown cells should be identical content-wise
# (Replace 5 with the indices of cells you expect to be shared)
diff <(jq -r '.cells[5].source | join("")' notebooks/N_xxx.ipynb) \
     <(jq -r '.cells[5].source | join("")' solutions/N_xxx_solutions.ipynb)
```

Either should print nothing (the structural form) or the same content (the markdown form).

## Why this matters

A `.ipynb` file with valid-looking JSON but inconsistent state will *open* in Jupyter — but cells will error on execution in confusing ways. By the time you notice, the bad commit may already be merged. The script-edit + nbconvert-execute loop catches this in seconds.
