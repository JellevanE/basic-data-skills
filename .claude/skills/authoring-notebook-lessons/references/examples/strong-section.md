# Example: a strong section

This is §4.7 of the course (PokéAPI pagination) as it stands after revision. Reproduced here to show what "good" looks like end to end, with annotations explaining why each choice works.

The cells below appear in this order in the notebook: markdown intro → code demo → markdown exercise prompt → code starter.

---

## Cell 1 — Markdown intro (theory)

> ## 4.7 Pagination
>
> Many APIs don't return everything at once. They split results into **pages**. Returning thousands of items in one response would be slow, large, and easy to time out — paging keeps each response small and predictable.
>
> Two common parameter styles:
>
> ```python
> # Offset-based: "start at item 0, give me 100 items"
> params = {"offset": 0, "limit": 100}
>
> # Page-based: "give me page 1, with 100 items per page"
> params = {"page": 1, "per_page": 100}
> ```
>
> Below we'll use the **PokéAPI**, which is free, public, and paginates with `limit`/`offset`. Its responses also tell you the total count and the URL of the next page.

**Why this works:**
- Sentence 1: *what* — pagination splits results.
- Sentence 2: *why* — concrete consequences (slow, large, timeouts).
- Sentence 3: previews the two common parameter conventions before the demo. Learners walk into the code already knowing what `limit`/`offset` are for.
- Final paragraph sets up the demo and names the API. The demo doesn't drop out of nowhere.
- No analogies forced. The "phone book pages" metaphor was considered and dropped — the concrete `count`/`next`/`results` shape is more useful than a metaphor.

---

## Cell 2 — Code demo (runnable)

```python
# PokéAPI paginates with limit + offset.
response = requests.get(
    "https://pokeapi.co/api/v2/pokemon",
    params={"limit": 5, "offset": 0},
)
data = response.json()

print(f"Total Pokémon in database: {data['count']}")
print(f"This page returned: {len(data['results'])} results")
print(f"Next page URL: {data['next']}")
print()
print("Names on this page:")
for p in data["results"]:
    print(f"  {p['name']}")
```

Expected output:
```
Total Pokémon in database: 1350
This page returned: 5 results
Next page URL: https://pokeapi.co/api/v2/pokemon?offset=5&limit=5

Names on this page:
  bulbasaur
  ivysaur
  venusaur
  charmander
  charmeleon
```

