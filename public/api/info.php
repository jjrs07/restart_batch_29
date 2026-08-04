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
