# Section pattern

The shape every learner section should follow. The order is load-bearing — skipping the demo beat or putting the exercise before the demo measurably increases learner friction.

## The shape

```
### N.M Section title       (markdown cell)

Theory: 2-3 plain sentences answering:
- What is it?
- Why does it matter (concretely — what does it let you do)?
- When would you reach for it?

Optional grounding (still in the same markdown cell):
- A small table comparing this concept to a sibling concept
- An analogy (only if it actually clarifies — don't force one)
- A single inline example showing the shape

```python                   (code cell — DEMO)
# Runnable. Prints something the learner can verify by eye.
# Should produce output that proves the concept.
```

**Exercise.** Concrete mini-task that produces named artifacts.   (markdown cell)

Required variables:
- `var_name_1` — type + one-sentence description
- `var_name_2` — type + one-sentence description

Optional: a hint pointing at WHERE to look (the docs cell above,
a prior section, an attribute on the response object) — never at
WHAT to write.

```python                   (code cell — STARTER, learner notebook only)
# YOUR CODE HERE
# Brief steps in plain language — describe the work, do not show
# the exact endpoint URL or the loop structure if those are the
# point of the exercise.

var_name_1 = None
var_name_2 = None

print(var_name_1)
print(var_name_2)
```
```

In the solutions notebook the starter cell is replaced with the actual working code — same variable names, terser comments.

## Annotated good example

This is §4.7 from the course (PokéAPI pagination). Reproduced and labelled.

**Markdown — theory:**

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

Notes:
- Three sentences of theory: what + why + the size argument.
- Comparison of two param styles — concrete, not abstract.
- Last sentence sets up the demo, naming what the response will show.

**Code — runnable demo:**

```python
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

Notes:
- Real call, real response.
- Prints exactly the three things the theory promised: total count, `next` URL, and the page contents.
- Output is short enough to read at a glance (5 names, not 100).

**Markdown — exercise:**

> **Exercise.** Use PokéAPI to fetch the **first 30 Pokémon names** in two pages of 15. Make two calls — one with `offset=0` and one with `offset=15`, both with `limit=15` — then combine the names into one list.
>
> Required variable:
> - `pokemon_names` — a list of 30 lowercase strings (the `name` field from each result)
>
> Print the length and the first three names.

Notes:
- The pagination-instructional task: two distinct calls, one combined list. Smallest amount of code that actually exercises pagination.
- Variable name + type + source attribute (`name` field) are spelled out so the checkpoint can assert on them.
- "Print the length and the first three names" gives the learner an immediate sanity signal.

**Code — starter (learner):**

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

Notes:
- Comments describe the steps, not the code. They don't show the loop structure (the learner has to choose: two literal calls? a `for offset in (0, 15)` loop?).
- The print scaffolding stays so the learner sees output immediately.

## Anti-patterns to avoid

Theory cell without a demo: the section feels like a textbook. Learners can't see the concept work; the exercise is their first encounter, and they freeze.

Demo cell that prints nothing or prints only `Status: 200`: no visible artifact for the learner to anchor on. Print enough that the relationship between the call and the response is visible.

Exercise that just asks for a `print()`: not checkable. Always produce a named variable.

Exercise prompt that gives the full endpoint URL: defeats any "read the docs" lesson above. State the *task*; let the learner find the path.

Starter cell with the answer in comments: read your starter as the learner. If you can solve the exercise just by typing what the comments say, the comments are too revealing.

Solutions cell that diverges structurally from the learner cell: variable names, cell count, and execution order must match. Solutions is the answer key, not a rewrite.
