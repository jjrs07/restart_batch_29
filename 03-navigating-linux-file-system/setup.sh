#!/usr/bin/env bash
#
# setup.sh — (re)create the practice file tree for the Linux navigation lab.
#
# Run this to build the "cloudmart" folder tree you'll navigate around.
# It is SAFE to run again any time — it resets the tree to a clean, known state,
# so if you delete or move things during practice, just run it again.
#
#   ./setup.sh
#
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$LAB_DIR/practice"

echo "Building a fresh practice tree at:"
echo "  $ROOT"
rm -rf "$ROOT"

# mkfile <relative/path/under/practice> <line1> [line2] [line3] ...
mkfile() {
  local rel="$1"; shift
  local full="$ROOT/$rel"
  mkdir -p "$(dirname "$full")"
  printf '%s\n' "$@" > "$full"
}

mkfile cloudmart/README.txt \
  "Welcome to CloudMart HQ." \
  "You are at: cloudmart  (the top of the practice tree)" \
  "From here you can reach every department below."

mkfile cloudmart/departments/engineering/team.txt \
  "Engineering Team" \
  "Location: cloudmart/departments/engineering"

mkfile cloudmart/departments/engineering/projects/alpha/README.txt \
  "Project Alpha" \
  "Location: cloudmart/departments/engineering/projects/alpha" \
  "If you can read this, you navigated here correctly!"

mkfile cloudmart/departments/engineering/projects/alpha/notes.txt \
  "Alpha notes: ship the login page, then the dashboard."

mkfile cloudmart/departments/engineering/projects/beta/README.txt \
  "Project Beta" \
  "Location: cloudmart/departments/engineering/projects/beta"

mkfile cloudmart/departments/hr/employees.txt \
  "HR — Employee list" \
  "Location: cloudmart/departments/hr"

mkfile cloudmart/departments/hr/policies/leave.txt \
  "Leave Policy" \
  "Location: cloudmart/departments/hr/policies"

mkfile cloudmart/departments/hr/policies/conduct.txt \
  "Code of Conduct" \
  "Location: cloudmart/departments/hr/policies"

mkfile cloudmart/departments/finance/budget.txt \
  "Finance — Annual budget" \
  "Location: cloudmart/departments/finance"

mkfile cloudmart/departments/finance/reports/2025/q4.txt \
  "Q4 2025 report" \
  "Location: cloudmart/departments/finance/reports/2025"

mkfile cloudmart/departments/finance/reports/2026/q1.txt \
  "Q1 2026 report" \
  "Location: cloudmart/departments/finance/reports/2026"

mkfile cloudmart/departments/finance/reports/2026/q2.txt \
  "Q2 2026 report" \
  "Location: cloudmart/departments/finance/reports/2026"

echo "Done. Explore it with:  cd \"$ROOT\" && ls"
