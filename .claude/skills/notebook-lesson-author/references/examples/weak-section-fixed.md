# Example: weak section, fixed

A real before/after from this repo's §4.2 ("Combining f-string paths with `params=`"). The original demo claimed hand-gluing URLs is error-prone, but the printed output showed both forms working identically. The lesson backfired. This document walks through the diagnosis and the fix.

---

## The original (broken)

**Markdown:**

> ## 4.2 Combining f-string paths with `params=`
>
> Query parameters handle the `?key=value` bits at the end of a URL. But sometimes the **endpoint itself** depends on a value — the region name, a currency, a country. Where do those go?
>
> Rule of thumb:
> - **Path segments** (the bit before the `?`) → use an f-string.
> - **Query bits** (after the `?`) → use `params=`.
>
> Don't try to glue both into one string by hand — it gets unreadable and you have to remember to URL-encode special characters.

**Code:**

```python
# Don't do this — gluing a full URL by hand
region = "europe"
fields = "name,capital"
url = "https://restcountries.com/v3.1/region/" + region + "?fields=" + fields
print(f"Glued URL: {url}")  # works, but error-prone

# Do this — f-string for the dynamic path segment, params= for the rest
response = requests.get(
    f"https://restcountries.com/v3.1/region/{region}",
    params={"fields": fields},
)
print(f"Final URL: {response.url}")
print(f"Status: {response.status_code}, Items: {len(response.json())}")
```

**Actual printed output:**

```
Glued URL: https://restcountries.com/v3.1/region/europe?fields=name,capital
Final URL: https://restcountries.com/v3.1/region/europe?fields=name%2Ccapital
Status: 200, Items: 53
```

## Why this is broken

Read the output as a beginner would:

- `Glued URL` is clean and readable: `?fields=name,capital`.
- `Final URL` is ugly: `?fields=name%2Ccapital` — what's `%2C`? Looks like an error.
- Both returned `Status: 200`, both got the same 53 items.

A learner walks away believing:
1. The "Don't do this" form actually works fine.
2. The "Do this" form makes URLs uglier.
3. The whole section is making a fuss about nothing.

The intent — "`params=` URL-encodes for you, which matters for special characters" — never lands. The example value (`"name,capital"`) doesn't have any character that *needs* encoding badly enough to fail. Commas are technically reserved but most APIs accept them raw. So the lesson dies in the output.

---

## The fix

The breakage isn't the strongest argument for `params=` — the maintenance/scaling cost is. With a single param, hand-gluing is fine. With three or four params (typical at work), hand-gluing turns into a mess of `+ "&...=" + str(value)` with type coercion and per-value encoding to think about.

The fix had three parts:

### Part 1: Drop the misleading side-by-side from §4.2

Replace the demo with the clean form only. Don't print `response.url` — that's what was exposing the confusing `%2C`. Just show the *call shape* and the success signal.

**New code:**

```python
# Pattern: f-string for the path part, params= for the query bits.
region = "europe"

response = requests.get(
    f"https://restcountries.com/v3.1/region/{region}",
    params={"fields": "name,capital"},
)
print(f"Status: {response.status_code}, Items: {len(response.json())}")
```

**New output:**

```
Status: 200, Items: 53
```

Clean. No confusing `%2C`. The lesson stays.

### Part 2: Slightly reframe the rule

Old: *"Don't try to glue both into one string by hand — it gets unreadable and you have to remember to URL-encode special characters."*

New: *"Don't try to glue both into one string by hand — `requests` URL-encodes values for you when you use `params=`, so things like spaces and ampersands never break the URL."*

The difference: stop calling hand-gluing "unreadable" (subjective; the old example didn't look unreadable). Instead state what `params=` does *for* you — encoding values so they don't break URLs. This claim is concrete and demonstrable.

### Part 3: Defer the scaling argument to §4.3

§4.3 introduces Open-Meteo, which naturally takes three params (`latitude`, `longitude`, `current_weather`). Added one line to its intro:

> *"Notice the call below takes **three** params (`latitude`, `longitude`, `current_weather`). Hand-gluing three values — each properly URL-encoded and joined with `&` — gets old fast. Passing a dict to `params=` keeps it readable as you add options."*

This way the "scaling pain" argument lands on a *real* call with three real params, not a contrived comparison.

---

## What we learned

### About this specific fix

- The original demo's failure was that its *printed output didn't match its stated lesson*. The lesson was about URL encoding; the output was about "both work the same." Always read your own demo output as a beginner and ask: "Does this prove what I just said?"
- Sometimes the right move is to **delete the comparison entirely** instead of trying to make it more convincing. A clean demo + prose argument can land better than a side-by-side that muddies the water.
- Spreading an argument across two sections (states-the-rule, demonstrates-the-scaling-pain) is fine. Not every claim needs to be proved within its own cell.

### About diagnosis generally

The diagnostic question to ask of any demo:

> "If a learner runs this cell and reads only the output, what conclusion will they draw?"

If that conclusion isn't the lesson you wanted to teach, the demo needs reworking. Common variants of this failure:

| Output reads as... | But the lesson was supposed to be... | Fix |
|---|---|---|
| "Both forms produce the same result" | "Use form B, form A is dangerous" | Use input that breaks form A visibly, or drop the comparison |
| "Status: 200" (nothing else) | "Look at the response structure" | Print the structure |
| "TypeError" with no explanation | "Handle missing fields with .get()" | Wrap demo in try/except and print a friendly error |
| Several pages of JSON | "Use params= to filter what you get back" | Use the filter; show the filtered output is short |

### About spotting weak demos in audits

When auditing an existing notebook, the fastest way to find broken demos is:

1. Run the notebook from a fresh kernel.
2. For each section, read **only** the printed output (close your eyes to the markdown).
3. Ask: "What does this output teach me?"
4. Then open the markdown. Does the teaching match?

Mismatches between "what the output teaches" and "what the markdown claims" are where revisions are needed.
