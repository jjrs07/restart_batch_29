# Uninstalling Apache — Student Guide

**Goal:** completely remove the Apache web server (and the `restart-demo` site
config it's serving) from your machine, so you can start clean or reclaim it.

**Time:** ~5 minutes

> This undoes what `deploy/deploy.sh onprem` set up: the Apache + PHP
> packages, the site files in `/var/www/html`, and the `restart-demo.conf`
> config file.

Pick the section that matches your machine:

- [Ubuntu / Debian (WSL)](#ubuntu--debian-wsl)
- [RHEL-family (RHEL, CentOS Stream, Rocky, AlmaLinux)](#rhel-family)

---

## Ubuntu / Debian (WSL)

`deploy.sh` detected `apt-get` on this platform and used the `apache2`
service name.

### Step 1 — Stop the Apache service

```bash
sudo systemctl stop apache2
```

If your WSL distro doesn't have systemd running, use the fallback instead:

```bash
sudo service apache2 stop
```

### Step 2 — Disable the site config (optional but tidy)

`deploy.sh` enabled a config called `restart-demo` via `a2enconf`. Disable it
before uninstalling so nothing references it afterward:

```bash
sudo a2disconf restart-demo
```

It's fine if this prints a warning that the config is already gone — just move on.

### Step 3 — Remove the Apache and PHP packages

This removes the packages `deploy.sh` installed (`apache2`, `php`,
`libapache2-mod-php`) along with anything `apt` pulled in as a dependency:

```bash
sudo apt-get purge -y apache2 apache2-utils apache2-bin apache2.2-common php libapache2-mod-php
sudo apt-get autoremove -y
```

`purge` (instead of `remove`) also deletes the package's own config files under
`/etc/apache2/`, not just the binaries.

### Step 4 — Delete leftover config and log directories

`purge` usually cleans most of this, but confirm these are gone. If any still
exist, remove them:

```bash
sudo rm -rf /etc/apache2
sudo rm -rf /var/log/apache2
```

### Step 5 — Delete the deployed site files

`deploy.sh` copied the app into `/var/www/html` and may have left the
`restart-demo.conf` file behind if Step 3 didn't fully clean it:

```bash
sudo rm -rf /var/www/html
sudo rm -f /etc/apache2/conf-available/restart-demo.conf
```

> Only run this if `/var/www/html` doesn't contain anything else you care
> about — it wipes the whole docroot, not just this app's files.

### Step 6 — Verify Apache is gone

```bash
apache2 -v
which apache2ctl
systemctl status apache2
```

Each of these should now report "command not found" or "not found" / "could
not be found" — confirming the package, binaries, and service are all gone.

---

## RHEL-family

`deploy.sh` detected `dnf`/`yum` on this platform and used the `httpd`
service name.

### Step 1 — Stop the Apache service

```bash
sudo systemctl stop httpd
```

### Step 2 — Remove the Apache and PHP packages

This removes the packages `deploy.sh` installed (`httpd`, `php`) along with
anything `dnf`/`yum` pulled in as a dependency:

```bash
sudo dnf remove -y httpd php
```

> No `dnf` on an older system? Use `sudo yum remove -y httpd php` instead.

### Step 3 — Delete leftover config and log directories

```bash
sudo rm -rf /etc/httpd
sudo rm -rf /var/log/httpd
```

### Step 4 — Delete the deployed site files

`deploy.sh` copied the app into `/var/www/html` and wrote
`/etc/httpd/conf.d/restart-demo.conf` (already covered by Step 3, listed here
in case you only want to clear the site, not the whole config):

```bash
sudo rm -rf /var/www/html
```

> Only run this if `/var/www/html` doesn't contain anything else you care
> about — it wipes the whole docroot, not just this app's files.

### Step 5 — Close the firewall rule (if you opened one)

If you followed `docs/SETUP-DEPLOY-RHEL.md` and opened HTTP in `firewalld`,
you can close it again:

```bash
sudo firewall-cmd --remove-service=http --permanent
sudo firewall-cmd --reload
```

### Step 6 — Verify Apache is gone

```bash
httpd -v
which apachectl
systemctl status httpd
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
