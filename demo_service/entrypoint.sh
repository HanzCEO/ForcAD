#!/bin/bash

set -e

PORT_10000="${PORT_10000:-10000}"
PORT_20000="${PORT_20000:-20000}"

echo "Starting demo service on ports ${PORT_10000} and ${PORT_20000}"

PORT="${PORT_10000}" python /app.py &
PORT="${PORT_20000}" python /app.py &

wait -n