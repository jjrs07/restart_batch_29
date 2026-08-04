#!/usr/bin/env python3
"""
dev-server.py — zero-install local preview (no Apache, no sudo, no PHP).

This is ONLY for quickly previewing the frontend. It fakes the /api/info.php
backend in Python so you can see the page without installing anything. The REAL
demo (and the on-prem vs cloud lesson) runs on Apache + PHP via deploy/deploy.sh.

Usage:
    DEPLOY_ENV=onprem python3 dev-server.py            # default port 8080
    DEPLOY_ENV=cloud  PORT=8081 python3 dev-server.py

Then open http://localhost:8080/
"""
import http.server
import json
import os
import socket
import datetime

PUBLIC_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "public")
PORT = int(os.environ.get("PORT", "8080"))
ENVIRONMENT = os.environ.get("DEPLOY_ENV", "onprem").strip().lower()
REGION = os.environ.get(
    "DEPLOY_REGION",
    "Local machine / WSL (dev preview)" if ENVIRONMENT == "onprem" else "Cloud (dev preview)",
)

LABELS = {
    "onprem": "On-Premise server (dev preview, not Apache)",
    "cloud": "Cloud instance (dev preview, not Apache)",
}

_hits = {"n": 0}


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=PUBLIC_DIR, **kwargs)

    def do_GET(self):
        if self.path.split("?")[0] == "/api/info.php":
            return self.send_info()
        return super().do_GET()

    def send_info(self):
        _hits["n"] += 1
        payload = {
            "environment": ENVIRONMENT if ENVIRONMENT in ("onprem", "cloud") else "unknown",
            "environment_label": LABELS.get(ENVIRONMENT, "Unknown (dev preview)"),
            "region": REGION,
            "hostname": socket.gethostname(),
            "server_software": "Python dev-server (NOT Apache)",
            "backend": "Python " + ".".join(map(str, __import__("sys").version_info[:3])),
            "server_time": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S %Z") or
                           datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "client_ip": self.client_address[0],
            "hits": _hits["n"],
        }
        body = json.dumps(payload, indent=2).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    print(f"ReStart demo dev preview  →  http://localhost:{PORT}/")
    print(f"  DEPLOY_ENV = {ENVIRONMENT}   (set DEPLOY_ENV=cloud to flip)")
    print("  This is a PREVIEW ONLY. Real deploy = Apache + PHP (deploy/deploy.sh). Ctrl+C to stop.")
    http.server.HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
