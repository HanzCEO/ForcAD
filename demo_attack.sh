#!/usr/bin/env bash
#
# Manual demo helper for ForcAD.
#
# Demonstrates service control and flag stealing from outside the server.
# No docker exec required.
#
# Usage:
#   ./demo_attack.sh <SERVER_IP>
#
# Environment variables:
#   TEAM1_TOKEN  token for Team 1
#   TEAM2_TOKEN  token for Team 2
#
set -euo pipefail

SERVER="${1:-127.0.0.1}"
TEAM1_TOKEN="${TEAM1_TOKEN:-}"
TEAM2_TOKEN="${TEAM2_TOKEN:-}"

if [[ -z "$TEAM1_TOKEN" || -z "$TEAM2_TOKEN" ]]; then
  echo "ERROR: Set TEAM1_TOKEN and TEAM2_TOKEN (get them from run_demo.sh output)." >&2
  exit 1
fi

print_scoreboard() {
  echo "--- scoreboard ---"
  curl -s "http://${SERVER}:8080/api/client/ctftime/"
  echo
}

echo "=== ForcAD manual demo ==="
echo "Server  : ${SERVER}:8080"
printf 'Team 1  : flags http://%s:10000/flags/ | token %s\n' "$SERVER" "${TEAM1_TOKEN:0:8}..."
printf 'Team 2  : flags http://%s:10001/flags/ | token %s\n' "$SERVER" "${TEAM2_TOKEN:0:8}..."

echo ""
echo "=== 1. Baseline: both services up ==="
curl -s "http://${SERVER}:10000/ping/"; echo
curl -s "http://${SERVER}:10001/ping/"; echo
print_scoreboard

echo ""
echo "=== 2. Take Team 2's service DOWN ==="
curl -s -X POST "http://${SERVER}:10001/down/"; echo
echo "Wait one round for the scoreboard to update..."
sleep 25
echo "Team 2 /ping/ now returns:"
curl -s -o /dev/null -w "  HTTP %{http_code}\n" "http://${SERVER}:10001/ping/"
print_scoreboard

echo ""
echo "=== 3. Bring Team 2's service back UP ==="
curl -s -X POST "http://${SERVER}:10001/up/"; echo
echo "Wait one round..."
sleep 25
print_scoreboard

echo ""
echo "=== 4. Team 1 steals a Team 2 flag ==="
FLAG=$(curl -s "http://${SERVER}:10001/flags/" \
  | python3 -c "import json,sys; flags=json.load(sys.stdin)['flags']; print(flags[-1] if flags else 'none')")
echo "Stolen Team 2 flag: ${FLAG}"
echo "Submit it as Team 1:"
curl -s -X PUT "http://${SERVER}:8080/flags/" \
  -H "X-Team-Token: ${TEAM1_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "[\"${FLAG}\"]"
echo
print_scoreboard