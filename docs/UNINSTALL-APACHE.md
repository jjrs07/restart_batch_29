# Uninstalling Apache from Your WSL Machine — Student Guide

**Goal:** completely remove the Apache web server (and the `restart-demo` site
config it's serving) from your on-prem WSL box, so you can start clean or
reclaim the machine.

**Time:** ~5 minutes

> This undoes what `deploy/deploy.sh onprem` set up: the `apache2` package, PHP,
> the site files in `/var/www/html`, and the `restart-demo.conf` config file.

---

## What you need before you start

- A terminal in WSL (Ubuntu/Debian-based, since that's what `deploy.sh` detected
  on this machine — it uses `apt-get` and the `apache2` service name).
- `sudo` access (same account that ran `deploy.sh`).

---

## Step 1 — Stop the Apache service

Stop it before removing anything, so no process is holding files open.

```
sudo systemctl stop apache2
```

If your WSL distro doesn't have systemd running, use the fallback instead:

```
sudo service apache2 stop
```

---

## Step 2 — Disable the site config (optional but tidy)

`deploy.sh` enabled a config called `restart-demo` via `a2enconf`. Disable it
before uninstalling so nothing references it afterward:

```
sudo a2disconf restart-demo
```

It's fine if this prints a warning that the config is already gone — just move on.

---

## Step 3 — Remove the Apache and PHP packages

This removes the packages `deploy.sh` installed (`apache2`, `php`,
`libapache2-mod-php`) along with anything `apt` pulled in as a dependency:

```
sudo apt-get purge -y apache2 apache2-utils apache2-bin apache2.2-common php libapache2-mod-php
sudo apt-get autoremove -y
```

`purge` (instead of `remove`) also deletes the package's own config files under
`/etc/apache2/`, not just the binaries.

---

## Step 4 — Delete leftover config and log directories

`purge` usually cleans most of this, but confirm these are gone. If any still
exist, remove them:

```
sudo rm -rf /etc/apache2
sudo rm -rf /var/log/apache2
```

---

## Step 5 — Delete the deployed site files

`deploy.sh` copied the app into `/var/www/html` and may have left the
`restart-demo.conf` file behind if Step 3 didn't fully clean it:

```
sudo rm -rf /var/www/html
sudo rm -f /etc/apache2/conf-available/restart-demo.conf
```

> Only run this if `/var/www/html` doesn't contain anything else you care
> about — it wipes the whole docroot, not just this app's files.

---

## Step 6 — Verify Apache is gone

```
apache2 -v
which apache2ctl
systemctl status apache2
```

Each of these should now report "command not found" or "not found" / "could
not be found" — confirming the package, binaries, and service are all gone.

---

## Notes

- This does **not** touch the `restart-demo` project folder itself
  (`~/restart-demo`) — only the system-wide Apache installation and the files
  it copied into `/var/www/html`.
- If you want Apache back later, just re-run `sudo ./deploy/deploy.sh onprem`
  — it reinstalls and reconfigures everything from scratch.
