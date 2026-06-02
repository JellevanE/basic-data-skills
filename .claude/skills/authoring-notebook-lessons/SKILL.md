---
name: authoring-notebook-lessons
description: Use when creating, editing, or reviewing hands-on Jupyter teaching notebooks for absolute beginners — new lessons, added or rewritten sections/exercises, reviewing a notebook against course style, or fixing issues like weak intros, dummy-data examples, leaky starter cells, and checkpoints that don't fail when the answer is wrong. Triggers on "create a notebook on X", "add a section about Y", "review notebook N", "this exercise feels weak", "use a real API instead of a placeholder", or any edit to `notebooks/*.ipynb` / `solutions/*.ipynb` meant to teach.
---

# Authoring notebook lessons

For authoring Jupyter notebooks that teach Python + API fundamentals to absolute beginners — both creating new lessons and improving existing ones. Encodes the patterns from `docs/NOTEBOOK_AUTHORING_RULES.md` plus lessons learned from review sessions on this repo.

## Six high-leverage principles

These are the rules that, when broken, produce the most learner confusion. Check every section against them.

### 1. Real over fake

Use real APIs and real data. `https://api.example.com/data` teaches nothing real. Pick stable, free, no-auth endpoints (see `references/real-world-apis.md`).

**Why this matters.** Learners build intuition from concrete artifacts. When the demo returns 53 European countries, they learn the response shape, the actual field names, and what "200 OK" feels like in practice. A placeholder URL teaches them nothing transferable.

### 2. Theory → runnable demo → exercise — in that order, every section

Each section has all three. A theory paragraph plus a commented-out template does NOT count as having a demo: learners need to see the concept *working* before being asked to write it. If a section is purely informational (auth concepts, pagination patterns), find a way to make at least its core idea runnable.

The *exercise* is as often the missing rung as the demo — watch for stretches of demo-only sections. Two pacing checks:

- **The first exercise comes early.** If a learner reads (and merely runs) three sections before touching the keyboard, the notebook feels like a lecture and the early concepts never get rehearsed. Put a small hands-on task in the first section or two — even a one-liner that just lets them feel the new object (e.g. build a tiny DataFrame from a list of dicts and print it).
- **Every conceptual section earns an exercise, and the notebook ends with one that combines them.** Output/utility sections (save to CSV, load it back) need a drill too. Close with a synthesis exercise that recombines the notebook's skills end-to-end — distinct from per-section drills and from any storyline clue.

**Why this matters.** Without a demo, the exercise is the learner's first encounter with the pattern executing — multiplying their friction. Without early and frequent exercises, the learner passively reads and never builds the muscle memory; a long demo-only run is the most common version of this failure.

### 3. Demos must demonstrate what they claim

If the lesson is "don't do X because Y", the demo must visibly show Y happening. If "X" works fine in the printed output, the lesson backfires — learners walk away believing the wrong thing.

**Why this matters.** Sanity-check every demo by asking: "Does the printed output prove the lesson, or contradict it?" Example from this repo's §4.2: a demo claimed hand-gluing URLs is error-prone, but the side-by-side output showed both forms working identically. Lesson didn't land. See `references/examples/weak-section-fixed.md`.

### 4. Don't leak the answer

Starter cells must not contain the solution in comments. Exercise prompts must not spoon-feed the endpoint URL when the lesson above just taught docs-reading. State the required variable *names*; do not state the *path to producing them*. This also applies *downstream*: a later section's setup or demo cell must not silently rebuild the exact artifact a previous exercise asked the learner to produce. If you need that data again, reuse the learner's variable or rebuild it in a visibly different, condensed form — never paste the solution into a cell the learner will scroll past.

**Why this matters.** The exercise is supposed to make the learner think. A starter that says `# 1) Call /v3.1/currency/{currency}` does the endpoint-picking work for them, defeating the section that just taught how to read API docs. And a next-section setup cell that re-derives the previous answer hands it back before they've attempted it.

### 5. Checkpoints must fail when wrong

Assertions match the exact expected result. `len(x) == 4` for a four-item input, not `len(x) >= 3`. Every required variable gets both a type check AND a content check. Error messages are actionable ("expected 30 entries, got 15: did you fetch both pages?").

**Why this matters.** A checkpoint that passes for partial work gives false confidence — the learner moves on with broken understanding. Tight checkpoints are the autograder; loose ones are theatre.

### 6. Calibrate explanation depth to a true beginner

"Keep theory short" is not "keep theory thin." Match the depth to what's being introduced:

