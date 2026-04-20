# tools/xlsx_to_csv.py
# Downloads balance data from the published Google Sheet and writes:
#   res://data/object_data.csv
#   res://data/skill_data.csv
#
# No third-party dependencies — urllib is part of Python's standard library.

import urllib.request
import os

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR     = os.path.join(PROJECT_ROOT, "data")

OBJECT_URL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vT4Ij8zsG0kcS2doeQUEmHi7CFS1wfKnVY9fZK6oVq-0JksjQVupBwpt6V4ZawdOyKQwfFYvCBlz1iS/pub?gid=0&single=true&output=csv"
SKILL_URL  = "https://docs.google.com/spreadsheets/d/e/2PACX-1vT4Ij8zsG0kcS2doeQUEmHi7CFS1wfKnVY9fZK6oVq-0JksjQVupBwpt6V4ZawdOyKQwfFYvCBlz1iS/pub?gid=946542281&single=true&output=csv"

os.makedirs(DATA_DIR, exist_ok=True)

def download(url, filename):
    dest = os.path.join(DATA_DIR, filename)
    urllib.request.urlretrieve(url, dest)
    print(f"xlsx_to_csv: wrote {filename}")

download(OBJECT_URL, "object_data.csv")
download(SKILL_URL,  "skill_data.csv")