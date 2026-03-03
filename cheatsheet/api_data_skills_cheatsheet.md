# API & Data Skills — Cheat Sheet

## Variables and types
```python
name = "Netherlands"       # String (text)
population = 17000000      # Integer (whole number)
latitude = 52.37           # Float (decimal)
is_eu = True               # Boolean (True/False)
type(name)                 # Check the type: <class 'str'>
```

## f-strings
```python
print(f"The capital of {country} is {capital}")
print(f"Population: {pop / 1000000:.1f} million")
```

## Lists
```python
items = ["a", "b", "c"]
items[0]                   # First item: "a"
items[-1]                  # Last item: "c"
len(items)                 # Length: 3
items.append("d")          # Add item to end
```

## Dictionaries
```python
data = {"name": "NL", "pop": 17000000}
data["name"]               # Access: "NL"
data.get("capital", "?")   # Safe access with fallback
data.keys()                # All keys
```

## Loops
```python
for item in my_list:
    print(item)

# Build a new list
results = []
for item in my_list:
    results.append(item["name"])
```

## Making API requests
```python
import requests

# Simple GET
response = requests.get(url)

# With query parameters
response = requests.get(url, params={"key": "value"})

# With authentication
response = requests.get(url, headers={"Authorization": "Bearer token"})
```

## Checking the response
```python
response.status_code       # 200, 404, etc.
response.ok                # True if 200-299
response.json()            # Parse JSON -> Python
response.text              # Raw text
```

## Status codes
| Code | Meaning          |
|------|------------------|
| 200  | OK               |
| 400  | Bad request      |
| 401  | Unauthorized     |
| 403  | Forbidden        |
| 404  | Not found        |
| 429  | Too many requests|
| 500  | Server error     |

## JSON files
```python
import json

# Read
with open("data.json") as f:
    data = json.load(f)

# Write
with open("data.json", "w") as f:
    json.dump(data, f, indent=2)
```

## Pandas
```python
import pandas as pd

df = pd.DataFrame(list_of_dicts)       # Create table
df[["col1", "col2"]]                   # Select columns
df[df["col"] > 100]                    # Filter rows
df.sort_values("col", ascending=False) # Sort
df.to_csv("file.csv", index=False)     # Save CSV
df.to_excel("file.xlsx", index=False)  # Save Excel
```

## The full pattern
```python
import requests
import pandas as pd

# 1. Call API
response = requests.get(url, params={...})

# 2. Process
rows = []
for item in response.json():
    rows.append({
        "field": item["nested"]["field"]
    })

# 3. Table + Save
df = pd.DataFrame(rows)
df.to_csv("output.csv", index=False)
```

## Error handling
```python
if response.ok:
    data = response.json()
else:
    print(f"Error: {response.status_code}")
    print(response.text)
```

## Virtual environment
```bash
python3 -m venv venv              # Create
source venv/bin/activate          # Activate (Mac/Linux)
venv\Scripts\activate             # Activate (Windows)
deactivate                        # Deactivate
pip install package_name          # Install package
```

## Public APIs for practice
| API              | URL                          | Auth   |
|------------------|------------------------------|--------|
| REST Countries   | restcountries.com            | None   |
| Open-Meteo       | open-meteo.com               | None   |
| JSONPlaceholder  | jsonplaceholder.typicode.com | None   |
| PokeAPI          | pokeapi.co                   | None   |
| GitHub           | api.github.com               | Optional |
