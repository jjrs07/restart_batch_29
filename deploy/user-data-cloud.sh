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

cat > /var/www/html/index.html <<'RESTART_INDEX_EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>ReStart Deploy Demo — On-Prem vs Cloud</title>
  <link rel="stylesheet" href="assets/style.css" />
</head>
<body>
  <header class="topbar">
    <div class="brand">
      <span class="logo">&#9650;</span>
      <span>ReStart <strong>Deploy Demo</strong></span>
    </div>
    <span id="env-badge" class="badge badge--unknown">detecting&hellip;</span>
  </header>

  <main class="wrap">
    <section class="hero card">
      <h1>The same web app, running in two worlds.</h1>
      <p class="lede">
        This exact site is deployed <em>twice</em> from one identical codebase &mdash; once on an
        <strong>on-premise</strong> server (your WSL machine) and once in the
        <strong>cloud</strong> (an AWS EC2 instance). Nothing in the app changes.
        Only <em>where it lives</em> and <em>how it is operated</em> change.
      </p>
      <p class="lede">
        The card below is filled in live by a small backend running next to this page.
        Notice which environment served <em>you</em> right now.
      </p>
    </section>

    <section class="card">
      <div class="card__head">
        <h2>This instance</h2>
        <button id="refresh" class="btn" type="button">Refresh</button>
      </div>
      <table class="kv">
        <tbody>
          <tr><th>Environment</th><td id="k-env">&mdash;</td></tr>
          <tr><th>Location</th><td id="k-region">&mdash;</td></tr>
          <tr><th>Server hostname</th><td id="k-host">&mdash;</td></tr>
          <tr><th>Web server</th><td id="k-server">&mdash;</td></tr>
          <tr><th>Backend</th><td id="k-backend">&mdash;</td></tr>
          <tr><th>Server time</th><td id="k-time">&mdash;</td></tr>
          <tr><th>Your IP (as seen by server)</th><td id="k-client">&mdash;</td></tr>
          <tr><th>Times this instance was hit</th><td id="k-hits">&mdash;</td></tr>
        </tbody>
      </table>
      <p id="status" class="status"></p>
    </section>

    <section class="grid">
      <div class="card compare compare--onprem">
        <h3>On-Premise (WSL stands in for your own server)</h3>
        <ul>
          <li><strong>You own the box.</strong> Hardware, OS, power, network &mdash; all yours.</li>
          <li>You install &amp; patch Apache, PHP, and security updates <em>by hand</em>.</li>
          <li>Fixed capacity. More traffic? Buy and rack more hardware.</li>
          <li>Full control, full responsibility. Great for data that must stay in-house.</li>
        </ul>
      </div>
      <div class="card compare compare--cloud">
        <h3>Cloud (AWS EC2)</h3>
        <ul>
          <li><strong>You rent the box.</strong> AWS owns the hardware and data center.</li>
          <li>Same Apache + PHP, but you can bake it into an image and clone it.</li>
          <li>Elastic capacity. More traffic? Add instances behind a load balancer.</li>
          <li>Pay for what you use. Fast to start, someone else handles the racks.</li>
        </ul>
      </div>
    </section>

    <section class="card takeaway">
      <h2>The lesson</h2>
      <p>
        Deployment is not about the code &mdash; the code is identical here. It is about
        the <strong>environment</strong> around it: who owns the server, who patches it, how you
        scale, and who is on call at 3&nbsp;a.m. Learn to deploy the <em>same</em> app to both,
        and you can work anywhere.
      </p>
    </section>
  </main>

  <footer class="foot">
    ReStart Program &middot; On-Prem &amp; Cloud Deployment Demo &middot; served by Apache
  </footer>

  <script src="assets/app.js"></script>
</body>
</html>
RESTART_INDEX_EOF

