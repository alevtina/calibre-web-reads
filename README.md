# calibre-web-reads

Sync your [Calibre-Web](https://github.com/janeczku/calibre-web) shelves to [IndieWeb read posts](https://indieweb.org/read) on a Jekyll site.

Runs on your home network (where your Calibre-Web instance lives), writes markdown files with [microformats2](https://microformats.org/wiki/microformats2) markup to your Jekyll `_reading/` collection, then commits and pushes automatically so GitHub Pages rebuilds without any manual steps.

Ratings, notes, and other manual edits are never touched by the sync.

## How it works

1. Authenticates with Calibre-Web and discovers your reading shelves
2. Scrapes book metadata (title, author, ISBN, series, publication year, tags)
3. Resolves cover images via the [Open Library](https://openlibrary.org) API — no auth required, no rate limits
4. Writes Jekyll markdown files with YAML front matter and `p-read-of h-cite` markup for new books
5. Reconciles existing files — if a book has moved to a different shelf (e.g. finished reading it), updates `status` and `date` in place while preserving all other content; if a book has been removed from all shelves, logs a warning (or deletes the file if `--prune` is set)
6. Commits and pushes the Jekyll repo — GitHub Pages rebuilds from there

## Why not GitHub Actions?

Calibre-Web is typically hosted on a home server, behind a router, not reachable from the public internet. This script is designed to run locally on the same network as your Calibre-Web instance.

## Requirements

- Python 3.10+
- [`requests`](https://pypi.org/project/requests/) and [`beautifulsoup4`](https://pypi.org/project/beautifulsoup4/)
- A Calibre-Web instance reachable from the machine running this script
- A Jekyll site with a `_reading/` collection and a `read` layout

## Installation

```bash
git clone https://github.com/alevtina/calibre-web-reads.git
cd calibre-web-reads
pip install -r requirements.txt
```

## Configuration

Copy `.env.example` and fill in your values:

```bash
cp .env.example .env
```

| Variable | Required | Description |
|---|---|---|
| `CALIBRE_WEB_URL` | ✓ | Base URL of your Calibre-Web instance (no trailing slash) |
| `CALIBRE_WEB_USER` | ✓ | Calibre-Web username |
| `CALIBRE_WEB_PASS` | ✓ | Calibre-Web password |
| `JEKYLL_READING_DIR` | ✓ | Absolute path to the `_reading/` directory in your Jekyll repo |
| `JEKYLL_REPO_DIR` | ✓ | Absolute path to the root of your Jekyll repo |
| `SHELF_PREFIX` | | Shelf name prefix — defaults to `CALIBRE_WEB_USER` |
| `PRUNE_REMOVED` | | Set to `true` to delete `_reading/` files for books removed from all shelves (equivalent to `--prune`) |

## Shelf naming convention

Shelves should be named with a common prefix followed by a status suffix. The prefix defaults to your Calibre-Web username; set `SHELF_PREFIX` to override.

| Shelf name | Status |
|---|---|
| `{prefix}-reading` | Currently reading |
| `{prefix}-tbr` | Want to read |
| `{prefix}-2024` | Finished in 2024 |
| `{prefix}-2025` | Finished in 2025 |

## Running

```bash
# load variables from .env
set -a && source .env && set +a

python3 sync.py
```

Pass `--prune` to also delete `_reading/` files for books removed from all shelves:

```bash
python3 sync.py --prune
```

Or export them directly:

```bash
export CALIBRE_WEB_URL=https://calibre.home.example.com
export CALIBRE_WEB_USER=alice
export CALIBRE_WEB_PASS=yourpassword
export JEKYLL_READING_DIR=~/sites/mysite/_reading
export JEKYLL_REPO_DIR=~/sites/mysite

python3 sync.py
```

## Jekyll integration

This script expects your Jekyll site to have a `_reading/` collection and a `read` layout. The generated front matter fields are:

```yaml
layout: read
title: "Book Title"
author: "Author Name"   # or a YAML list for multiple authors
isbn: "9780000000000"
year: 2024
series: "Series Name"
series_part: 1
cover: "https://covers.openlibrary.org/..."
status: finished        # finished | reading | to-read
date: 2024-01-01
rating:                 # fill in manually; sync never touches this field
tags: []
calibre_id: 42
```

A live example: [verbovetskaya.com/reading](https://verbovetskaya.com/reading)

## IndieWeb

Generated files are designed for use with a `read` layout that emits [microformats2](https://microformats.org/wiki/microformats2) read post markup:

- `h-entry` on the entry
- `p-read-of h-cite` wrapping the book metadata
- `p-x-read-status` for the reading status
- `dt-published` for the date
- `u-photo` for the cover image

## License

[MIT](LICENSE)