**Why this works:**
- One real call to a real API. No `api.example.com`.
- `limit=5` keeps the output short enough to read at a glance. (If we'd used `limit=100`, the print would be a wall and the lesson would drown in scrollback.)
- The three things the theory promised — total count, `next` URL, this-page contents — all print in that order.
- Output shows recognizable Pokémon names. Learners feel "yes this is the real thing."

**What we did NOT do:**
- Did not include a `while next: ...` loop in the demo. That belongs in the exercise (or in a follow-on lesson). A demo with a full pagination loop would be too dense for first contact.
- Did not import anything. `requests` is already imported earlier in the notebook.

---

## Cell 3 — Markdown exercise prompt

> **Exercise.** Use PokéAPI to fetch the **first 30 Pokémon names** in two pages of 15. Make two calls — one with `offset=0` and one with `offset=15`, both with `limit=15` — then combine the names into one list.
>
> Required variable:
> - `pokemon_names` — a list of 30 lowercase strings (the `name` field from each result)
>
> Print the length and the first three names.

**Why this works:**
- Smallest task that actually exercises pagination: two distinct calls, results combined. Learners can't shortcut by setting `limit=30` — they have to handle the offset.
- The prompt names the parameters (`offset`, `limit`, values 0/15/15) — those are the *mechanics* the lesson is teaching, so spelling them out is fine. The *combining* step is left to the learner.
- Required variable spelled out: name, type, source attribute. The checkpoint can assert on all three.
- "Print the length and the first three names" gives the learner an immediate sanity check before they even run the checkpoint.

**What we did NOT do:**
- Did not say "use a loop" — the learner can choose two literal calls or `for offset in (0, 15)`. Both are correct.
- Did not say "follow the `next` URL." That's a different pattern; the lesson is offset-based pagination.
- Did not provide the API base URL — that came from the demo cell directly above.

---

## Cell 4 — Code starter (learner notebook)

```python
# YOUR CODE HERE
# 1) Call PokéAPI with limit=15 and offset=0  → first page
# 2) Call PokéAPI with limit=15 and offset=15 → second page
# 3) From each response, take the "name" of every item in results
# 4) Combine into pokemon_names (should have 30 entries)

pokemon_names = []

print(f"Got {len(pokemon_names)} names")
print(f"First three: {pokemon_names[:3]}")
```

**Why this works:**
- Comments describe the *tasks* ("Call PokéAPI", "take the name") not the *code* ("write `for offset in (0, 15):`"). The learner still has to choose the structure.
- Initial value `pokemon_names = []` matches the required type — the checkpoint won't blow up on `TypeError` for an unset variable. The learner can run the cell immediately and see "Got 0 names" — a clear "now do the work" signal.
- Print scaffolding stays so the learner sees their output immediately as they fill in the code.
- One `# YOUR CODE HERE` marker, not two. (One for "the call", one for "the loop" is a common anti-pattern — the learner doesn't know where to insert.)

---

## Cell 4' — Code starter (solutions notebook)

```python
# Two-page fetch: 15 items per page, offset 0 then offset 15.
pokemon_names = []
for offset in (0, 15):
    response = requests.get(
        "https://pokeapi.co/api/v2/pokemon",
        params={"limit": 15, "offset": offset},
    )
    page = response.json()
    pokemon_names.extend(p["name"] for p in page["results"])

print(f"Got {len(pokemon_names)} names")
print(f"First three: {pokemon_names[:3]}")
```

**Why this works:**
- Same variable name, same print scaffolding. Structure matches the learner cell exactly — the only difference is the body of the work.
- The for-loop form chosen over two literal calls. Both would be correct; the loop is slightly more idiomatic and shows a pattern that generalizes.
- One brief header comment, no over-explanation. Solutions cells should be terse — the learner reads these as "oh, that's how it goes" reference code, not as new teaching material.

---

## Cell 5 — Checkpoint contribution

This isn't a new cell — the checkpoint cell lives elsewhere in the notebook. But §4.7 contributes to it:

```python
# Add pokemon_names to required_vars at the top of the checkpoint
required_vars = [
    ...,
    "pokemon_names",
]

# Then later in the checkpoint body:
# 4.7 - pokemon_names
assert isinstance(pokemon_names, list) and len(pokemon_names) == 30, (
    f"pokemon_names should have exactly 30 entries, got "
    f"{len(pokemon_names) if isinstance(pokemon_names, list) else 'n/a'}"
)
assert all(isinstance(n, str) for n in pokemon_names), (
    "All entries in pokemon_names should be strings (the 'name' field of each result)"
)
```

**Why this works:**
- `len == 30` exactly. A learner who fetches only one page (15 names) fails. A learner who fetches `limit=30, offset=0` also fails (technically correct count but doesn't exercise pagination — though this hint is left to the error message, not asserted explicitly).
- Type check first (`isinstance(pokemon_names, list)`) before length check, otherwise the `len()` could raise on a `None` value with a confusing error.
- Content check (`all(isinstance(n, str) for n in ...)`) catches the case where the learner forgot to extract the `name` field and stored full result dicts instead.
- Error messages are specific. A learner who sees "got 15" knows exactly what went wrong.

---

## What makes this whole section "strong"

1. **Theory grounds the demo, demo grounds the exercise, exercise grounds the checkpoint.** Each layer prepares the next; nothing comes out of nowhere.
2. **Every line earns its place.** The intro is 3 sentences, not 10. The demo prints 4 things, not 20. The starter has 4 comment lines, not a tutorial.
3. **The exercise actually requires what the section taught.** A learner who didn't internalize pagination cannot complete it by guessing.
4. **The checkpoint is tight.** Exact count, type + content, actionable errors.
5. **Real API, real data.** "bulbasaur" is more memorable than "item_1".

When auditing a section, compare it line-by-line to this one. If yours doesn't match the shape, ask why.
