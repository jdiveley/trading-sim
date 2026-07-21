#!/usr/bin/env bash
# Quick guard for the daily routine: exits 1 and prints the reason if the simulation has
# already ENDED, so the routine can skip all trading logic early.
# Usage: ./check_status.sh   (run from repo root, or pass a path to status.json)
set -euo pipefail

STATUS_FILE="${1:-data/status.json}"

STATE=$(python3 -c "import json; print(json.load(open('${STATUS_FILE}'))['state'])")

if [ "$STATE" = "ENDED" ]; then
    REASON=$(python3 -c "import json; print(json.load(open('${STATUS_FILE}'))['reason'])")
    echo "Simulation ENDED: ${REASON}"
    exit 1
fi

echo "RUNNING"
