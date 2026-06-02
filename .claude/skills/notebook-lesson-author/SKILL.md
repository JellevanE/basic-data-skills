---
name: notebook-lesson-author
description: Author and improve hands-on Jupyter teaching notebooks for absolute beginners. Use whenever the user wants to create a new lesson, add or rewrite a section/exercise, review an existing notebook against course style, or fix specific issues like weak intros, dummy-data examples, leaky starter cells, or checkpoints that don't actually fail when broken. Triggers on phrases like "create a notebook on X", "add a section about Y", "review notebook N", "this exercise feels weak", "use a real API instead of a placeholder", or any editing of `notebooks/*.ipynb` / `solutions/*.ipynb` with intent to teach. Prefer this skill over generic code-edit guidance whenever the artifact being changed is teaching material with a learner audience.
---

# Notebook lesson author

For authoring Jupyter notebooks that teach Python + API fundamentals to absolute beginners — both creating new lessons and improving existing ones. Encodes the patterns from `docs/NOTEBOOK_AUTHORING_RULES.md` plus lessons learned from review sessions on this repo.

## Five high-leverage principles

These are the rules that, when broken, produce the most learner confusion. Check every section against them.

### 1. Real over fake

Use real APIs and real data. `https://api.example.com/data` teaches nothing real. Pick stable, free, no-auth endpoints (see `references/real-world-apis.md`).

**Why this matters.** Learners build intuition from concrete artifacts. When the demo returns 53 European countries, they learn the response shape, the actual field names, and what "200 OK" feels like in practice. A placeholder URL teaches them nothing transferable.

### 2. Theory → runnable demo → exercise — in that order, every section

Each section has all three. A theory paragraph plus a commented-out template does NOT count as having a demo: learners need to see the concept *working* before being asked to write it. If a section is purely informational (auth concepts, pagination patterns), find a way to make at least its core idea runnable.

**Why this matters.** Without a demo, the exercise is the learner's first encounter with the pattern executing — multiplying their friction. The demo also gives them a known-good reference to model their exercise code after.

### 3. Demos must demonstrate what they claim

If the lesson is "don't do X because Y", the demo must visibly show Y happening. If "X" works fine in the printed output, the lesson backfires — learners walk away believing the wrong thing.

**Why this matters.** Sanity-check every demo by asking: "Does the printed output prove the lesson, or contradict it?" Example from this repo's §4.2: a demo claimed hand-gluing URLs is error-prone, but the side-by-side output showed both forms working identically. Lesson didn't land. See `references/examples/weak-section-fixed.md`.

### 4. Don't leak the answer

Starter cells must not contain the solution in comments. Exercise prompts must not spoon-feed the endpoint URL when the lesson above just taught docs-reading. State the required variable *names*; do not state the *path to producing them*.

**Why this matters.** The exercise is supposed to make the learner think. A starter that says `# 1) Call /v3.1/currency/{currency}` does the endpoint-picking work for them, defeating the section that just taught how to read API docs.

### 5. Checkpoints must fail when wrong

Assertions match the exact expected result. `len(x) == 4` for a four-item input, not `len(x) >= 3`. Every required variable gets both a type check AND a content check. Error messages are actionable ("expected 30 entries, got 15: did you fetch both pages?").

**Why this matters.** A checkpoint that passes for partial work gives false confidence — the learner moves on with broken understanding. Tight checkpoints are the autograder; loose ones are theatre.

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
3. Audit every section against the five principles + the pattern. Common findings:
   - Theory without a demo (commented-out template doesn't count)
   - Demos whose printed output contradicts the stated lesson
   - Starter cells leaking the answer
   - Variable names in prompts that don't match checkpoint assertions
   - Loose assertions (`>=` where `==` would catch silent errors)
   - Tone drift — does this notebook read differently from earlier ones in the series? If yes, narrow the gap.
   - Items in "What you'll learn" that aren't actually exercised in the checkpoint
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

## Pitfalls catalogued from review sessions

A non-exhaustive list. Full catalogue with mitigations in `references/common-pitfalls.md`.

- **Name search returning multiple matches**: `/v3.1/name/netherlands` first hit is "Caribbean Netherlands". Use `params={"fullText": "true"}` or exact-match endpoints.
- **`input()` blocks nbconvert/CI runs**: wrap in `try: ... except Exception: api_key = "DEMO_KEY"` for graceful fallback.
- **Multiple placeholder markers** (`# YOUR CODE HERE` + `# YOUR LOOP HERE`): pick one.
- **Promising things in "What you'll learn" that aren't exercised**: the checkpoint must back every promise.
- **Edits asymmetric across learner ↔ solutions**: variable contracts and cell structure must match exactly; apply edits in the same pass.
- **Colloquialisms drifting from prior notebooks' tone**: "glue", "split", "the bit before the `?`" can read fine in isolation but feel inconsistent if earlier notebooks were plainer.

## References

Read these as needed — they're loaded only when you reach for them, so don't pre-fetch.

- `references/section-pattern.md` — Full section template with annotated examples.
- `references/real-world-apis.md` — Catalog of teaching APIs with quirks-and-caveats.
- `references/common-pitfalls.md` — Anti-patterns + how to spot them + how to fix.
- `references/safe-notebook-edits.md` — Python-script-based editing + validation workflow.
- `references/examples/strong-section.md` — A solid section (PokéAPI pagination), annotated.
- `references/examples/weak-section-fixed.md` — Real before/after of a fix.
- `references/examples/checkpoint-template.md` — Anatomy of a good checkpoint cell.
