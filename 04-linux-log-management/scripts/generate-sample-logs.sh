#!/usr/bin/env bash
set -euo pipefail

ENTRY_COUNT="${1:-20}"
LOG_DIR="${HOME}/log-demo"
LOG_FILE="${LOG_DIR}/app.log"

if [[ ! "${ENTRY_COUNT}" =~ ^[0-9]+$ ]] || (( ENTRY_COUNT < 1 )); then
    echo "Usage: $0 [positive-number-of-entries]" >&2
    exit 1
fi

LOG_TYPES=(INFO INFO WARNING WARNING ERROR ERROR)
DESCRIPTIONS=(
    "Application health check successful"
    "Database connection successful"
    "Disk usage exceeded warning threshold"
    "High CPU utilization detected"
    "Database connection failed"
    "Application service unavailable"
)

mkdir -p "${LOG_DIR}"

for ((i = 0; i < ENTRY_COUNT; i++)); do
    message_index=$((i % ${#LOG_TYPES[@]}))
    printf '%s,%s,%s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "${LOG_TYPES[message_index]}" \
        "${DESCRIPTIONS[message_index]}" >> "${LOG_FILE}"
done

echo "Added ${ENTRY_COUNT} sample entries to ${LOG_FILE}"
echo "Latest five entries:"
tail -n 5 "${LOG_FILE}"
