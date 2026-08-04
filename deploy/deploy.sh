#!/usr/bin/env bash
#
# deploy.sh — deploy the ReStart demo to Apache.
#
# The SAME app is deployed to two environments. The only thing that changes is
# the DEPLOY_ENV value below, which Apache injects into the PHP backend.
#
# Usage:
#   ./deploy.sh onprem                         # on your WSL / on-prem box
#   ./deploy.sh cloud  "AWS ap-southeast-1"    # on an EC2 instance
#
#   arg 1: environment  -> onprem | cloud   (default: onprem)
#   arg 2: region label -> free text shown in the UI (optional)
#
# Run with sudo, or as a user who can sudo (it will prompt for your password):
#   sudo ./deploy.sh onprem
#
set -euo pipefail

ENVIRONMENT="${1:-onprem}"
REGION_LABEL="${2:-}"

if [[ "$ENVIRONMENT" != "onprem" && "$ENVIRONMENT" != "cloud" ]]; then
  echo "ERROR: first argument must be 'onprem' or 'cloud' (got '$ENVIRONMENT')." >&2
  exit 1
fi

# Default region labels if none supplied.
if [[ -z "$REGION_LABEL" ]]; then
  if [[ "$ENVIRONMENT" == "onprem" ]]; then
    REGION_LABEL="On-prem: $(hostname) (WSL / local machine)"
  else
    REGION_LABEL="Cloud: AWS EC2"
  fi
fi

# Locate this script and the app's public/ folder (works from anywhere).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUBLIC_DIR="$(cd "$SCRIPT_DIR/../public" && pwd)"
DOCROOT="/var/www/html"

# Use sudo only if we are not already root.
SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
  SUDO="sudo"
fi

echo "==> Deploying ReStart demo"
echo "    environment : $ENVIRONMENT"
echo "    region label: $REGION_LABEL"
echo "    source      : $PUBLIC_DIR"
echo "    docroot     : $DOCROOT"
echo

# --- Detect the platform: Debian/Ubuntu (apt) vs RHEL/Amazon Linux (dnf/yum) ---
if command -v apt-get >/dev/null 2>&1; then
  PLATFORM="debian"
  SERVICE="apache2"
  CONF_FILE="/etc/apache2/conf-available/restart-demo.conf"
elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
  PLATFORM="rhel"
  SERVICE="httpd"
  CONF_FILE="/etc/httpd/conf.d/restart-demo.conf"
else
  echo "ERROR: no supported package manager (apt/dnf/yum) found." >&2
  exit 1
fi
echo "==> Detected platform: $PLATFORM (service: $SERVICE)"

# --- Install Apache + PHP ---
echo "==> Installing Apache + PHP (may take a minute)…"
if [[ "$PLATFORM" == "debian" ]]; then
  export DEBIAN_FRONTEND=noninteractive
  $SUDO apt-get update -y
  $SUDO apt-get install -y apache2 php libapache2-mod-php
  $SUDO a2enmod php* >/dev/null 2>&1 || true   # enable whatever php module got installed
  $SUDO a2enmod env  >/dev/null 2>&1 || true
else
  PM="dnf"; command -v dnf >/dev/null 2>&1 || PM="yum"
  $SUDO $PM install -y httpd php
fi

# --- Deploy the app files ---
echo "==> Copying app into $DOCROOT"
$SUDO mkdir -p "$DOCROOT"
$SUDO rm -rf "${DOCROOT:?}/index.html" "${DOCROOT}/assets" "${DOCROOT}/api"
$SUDO cp -r "$PUBLIC_DIR/." "$DOCROOT/"

# --- Write the per-environment Apache config (this is the ONLY thing that differs) ---
echo "==> Writing $CONF_FILE with DEPLOY_ENV=$ENVIRONMENT"
$SUDO tee "$CONF_FILE" >/dev/null <<EOF
# Managed by restart-demo deploy.sh — do not edit by hand.
# This single file is what makes an identical app report "onprem" vs "cloud".
SetEnv DEPLOY_ENV "$ENVIRONMENT"
SetEnv DEPLOY_REGION "$REGION_LABEL"
EOF

if [[ "$PLATFORM" == "debian" ]]; then
  $SUDO a2enconf restart-demo >/dev/null 2>&1 || true
fi

# --- Start / restart Apache ---
echo "==> (Re)starting $SERVICE"
if command -v systemctl >/dev/null 2>&1 && systemctl list-units >/dev/null 2>&1; then
  $SUDO systemctl enable "$SERVICE" >/dev/null 2>&1 || true
  $SUDO systemctl restart "$SERVICE"
else
  # WSL without systemd: fall back to the service wrapper.
  $SUDO service "$SERVICE" restart || $SUDO apache2ctl restart || $SUDO httpd -k restart
fi

IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
echo
echo "==> Done. The '$ENVIRONMENT' instance is live:"
echo "      http://localhost/           (from this machine)"
[[ -n "$IP" ]] && echo "      http://$IP/   (from other machines on the network)"
echo
echo "    Check the backend directly:"
echo "      curl -s http://localhost/api/info.php"
