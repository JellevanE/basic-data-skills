# Checkpoint anatomy

Checkpoints are the autograder. A good one fails loudly when the learner is wrong, points them at what to fix, and unlocks downstream content (the clue, the next section) only when everything passes.

This document walks through the anatomy of a checkpoint cell using the §4.8 checkpoint from this repo as a worked example.

## Structure

```python
# Run this cell to check your understanding.

# 1. Required variables list
required_vars = [
    "countries_basic",
    "first_country",
    "western_europe_countries",
    "brussels_temp",
    "berlin_temp",
    "euro_countries",
    "country_populations",
    "pokemon_names",
]

# 2. Existence check
missing = [v for v in required_vars if v not in globals() or globals()[v] is None]
assert not missing, f"Missing or unfinished: {missing}. Go back and complete those exercises."

# 3. Per-exercise assertions (type + content)
# 4.1 - countries_basic + first_country
assert isinstance(countries_basic, list) and len(countries_basic) > 100, (
    f"countries_basic should be a list of 100+ countries, got "
    f"{type(countries_basic).__name__} len="
    f"{len(countries_basic) if isinstance(countries_basic, list) else 'n/a'}"
)
assert isinstance(first_country, dict) and "name" in first_country, (
    "first_country should be a dict with a 'name' key"
)

# ... [more per-exercise blocks] ...

# 4.7 - pokemon_names (tightest check: exact count + type + content)
assert isinstance(pokemon_names, list) and len(pokemon_names) == 30, (
    f"pokemon_names should have exactly 30 entries, got "
    f"{len(pokemon_names) if isinstance(pokemon_names, list) else 'n/a'}"
)
assert all(isinstance(n, str) for n in pokemon_names), (
    "All entries in pokemon_names should be strings (the 'name' field of each result)"
)

# 4. Unlock flag
notebook4_ready_for_clue = True
print("All checks passed — you're ready for the clue.")
```

## The four parts

### 1. Required variables list

A flat list of every variable name the checkpoint expects. Keep this at the top so a reviewer can see at a glance which exercises this checkpoint covers, and so the existence check can iterate it.

Rule: every promise in "What you'll learn" should be backed by at least one variable in this list. If you can't find the variable corresponding to a learning goal, the goal isn't being exercised — fix the exercises or trim the promise.

### 2. Existence check

```python
missing = [v for v in required_vars if v not in globals() or globals()[v] is None]
assert not missing, f"Missing or unfinished: {missing}. Go back and complete those exercises."
```

Why this comes first: if the learner hasn't done the work, you want a clear "you have these exercises left" message, not a cascade of `TypeError: 'NoneType' has no attribute '...'` from the per-exercise checks.

Two ways a variable can be "missing":
- Not defined at all (skipped the cell) → `v not in globals()`
- Defined as the starter placeholder `None` (cell run but not edited) → `globals()[v] is None`

Both cases get the same friendly message: "Missing or unfinished".

### 3. Per-exercise assertions

For each exercise, two checks: **type** and **content**.

**Type check first**, otherwise content checks raise on the wrong path:

```python
# WRONG — if pokemon_names is a dict, len() works but the content check fails confusingly
assert len(pokemon_names) == 30 and all(isinstance(n, str) for n in pokemon_names), ...

# RIGHT — short-circuit on type
assert isinstance(pokemon_names, list) and len(pokemon_names) == 30, ...
assert all(isinstance(n, str) for n in pokemon_names), ...
```

**Content check matches expectation tightly:**

| Loose | Tight | Why tight is better |
|---|---|---|
| `len(x) >= 3` | `len(x) == 4` | Catches silent drops |
| `isinstance(x, dict)` | `isinstance(x, dict) and all(k in x for k in ["a", "b", "c"])` | Catches missing keys |
| `x > 0` | `100 <= x <= 200` | Catches wrong units or scale |
| (no content check) | `assert all(isinstance(v, int) for v in x.values())` | Catches type mistakes inside containers |

**Error messages include what the learner actually has:**

```python
# Bad: gives no diagnostic
assert len(x) == 30, "wrong length"

# Good: tells them what they have
assert len(x) == 30, f"Expected 30 entries, got {len(x)}: did you fetch both pages?"
```

The `f"... got {len(x) if isinstance(x, ...) else 'n/a'}"` pattern handles the case where the assertion is checking BOTH type and length — if the type was wrong, `len()` would itself raise, so we guard it with `'n/a'`.

### 4. Unlock flag + print

```python
notebook4_ready_for_clue = True
print("All checks passed — you're ready for the clue.")
```

The clue cell is gated by this flag:

```python
# In the clue cell:
assert notebook4_ready_for_clue, "Run the 4.8 checkpoint first."
```

Why this matters: without the flag, a learner can run the clue cell directly and either solve it wrong (the demo of the clue uses placeholders that they fill in) or be tempted to skip the checkpoint entirely. The gate keeps the checkpoint mandatory in the learning sequence.

The `print` line is the success signal. Plain text, no emojis, no celebration — those belong in the clue cell when something narratively earned has happened.

## Common checkpoint failures

### "All checks pass but the exercise was actually wrong"

The assertion was too loose. Tighten the content check. If you find this happening repeatedly in one section, write down the actual failure mode (e.g., "learner forgot to extract `name` field, stored full dicts instead") and add a specific check for it.

### "The error message is confusing"

Run the checkpoint with a deliberately broken exercise to see what message a learner would actually see. If it's not actionable, rewrite. Good error messages name the variable, state what's expected, state what was got, and gesture at the likely cause.

### "Cell runs but learner doesn't notice it passed"

Make sure the final `print` is clearly a success signal. "All checks passed — you're ready for the clue." beats "Done." beats no output at all.

### "Cell fails on the very first run because some exercise was skipped"

That's the existence check working correctly. Don't try to make the checkpoint "robust" to skipped exercises — failing loudly is the point.

## Updating a checkpoint when adding a new exercise

Three places to touch:

1. Append the new variable name to `required_vars`.
2. Add a new `# X.Y - var_name` assertion block in the per-exercise section. Place it in section order (4.1 → 4.7), not at the bottom.
3. If the new variable's type/content has unusual constraints, write a specific assertion (not just `isinstance` + length).

Then validate by running the solutions notebook end-to-end and confirming the existing checkpoint still passes — the new assertion shouldn't accidentally break it.
