#!/usr/bin/env bash
#
# Bootstrap and run the ForcAD demo stack.
#
# This script prepares a fresh clone and starts the demo.
# Run it from the project root.
#
# Usage:
#   ./run_demo.sh            # first run / start the demo
#   ./run_demo.sh --reset    # wipe the previous game first
#
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "${BASE_DIR}"

DO_RESET=0
if [[ "${1:-}" == "--reset" ]]; then
  DO_RESET=1
fi

echo "[1/5] Creating Python virtual environment with uv"
if [[ ! -d .venv ]]; then
  uv venv --python 3.11
fi
uv pip install --python .venv/bin/python -r cli/requirements.txt

echo "[2/5] Checking config.yml"
if [[ ! -f config.yml ]]; then
  echo "ERROR: config.yml is missing." >&2
  echo "Restore it from the repo with:  git restore config.yml" >&2
  exit 1
fi

echo "[3/5] Running control.py setup"
.venv/bin/python control.py setup

if [[ "${DO_RESET}" == "1" ]]; then
  echo "[--reset] Wiping previous game state"
  .venv/bin/python control.py reset
fi

echo "[4/5] Starting the demo stack"
.venv/bin/python control.py start

echo "[5/5] Demo is running"
echo ""
echo "  Scoreboard : http://127.0.0.1:8080/"
echo "  Admin panel: http://127.0.0.1:8080/admin/"
echo "  Flower     : http://127.0.0.1:8080/flower/"
echo ""
echo "Waiting for the initializer to finish, then printing team tokens..."
sleep 20
echo "Team tokens:"
.venv/bin/python control.py print_tokens || true