cat > /var/www/html/assets/style.css <<'RESTART_CSS_EOF'
:root {
  --bg: #0f172a;
  --panel: #1e293b;
  --panel-2: #263449;
  --text: #e2e8f0;
  --muted: #94a3b8;
  --line: #334155;
  --accent: #38bdf8;
  --onprem: #f59e0b;
  --cloud: #3b82f6;
  --ok: #34d399;
}

* { box-sizing: border-box; }

body {
  margin: 0;
  font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
  background: radial-gradient(1200px 600px at 70% -10%, #16233f 0%, var(--bg) 55%);
  color: var(--text);
  line-height: 1.6;
  min-height: 100vh;
}

.topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 22px;
  border-bottom: 1px solid var(--line);
  position: sticky;
  top: 0;
  background: rgba(15, 23, 42, 0.85);
  backdrop-filter: blur(8px);
}
.brand { display: flex; align-items: center; gap: 10px; font-size: 1.05rem; }
.logo { color: var(--accent); font-size: 1.2rem; }

.badge {
  font-weight: 700;
  font-size: 0.8rem;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  padding: 6px 14px;
  border-radius: 999px;
  border: 1px solid var(--line);
}
.badge--onprem { background: rgba(245, 158, 11, 0.15); color: var(--onprem); border-color: var(--onprem); }
.badge--cloud  { background: rgba(59, 130, 246, 0.15); color: var(--cloud);  border-color: var(--cloud); }
.badge--unknown { color: var(--muted); }

.wrap { max-width: 920px; margin: 0 auto; padding: 28px 20px 60px; }

.card {
  background: var(--panel);
  border: 1px solid var(--line);
  border-radius: 14px;
  padding: 22px 24px;
  margin-bottom: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.25);
}

.hero h1 { margin: 0 0 12px; font-size: 1.7rem; line-height: 1.25; }
.lede { color: var(--muted); margin: 0 0 10px; }
.lede em { color: var(--text); font-style: normal; text-decoration: underline dotted var(--accent); }

.card__head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px; }
.card__head h2 { margin: 0; }

.btn {
  background: var(--accent);
  color: #082032;
  border: 0;
  font-weight: 700;
  padding: 8px 16px;
  border-radius: 8px;
  cursor: pointer;
}
.btn:hover { filter: brightness(1.08); }
.btn:active { transform: translateY(1px); }

.kv { width: 100%; border-collapse: collapse; }
.kv th, .kv td { text-align: left; padding: 9px 4px; border-bottom: 1px solid var(--line); vertical-align: top; }
.kv th { color: var(--muted); font-weight: 500; width: 44%; }
.kv td { font-variant-numeric: tabular-nums; }

