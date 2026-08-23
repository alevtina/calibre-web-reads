#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

set -a
source .env
set +a

exec /Library/Frameworks/Python.framework/Versions/3.11/bin/python3 sync.py
