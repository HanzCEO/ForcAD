#!/usr/bin/env bash
#
# Manual demo helper for ForcAD.
#
# Demonstrates service control and flag stealing from outside the server.
# Replacement values: <SERVER_IP>, <TEAM1_TOKEN>, <TEAM2_TOKEN>.
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
printf 'Team 1  : ping %s:10000 | submit via token %s\n' "$SERVER" "${TEAM1_TOKEN:0:8}..."
printf 'Team 2  : ping %s:10001 | submit via token %s\n' "$SERVER" "${TEAM2_TOKEN:0:8}..."

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
echo "=== 4. Team 2 steals a Team 1 flag (manual) ==="
echo "Fetch a fresh Team 1 flag from the DB:"
echo "  docker exec forcad-postgres-1 psql -U forcad -d forcad -t -A \\"
echo "    -c \"SELECT flag FROM flags WHERE team_id=1 ORDER BY id DESC LIMIT 1;\""
echo ""
echo "Submit it as Team 2:"
echo "  curl -X PUT http://${SERVER}:8080/flags/ \\"
echo "    -H \"X-Team-Token: ${TEAM2_TOKEN}\" \\"
echo "    -H \"Content-Type: application/json\" \\"
echo "    -d '[\"<FLAG>\"]'"
print_scoreboard