.status { min-height: 1.2em; margin: 12px 0 0; font-size: 0.9rem; color: var(--muted); }
.status.err { color: #fca5a5; }
.status.ok { color: var(--ok); }

.grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.grid .card { margin-bottom: 0; }
.compare h3 { margin-top: 0; }
.compare ul { margin: 0; padding-left: 18px; color: var(--muted); }
.compare li { margin-bottom: 8px; }
.compare li strong { color: var(--text); }
.compare--onprem { border-top: 3px solid var(--onprem); }
.compare--cloud  { border-top: 3px solid var(--cloud); }

.takeaway { border-left: 3px solid var(--accent); }
.takeaway p { color: var(--muted); margin-bottom: 0; }
.takeaway strong, .takeaway em { color: var(--text); }

.foot { text-align: center; color: var(--muted); font-size: 0.85rem; padding: 24px 16px 40px; border-top: 1px solid var(--line); }

@media (max-width: 720px) {
  .grid { grid-template-columns: 1fr; }
  .kv th { width: 50%; }
}
RESTART_CSS_EOF

cat > /var/www/html/assets/app.js <<'RESTART_JS_EOF'
// Frontend: ask the backend where it is running and paint the page accordingly.
// The SAME file runs on-prem and in the cloud. Only the backend's answer differs.

const $ = (id) => document.getElementById(id);

function setStatus(msg, kind) {
  const el = $("status");
  el.textContent = msg;
  el.className = "status" + (kind ? " " + kind : "");
}

function paint(info) {
  const env = (info.environment || "unknown").toLowerCase();

  const badge = $("env-badge");
  if (env === "onprem") {
    badge.textContent = "On-Premise";
    badge.className = "badge badge--onprem";
  } else if (env === "cloud") {
    badge.textContent = "Cloud";
    badge.className = "badge badge--cloud";
  } else {
    badge.textContent = "Unknown";
    badge.className = "badge badge--unknown";
  }

  $("k-env").textContent = info.environment_label || env;
  $("k-region").textContent = info.region || "—";
  $("k-host").textContent = info.hostname || "—";
  $("k-server").textContent = info.server_software || "—";
  $("k-backend").textContent = info.backend || "—";
  $("k-time").textContent = info.server_time || "—";
  $("k-client").textContent = info.client_ip || "—";
  $("k-hits").textContent = info.hits != null ? info.hits : "—";
}

async function load() {
  setStatus("Contacting backend…");
  try {
    const res = await fetch("api/info.php", { cache: "no-store" });
    if (!res.ok) throw new Error("HTTP " + res.status);
    const info = await res.json();
    paint(info);
    setStatus("Live data from the server that handled this request.", "ok");
  } catch (err) {
    setStatus(
      "Could not reach the backend (api/info.php). Is Apache + PHP running? " + err.message,
      "err"
    );
  }
}

$("refresh").addEventListener("click", load);
load();
RESTART_JS_EOF

cat > /var/www/html/api/info.php <<'RESTART_PHP_EOF'
<?php
// Tiny backend. The SAME file is deployed on-prem and in the cloud.
// What makes the page say "On-Premise" or "Cloud" is a single environment
// variable that Apache injects (DEPLOY_ENV), configured at deploy time.
//
// See deploy/deploy.sh — it writes an Apache conf with:
//     SetEnv DEPLOY_ENV onprem     (or cloud)
//     SetEnv DEPLOY_REGION "..."

header("Content-Type: application/json");
header("Cache-Control: no-store");

// Read the environment injected by Apache (fallback to onprem if unset).
$env = getenv("DEPLOY_ENV");
if ($env === false || $env === "") {
    $env = "onprem";
}
$env = strtolower(trim($env));

$region = getenv("DEPLOY_REGION");
if ($region === false || $region === "") {
    $region = ($env === "cloud") ? "Cloud region (unset)" : "Local machine / WSL";
}

$labels = [
    "onprem" => "On-Premise server (you run the hardware)",
    "cloud"  => "Cloud instance (AWS EC2)",
];

// A simple hit counter, to show that a real server is keeping state.
// Stored in a file the web server can write to; degrades gracefully.
$hits = null;
$counterFile = sys_get_temp_dir() . "/restart_demo_hits.txt";
$fp = @fopen($counterFile, "c+");
if ($fp !== false) {
    if (flock($fp, LOCK_EX)) {
        $current = (int) stream_get_contents($fp);
        $current++;
        rewind($fp);
        ftruncate($fp, 0);
        fwrite($fp, (string) $current);
        fflush($fp);
        flock($fp, LOCK_UN);
        $hits = $current;
    }
    fclose($fp);
}

$response = [
    "environment"       => in_array($env, ["onprem", "cloud"], true) ? $env : "unknown",
    "environment_label" => $labels[$env] ?? "Unknown environment",
    "region"            => $region,
    "hostname"          => gethostname(),
    "server_software"   => $_SERVER["SERVER_SOFTWARE"] ?? "Apache",
    "backend"           => "PHP " . PHP_VERSION,
    "server_time"       => date("Y-m-d H:i:s T"),
    "client_ip"         => $_SERVER["REMOTE_ADDR"] ?? "unknown",
    "hits"              => $hits,
];

echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
RESTART_PHP_EOF

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
