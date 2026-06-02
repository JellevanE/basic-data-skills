# Real-world APIs for teaching

A catalog of public APIs that have proven good for teaching in this course. Each entry covers: what it teaches well, a known-good call, and quirks that have bitten learners.

The bar for inclusion: free, no signup (or trivial signup), stable for years, returns JSON, no rate-limiting under normal classroom load. When you need a new API for a lesson and one here fits, prefer the known-good option over a new unknown.

---

## REST Countries — `https://restcountries.com/v3.1/`

Country data: name, capital, population, region, currencies, languages, borders. No auth.

**Good for teaching:**
- First `requests.get()` calls (deeply nested but understandable data)
- Query parameters (`?fields=name,capital`)
- Multiple endpoints with the same base (`/name/`, `/region/`, `/currency/`, `/lang/`)
- Reading API documentation (the homepage lists all endpoints clearly)

**Known-good calls:**
```python
requests.get("https://restcountries.com/v3.1/all", params={"fields": "name,region"})
requests.get("https://restcountries.com/v3.1/region/europe", params={"fields": "name,capital"})
requests.get("https://restcountries.com/v3.1/name/netherlands", params={"fullText": "true"})
requests.get("https://restcountries.com/v3.1/currency/eur", params={"fields": "name,capital"})
```

**Quirks / gotchas:**
- `/name/{name}` is a substring search by default. `/name/netherlands` returns BOTH the Netherlands AND Caribbean Netherlands — and the first hit is often the latter. Always pass `params={"fullText": "true"}` when you mean exact-match, or learners will think their code is broken.
- The `capital` field is a list (not a string), and can be missing entirely for some entries. Use `country.get("capital", ["—"])[0]` defensively.
- The `name` field is a nested dict: `country["name"]["common"]` for the everyday form.
- No pagination — `/all` returns ~250 countries in one shot. Don't use it to teach pagination.

---

## Open-Meteo — `https://api.open-meteo.com/v1/forecast`

Weather data: current conditions, hourly forecasts, historical. No auth, no signup.

**Good for teaching:**
- Multi-parameter requests (`latitude`, `longitude`, `current_weather`, plus optional hourly/daily/timezone keys)
- Showing why `params=` scales better than manual URL gluing
- Calling a "different API" to reinforce that the pattern transfers

**Known-good call:**
```python
requests.get(
    "https://api.open-meteo.com/v1/forecast",
    params={"latitude": 52.37, "longitude": 4.89, "current_weather": True},
)
# response.json()["current_weather"]["temperature"] → a number
```

**Quirks:**
- Numeric params are sent as numbers, not strings — `requests` handles the str conversion via `params=`.
- `current_weather: True` (Python boolean) is encoded as `current_weather=True` in the URL; the API accepts it.
- Temperatures are in °C by default; pass `temperature_unit="fahrenheit"` for °F.
- No pagination, no rate limit at classroom scale.

---

## PokéAPI — `https://pokeapi.co/api/v2/`

Pokémon data: species, moves, types, abilities. No auth.

**Good for teaching:**
- **Pagination** — `/pokemon` paginates with `limit`/`offset`, and responses include `count`, `next`, `previous`, `results`. Textbook shape.
- Loops over fetched lists (each `results` item has a `url` you can follow to get full data)
- Real-world response structure that's deeper than REST Countries

**Known-good calls:**
```python
# Page 1: first 20 results
requests.get("https://pokeapi.co/api/v2/pokemon", params={"limit": 20, "offset": 0})

# Page 2: next 20
requests.get("https://pokeapi.co/api/v2/pokemon", params={"limit": 20, "offset": 20})

# Detail for one Pokémon
requests.get("https://pokeapi.co/api/v2/pokemon/pikachu")
```

**Quirks:**
- `count` (~1350) is the total across all pages, not the current page size.
- `next` is `null` on the final page — that's how you know to stop a paging loop.
- Names are lowercase always (`"bulbasaur"`, not `"Bulbasaur"`).
- The detail endpoint (`/pokemon/{name-or-id}`) returns a fairly large response (~50KB). Filter what you print.

---

## NASA APIs — `https://api.nasa.gov/`

Multiple endpoints: APOD (Astronomy Picture of the Day), Mars Rover photos, Near-Earth Objects. **Requires an API key**, but `DEMO_KEY` works without signup.

**Good for teaching:**
- Authentication with an API key (passed as `params={"api_key": ...}` — NASA's convention)
- Real `input()` workflow for keeping keys out of notebook source
- The "sign up for your own key" path (1 minute, no credit card)

**Known-good call:**
```python
# APOD — Astronomy Picture of the Day
requests.get("https://api.nasa.gov/planetary/apod", params={"api_key": "DEMO_KEY"})
# response.json() → {"title": "...", "url": "...", "explanation": "...", ...}
```

**Quirks:**
- `DEMO_KEY` rate-limits hard: 30 requests/hour and 50/day **per IP**. Fine for one classroom; not fine if the whole class runs from the same NAT.
- Personal keys: 1000/hour, 5000/day — generous.
- `input()` blocks `jupyter nbconvert --execute`. Always wrap:
  ```python
  try:
      api_key = input("Enter NASA API key (or Enter for DEMO_KEY): ").strip() or "DEMO_KEY"
  except Exception:
      api_key = "DEMO_KEY"  # non-interactive run
  ```
- APOD has a `media_type` field that's sometimes `"video"`. The `url` field works either way; `hdurl` only exists for images.

---

## Things to NOT use

- `httpbin.org` — useful for testing requests/responses but the data is fake and learners can't anchor on what it "means".
- `jsonplaceholder.typicode.com` — same problem; the posts/comments are placeholders, not real artifacts.
- Any API requiring OAuth, a credit card, or a wait for approval. Friction kills the lesson.
- Internal company APIs in starter material. Save those for workplace examples after the course pattern is internalized.
- APIs whose free tier rate-limits below classroom-throughput. If 25 learners can't all run the demo simultaneously, it'll fail in the workshop.

## When you need an API not in this list

Check three things before committing:
1. **No auth (or DEMO_KEY-equivalent)?** Anything more is a setup tax.
2. **Stable response shape?** Read the docs and look for "v1"/"stable" — beta APIs change.
3. **Print one real response.** Look at it. Does the structure suit the lesson? If the relevant data is buried 5 levels deep, the lesson becomes about traversal, not about the concept you're teaching.
