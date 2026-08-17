#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${HOME}/log-demo"
LOG_FILE="${LOG_DIR}/app.log"
LOG_TYPE="${1:-INFO}"
DESCRIPTION="${2:-Application health check successful}"

mkdir -p "${LOG_DIR}"

# >> appends the new entry to the end of the file and keeps older entries.
# A single > would overwrite the file, destroying its previous log entries.
printf '%s,%s,%s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "${LOG_TYPE}" "${DESCRIPTION}" >> "${LOG_FILE}"

echo "Log entry written to ${LOG_FILE}"
echo "Latest five entries:"
tail -n 5 "${LOG_FILE}"
