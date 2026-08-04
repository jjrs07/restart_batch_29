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