- **Motivation and new-tool intros get room.** The opening "why this notebook" framing and the first encounter with a major new library deserve a few warm sentences — what it is, why it's the standard tool for this job, when you'd reach for it. `pandas` is "Python's go-to way to work with tabular data," not just "a library that makes tables." Per-concept micro-theory still stays tight (2–3 sentences).
- **Explain new syntax the first time it appears.** Any function, method, or idiom the learner hasn't met in an earlier notebook gets a one-line "what it does, and why here" — e.g. `dict.get(key, default)` returns a fallback instead of crashing when the key is missing, which is why it's safer than `dict[key]`. Before assuming something is known, check the earlier notebooks for where it was introduced.
- **One idea per cell.** Don't stack two new patterns into one dense cell. Split a multi-step demo into stepwise cells with a sentence of narration between them, so the learner reads → runs → understands before the next step.

**Why this matters.** Absolute beginners can't fill gaps you skip — an unexplained `.get()` or a cell doing three new things at once reads as magic, and magic doesn't transfer. Brevity is a tool for clarity, not a licence to omit the explanation that makes code legible.

## Section pattern

Every learner section follows this shape. See `references/section-pattern.md` for the full spec with annotated examples.

```
### N.M Section title

[Theory: 2-3 plain sentences. What is it? Why does it matter? When would you use it?]

[Optional grounding: a small comparison table, an analogy, or one inline example.]

```python
# Runnable demo
# Prints output the learner can verify by eye.
```

**Exercise.** [Concrete task. Name required variables explicitly.]

Required variables:
- `var_name` — type + brief description

[Optional hint that points at *where* to look, never *what* to write.]
```

## Workflows

### A — Improve an existing notebook

1. Read the learner notebook AND its solutions counterpart side by side. They must mirror each other.
2. Read `docs/NOTEBOOK_AUTHORING_RULES.md` if it exists in the project.
3. Audit every section against the six principles + the pattern. `references/common-pitfalls.md` is the full symptom → why → fix catalogue and ends with a step-by-step audit pass to walk in order.
4. Present findings to the user before editing — let them prioritize. Don't bundle "polish" with structural fixes; the user may want different scope for each.
5. Apply each agreed edit to **both** notebook and solutions in the same pass. See `references/safe-notebook-edits.md` for the script pattern.
6. Validate by executing the solutions notebook end-to-end and confirming every checkpoint + clue passes.

### B — Create a new notebook (or section)

1. Clarify with the user: topic + ONE primary learning goal. A whole notebook usually carries 4-7 small sections building one bigger skill.
2. Pick a real-world example. Browse `references/real-world-apis.md` for stable teaching APIs, or pick another genuinely public, no-auth endpoint.
3. Draft each section using the pattern (theory → demo → exercise).
4. Add a final checkpoint cell that asserts on every required variable from the exercises. Each variable gets type + content checks.
5. (Optional) Add a capstone/"clue" cell gated behind a `notebookN_ready_for_clue` flag set by the checkpoint — useful for storyline-driven courses.
6. Mirror to the solutions notebook with working solutions for every exercise. Solutions cells should be terser than learner starters but otherwise structurally identical.
7. Validate end-to-end via `jupyter nbconvert --to notebook --execute`.

## Editing `.ipynb` files safely

Notebooks are JSON. Hand-editing is brittle — broken escape sequences, mismatched quotes, lost newlines in source arrays. Always edit via a Python script that loads JSON, mutates `nb["cells"]`, and writes back.

`references/safe-notebook-edits.md` has the working template used in this repo's review sessions:
- nbformat 4.4 cell schema
- In-place cell replacement
- Inserting new cells without scrambling indices
- Clearing `outputs` + `execution_count` for re-execution
- Validation step (`jupyter nbconvert --to notebook --execute solutions/<file>`) + grepping for `"All checks passed"`

## References

Read these as needed — they're loaded only when you reach for them, so don't pre-fetch.

- `references/section-pattern.md` — Full section template with annotated examples.
- `references/real-world-apis.md` — Catalog of teaching APIs with quirks-and-caveats.
- `references/common-pitfalls.md` — Full symptom → why → fix catalogue (content + technical traps like `input()` blocking and name-search mismatches), ending with a step-by-step audit pass.
- `references/safe-notebook-edits.md` — Python-script-based editing + validation workflow.
- `references/examples/strong-section.md` — A solid section (PokéAPI pagination), annotated.
- `references/examples/weak-section-fixed.md` — Real before/after of a fix.
- `references/examples/checkpoint-template.md` — Anatomy of a good checkpoint cell.
