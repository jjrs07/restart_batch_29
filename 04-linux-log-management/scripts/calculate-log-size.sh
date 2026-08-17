#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${HOME}/log-demo/app.log"
INTERVAL_MINUTES=5

if [[ ! -f "${LOG_FILE}" ]]; then
    echo "Log file not found: ${LOG_FILE}" >&2
    echo "Run ./scripts/generate-log.sh first." >&2
    exit 1
fi

entry_count=$(wc -l < "${LOG_FILE}")
file_bytes=$(wc -c < "${LOG_FILE}")
disk_usage=$(du -h "${LOG_FILE}" | awk '{print $1}')
logs_per_hour=$((60 / INTERVAL_MINUTES))
logs_per_day=$((logs_per_hour * 24))

if (( entry_count == 0 )); then
    average_bytes="0.00"
    day_bytes=0
else
    average_bytes=$(awk -v bytes="${file_bytes}" -v entries="${entry_count}" \
        'BEGIN {printf "%.2f", bytes / entries}')
    day_bytes=$((file_bytes * logs_per_day / entry_count))
fi

month_bytes=$((day_bytes * 30))
year_bytes=$((day_bytes * 365))

to_kib() {
    awk -v bytes="$1" 'BEGIN {printf "%.2f KiB", bytes / 1024}'
}

echo "Log file: ${LOG_FILE}"
echo "Total log entries: ${entry_count}"
echo "Exact file size: ${file_bytes} bytes"
echo "Human-readable file size: $(to_kib "${file_bytes}")"
echo "Human-readable allocated disk usage: ${disk_usage}"
echo "Average bytes per log entry: ${average_bytes}"
echo
echo "Logging interval: every ${INTERVAL_MINUTES} minutes"
echo "60 / 5 = ${logs_per_hour} logs per hour"
echo "${logs_per_hour} * 24 = ${logs_per_day} logs per day"
echo "24 * 60 / 5 = ${logs_per_day} logs per day"
echo
echo "Estimated size after 1 day: ${day_bytes} bytes ($(to_kib "${day_bytes}"))"
echo "Estimated size after 30 days: ${month_bytes} bytes ($(to_kib "${month_bytes}"))"
echo "Estimated size after 365 days: ${year_bytes} bytes ($(to_kib "${year_bytes}"))"
echo
echo "These are estimates: description lengths vary, so future entries may not match the current average."
echo "Binary units are used: 1 KiB = 1024 bytes."
