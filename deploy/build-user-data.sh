#!/usr/bin/env bash
#
# build-user-data.sh — generate a self-contained EC2 "user data" script from the
# app in ../public. The output embeds every app file, so pasting it into the EC2
# launch wizard builds the whole site on first boot (no SSH, no scp needed).
#
# Usage:  ./build-user-data.sh   ->  writes ./user-data-cloud.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUB="$(cd "$SCRIPT_DIR/../public" && pwd)"
OUT="$SCRIPT_DIR/user-data-cloud.sh"

# Emit "cat > DEST <<'DELIM' ... DELIM" preserving file contents literally.
emit_file() {
  local src="$1" dest="$2" delim="$3"
  echo "cat > $dest <<'$delim'"
  cat "$src"
  echo "$delim"
  echo
}

{
  cat <<'HEADER'
#!/bin/bash
###############################################################################
# ReStart demo — EC2 USER DATA (cloud deployment)
#
# Paste this whole file into: Launch instance > Advanced details > User data.
# It runs ONCE, as root, on first boot. When the instance is "running" and
# "2/2 checks passed", open http://<PUBLIC-IP>/ and you'll see the Cloud badge.
#
# Requires (set in the launch wizard, NOT here):
#   - Amazon Linux 2023 (or Amazon Linux 2)
#   - Security group inbound rule: HTTP / port 80 / 0.0.0.0/0
#
# Logs land in:  /var/log/restart-demo-userdata.log   and
#                /var/log/cloud-init-output.log
###############################################################################
set -xe
exec > /var/log/restart-demo-userdata.log 2>&1
echo "[restart-demo] user-data starting: $(date)"

# --- 1. Install Apache (httpd) + PHP -----------------------------------------
if command -v dnf >/dev/null 2>&1; then
  dnf install -y httpd php
else
  yum install -y httpd php
fi

# --- 2. Detect the AWS region (for a nice label in the UI) -------------------
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 300" || true)
REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/region || true)
REGION=${REGION:-unknown-region}
echo "[restart-demo] region: $REGION"

# --- 3. Write the app into the web root --------------------------------------
mkdir -p /var/www/html/assets /var/www/html/api

HEADER

  emit_file "$PUB/index.html"        /var/www/html/index.html        RESTART_INDEX_EOF
  emit_file "$PUB/assets/style.css"  /var/www/html/assets/style.css  RESTART_CSS_EOF
  emit_file "$PUB/assets/app.js"     /var/www/html/assets/app.js     RESTART_JS_EOF
  emit_file "$PUB/api/info.php"      /var/www/html/api/info.php      RESTART_PHP_EOF

  cat <<'FOOTER'
# --- 4. Mark this instance as the CLOUD environment --------------------------
# This single Apache setting is the ONLY difference from the on-prem deploy.
cat > /etc/httpd/conf.d/restart-demo.conf <<EOF
SetEnv DEPLOY_ENV "cloud"
SetEnv DEPLOY_REGION "AWS EC2 - ${REGION}"
EOF

# --- 5. Start Apache on boot and now -----------------------------------------
systemctl enable httpd
systemctl restart httpd

echo "[restart-demo] done: $(date). Visit http://<this-instance-public-ip>/"
FOOTER
} > "$OUT"

chmod +x "$OUT"
echo "Generated: $OUT"
wc -l "$OUT"
