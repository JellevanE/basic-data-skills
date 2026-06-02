# Common pitfalls

Patterns that have shown up across review sessions, organized as: **symptom → why it's wrong → how to fix**.

Use this as a checklist when auditing an existing notebook, or to sanity-check a new one before validation.

---

## Content pitfalls

### Demo printed output contradicts the lesson

**Symptom.** The markdown says "don't do X — it's error-prone." The code cell shows X and Y side by side. Both print successful results. The "good" approach often produces *uglier-looking* output (e.g., URL-encoded characters that look like gibberish to a beginner).

**Why it's wrong.** Learners trust output more than prose. If the output shows X working fine, they conclude X is fine.

**Fix.** Either (a) make the demo actually break X (use input that requires what you're teaching — a value with a space that needs URL-encoding, an empty list that breaks naive indexing), or (b) drop the comparison and let prose carry the argument, or (c) defer the demonstration to a later section where the right example arises naturally.

### Section has theory but no runnable demo

**Symptom.** A markdown explanation followed by a commented-out template ("you'll adapt this when you encounter it"). No exercise. No way for the learner to see the concept in motion.

**Why it's wrong.** Skips the most important rung of the theory → demo → exercise ladder. Learners can read theory and never internalize it.

**Fix.** Find a runnable example. If the section is genuinely informational (showing patterns the learner won't encounter until later), reframe as a small "preview/reference" callout and skip the section number, OR find a way to make even a minimal version of the idea runnable.

### Long demo-only run before the first exercise

**Symptom.** The learner reads (and runs) several sections before the first `# YOUR CODE HERE`. The first hands-on task lands in section 4.

**Why it's wrong.** Beginners learn by doing. A lecture-length preamble means the concepts from the earlier sections were never practiced, so by the time they write code they're juggling three unrehearsed ideas at once.

**Fix.** Put a small exercise in the first section or two — even a trivial one (build a 3-row DataFrame from a list of dicts and print it) that lets them feel the new object. Then escalate. Also confirm the notebook ends with a synthesis exercise that recombines its skills, not just per-section drills.

### A later cell hands back a prior exercise's answer

**Symptom.** §5.5's setup cell re-fetches the data and rebuilds the exact DataFrame §5.4 asked the learner to create.

**Why it's wrong.** The learner can scroll to the next section and read the solution to the exercise they just struggled with — or skip attempting it entirely.

**Fix.** Reuse the learner's own variable downstream. If you must rebuild, do it in a visibly condensed form that doesn't echo the exercise's steps. Never paste the solution into a later cell.

### New syntax used without a first-time explanation

**Symptom.** A demo uses `c.get("area", 0)` or `df[df["x"] > n]` with no note on what it does, and the learner hasn't met `.get()` or boolean indexing in any earlier notebook.

**Why it's wrong.** Unexplained syntax reads as magic. The learner can copy it but can't transfer it.

**Fix.** One-line explanation at first appearance: what it does + why it's used here (`.get(key, default)` avoids a crash when the key is missing, so it's safer than `dict[key]`). Check prior notebooks to confirm whether it's genuinely new before explaining or assuming.

### Output operation taught without the round-trip

**Symptom.** A section saves a CSV and stops. The learner never sees the file confirmed, located, or read back.

**Why it's wrong.** A file they can't find or reload feels abstract; saving and loading are two halves of one skill.

**Fix.** Tell them where the file lands and how to find it (the IDE file tree or the Jupyter file browser), then add a short cell that loads it back and shows `.head()`.

### Exercise prompt spoon-feeds the answer

**Symptom.** Section teaches "read the docs to find the right endpoint." Exercise prompt then says `Endpoint: https://api.example.com/v1/things/{thing}`.

**Why it's wrong.** The exercise was supposed to make the learner read the docs and pick. You did the pick for them.

**Fix.** Drop the URL from the prompt. Keep the required-variable name (`euro_countries`) and one hint that points at *where to look* ("the docs list above"), never *what to write*. Trust the checkpoint to tell them if they picked wrong.

### Starter cell comments leak the implementation

**Symptom.** `# 1) Call /v3.1/currency/{currency} with currency = "eur"` in the starter. The learner just types it.

**Why it's wrong.** Same as above one level deeper — the starter has become a fill-in-the-blanks form, not an exercise.

**Fix.** Read your starter as the learner would. If solving it amounts to transcribing the comments, the comments are too revealing. Rewrite as task description, not code description: `# 1) Pick the right endpoint from the docs list above`.

### Variable names in prompt drift from checkpoint assertions

**Symptom.** Prompt asks for `country_data`. Checkpoint asserts on `countries_basic`.

**Why it's wrong.** The learner writes the right code, gets a missing-variable failure, can't tell what they did wrong.

**Fix.** Lock the variable name in the prompt and verbatim in the checkpoint. After every exercise edit, scroll to the checkpoint and grep for the name.

### "What you'll learn" promises that the checkpoint doesn't check

**Symptom.** Notebook intro lists 5 skills. Checkpoint asserts on 3. The other 2 have no exercises.

**Why it's wrong.** A learner could finish the notebook believing they've practiced things they haven't. The promise is a contract.

**Fix.** Either add exercises and checkpoint assertions for the missing items, or trim the promise list to match. Don't let the gap stand.

### Tone drift between adjacent notebooks

**Symptom.** Notebook N has restaurant analogies, comparison tables, and "That's it. You just called an API!" beats. Notebook N+1 jumps straight to "this notebook expands on those" with no warm-up.

**Why it's wrong.** The learner is the same person across notebooks. If you abruptly start assuming comfort they don't have yet, friction spikes.

**Fix.** Before editing a new section, skim the previous notebook for tone calibration. Match the warmth, the analogy density, the willingness to celebrate small wins.

---

## Technical pitfalls

### `input()` blocks `nbconvert --execute`

**Symptom.** Solutions notebook executes fine in Jupyter but fails in CI/validation with `StdinNotImplementedError` or `EOFError`.

**Fix.**
```python
try:
    api_key = input("Enter your key (or Enter for DEMO_KEY): ").strip() or "DEMO_KEY"
except Exception:
    api_key = "DEMO_KEY"  # non-interactive run
```
`Exception` is intentionally broad here — both `EOFError` (CLI pipe) and `StdinNotImplementedError` (Jupyter without a frontend) are possible, and the only failure mode is "input unavailable, fall back."

### API name searches return the wrong "first" result

**Symptom.** Demo says "fetch the Netherlands"; prints "Got data for Caribbean Netherlands". Learner thinks code is broken.

**Fix.** Whenever an API supports both substring and exact-match modes, use exact-match in teaching material. For REST Countries: `params={"fullText": "true"}`. For other APIs: read the docs for "exact" or "strict" flags, or use ID-based endpoints (`/alpha/{code}`).

### Loose checkpoint assertions

**Symptom.** Exercise input has 4 items; assertion is `len(x) >= 3`. A learner who silently drops one country still passes.

**Fix.** Match the exact expected count: `len(x) == 4`. Include the actual count and value in the error message:
```python
assert len(x) == 4, (
    f"Expected all 4 entries, got {len(x)}: {x}. "
    "Did your loop skip any country?"
)
```

### Edits to one notebook not mirrored to the other

**Symptom.** Learner notebook's exercise prompt says "use the docs to pick the endpoint." Solutions has stale comment: `# Find all countries that use the Euro` with the endpoint hardcoded. The two have drifted.

**Fix.** Every edit script touches both files. If you find yourself opening just one, stop and reconsider. The diff-checking trick: `diff <(jq -r '.cells[N].source | join("")' notebook.ipynb) <(jq -r '.cells[N].source | join("")' solutions.ipynb)` should match for markdown cells, and have a tight structural correspondence for code cells.

### Hand-editing the raw `.ipynb` JSON

**Symptom.** `Edit` tool calls trying to match exact byte sequences with `\n` and `\"` escaping. Fragile, often fails silently.

**Fix.** Always edit via a Python script that uses `json.loads` / `json.dumps`. See `references/safe-notebook-edits.md`.

### Multiple placeholder markers in one starter cell

**Symptom.**
```python
# YOUR CODE HERE
...
country_populations = {}

# YOUR LOOP HERE

print(country_populations)
```
Two markers, both for the same exercise.

**Fix.** One marker per exercise. The first is enough.

### Demo runs but checkpoint never re-runs

**Symptom.** Learner edits exercise, runs checkpoint, sees "passed!" — but the checkpoint was actually passing on stale notebook state from before the edit.

**Fix.** Pedagogically: tell learners to "Kernel → Restart & Run All" before relying on a checkpoint pass. In review: run the solutions notebook via `nbconvert --execute`, not by clicking cells in Jupyter — fresh kernel guarantees the checkpoint reflects current state.

---

## How to do an audit pass

Given an existing notebook, walk this list in order:

1. **Run it from a fresh kernel.** Either `Kernel → Restart & Run All` in Jupyter, or `jupyter nbconvert --to notebook --execute solutions/foo.ipynb`. Note any cell that fails.
2. **Read the markdown cells in order.** For each section: theory → demo → exercise present? In order? Demo runnable, demo demonstrates its claim? Is any new syntax explained on first use? Is each demo one idea per cell, not three?
3. **Trace the pacing.** Where does the learner first touch the keyboard — is the first exercise in the first section or two? Does any section lack an exercise? Is there a synthesis exercise at the end? Does any later setup cell rebuild a prior exercise's answer?
4. **Read the starter cells.** Could the learner solve them just from the comments? (If yes, soften the comments.) Does the exercise demand a step beyond replaying the demo?
5. **Diff against the previous notebook in the series.** Tone consistent? Vocabulary consistent? New colloquialisms introduced?
6. **Read the checkpoint.** Does every required variable have type AND content checks? Are assertions tight (`==`, not `>=`)? Do error messages tell the learner what went wrong?
7. **Read the "What you'll learn" list.** Is every promise exercised by the checkpoint?
8. **Diff learner ↔ solutions structurally.** Cell counts match? Markdown cells identical? Exercise variable names match?

Take findings to the user before editing. Don't bundle a tone-polish pass with a structural fix — they may want different scope on each.
