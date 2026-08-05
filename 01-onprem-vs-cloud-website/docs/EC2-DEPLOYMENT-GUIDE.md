# Deploying the App to the Cloud (AWS EC2) — Student Guide

**Goal:** put the *same* app that runs on your on-prem (WSL) machine onto a rented
server in Amazon's cloud, and open it in a browser over the internet.

**Time:** ~20 minutes · **Cost:** free-tier eligible (`t2.micro` / `t3.micro`)

> Reminder: the app code does **not** change. You are just running it on a computer
> that lives in an Amazon data center instead of under your desk.

---

## What you need before you start

- An AWS account (sign in at <https://console.aws.amazon.com>).
- The `restart-demo` project folder (the same one from the on-prem exercise).
- A terminal: **WSL / macOS / Linux** have `ssh` built in. On Windows you can also
  use WSL for the `ssh` and `scp` commands below.

---

## Step 1 — Launch an EC2 instance

1. In the AWS Console search bar, type **EC2** and open it.
2. Make sure the **Region** (top-right) is close to you (e.g. *Asia Pacific
   (Singapore) ap-southeast-1*). Remember which one — you'll name it later.
3. Click **Launch instance**.
4. Fill in the form:
   - **Name:** `restart-cloud-demo`
   - **Application and OS Images:** choose **Amazon Linux 2023** (free-tier eligible).
   - **Instance type:** `t2.micro` or `t3.micro` (whichever says *Free tier eligible*).
   - **Key pair (login):** click **Create new key pair**.
     - Name it `restart-key`, type **RSA**, format **.pem**.
     - Click **Create key pair** — a file `restart-key.pem` downloads. **Keep it safe;
       you cannot download it again.**
5. Under **Network settings**, click **Edit**, then check these boxes so people can
   reach your website and you can log in:
   - ✅ **Allow SSH traffic from** → *My IP* (this is you logging in).
   - ✅ **Allow HTTP traffic from the internet** (this is visitors seeing the site).
6. Click **Launch instance**, then **View all instances**.
7. Wait until **Instance state** = *Running* and **Status check** = *2/2 checks passed*.
8. Click your instance and copy its **Public IPv4 address** (e.g. `13.250.44.10`).
   You'll use this a lot below — call it **YOUR_IP**.

---

## Step 2 — Protect your key file

In your terminal, go to where the key downloaded (usually `Downloads`) and lock it
down. SSH refuses to use a key that others could read.

```bash
cd ~/Downloads          # or wherever restart-key.pem is
chmod 400 restart-key.pem
```

> **WSL tip:** if the key is on your Windows side, copy it into WSL first, e.g.
> `cp /mnt/c/Users/<you>/Downloads/restart-key.pem ~/ && cd ~ && chmod 400 restart-key.pem`

---

## Step 3 — Copy the app up to the server

From the folder that **contains** `restart-demo` (so the whole folder goes up):

```bash
scp -i restart-key.pem -r ~/restart-demo ec2-user@YOUR_IP:~
```

- Replace **YOUR_IP** with your Public IPv4 address.
- The first time, it asks *"Are you sure you want to continue connecting?"* → type
  **yes**.
- `ec2-user` is the default username for Amazon Linux.

---

## Step 4 — Log into the server

```bash
ssh -i restart-key.pem ec2-user@YOUR_IP
```

Your prompt changes to something like `[ec2-user@ip-172-31-... ~]$`. **You are now
typing commands on the cloud server, not your laptop.**

Check the app arrived:

```bash
ls restart-demo
```

You should see `public  deploy  README.md ...`

---

## Step 5 — Deploy it as "cloud"

Still logged into the server, run the same deploy script — but tell it this is the
**cloud** environment and give it a region label:

```bash
cd ~/restart-demo
sudo ./deploy/deploy.sh cloud "AWS EC2 - ap-southeast-1"
```

(Use *your* region name.) The script installs Apache (`httpd`) and PHP, copies the
app, sets the environment, and starts the web server. Wait for it to print
**"Done. The 'cloud' instance is live"**.

Quick check, right on the server:

```bash
curl -s http://localhost/api/info.php
```

You should see JSON with `"environment": "cloud"`.

---

## Step 6 — Open your cloud website 🎉

On **any** computer, open a browser and go to:

```
http://YOUR_IP/
```

The page loads with a blue **Cloud** badge. This is your app, running in Amazon's
data center, reachable from anywhere on the internet.

**Now put two tabs side by side:**
- `http://localhost/` → your on-prem (WSL) instance, **On-Premise** badge.
- `http://YOUR_IP/` → your cloud (EC2) instance, **Cloud** badge.

Same app. Two worlds. That's the whole lesson.

---

## Step 7 — Clean up (IMPORTANT — avoid charges)

When the class is done, **stop or terminate** the instance so it doesn't keep
running:

1. EC2 Console → **Instances** → select `restart-cloud-demo`.
2. **Instance state** →
   - **Stop instance** = pause it (you can start it again later; small storage cost).
   - **Terminate instance** = delete it permanently (no more cost). Choose this if
     you're finished.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `Permission denied (publickey)` | Wrong key or username. Use `ec2-user@YOUR_IP` and the `-i restart-key.pem` you created. Re-run `chmod 400 restart-key.pem`. |
| Browser just spins / can't connect on `http://YOUR_IP/` | The **HTTP (port 80)** rule is missing. EC2 → your instance → **Security** tab → click the security group → **Edit inbound rules** → add **HTTP / port 80 / source 0.0.0.0/0** → Save. |
| `scp`/`ssh` says *Connection timed out* | The **SSH (port 22)** rule doesn't include your current IP (it may have changed). Edit inbound rules → SSH → source **My IP** again. |
| `sudo: ./deploy/deploy.sh: Permission denied` | Make it executable: `chmod +x ~/restart-demo/deploy/deploy.sh` then re-run. |
| Page shows but badge says "Unknown" | Re-run the deploy with the environment argument: `sudo ./deploy/deploy.sh cloud "AWS EC2"`. |
| Unsure it's really PHP/Apache | On the server: `sudo systemctl status httpd` and `php -v`. |

---

## Cheat sheet (copy/paste, replace YOUR_IP)

```bash
# 1. lock the key (once)
chmod 400 restart-key.pem

# 2. upload the app
scp -i restart-key.pem -r ~/restart-demo ec2-user@YOUR_IP:~

# 3. log in
ssh -i restart-key.pem ec2-user@YOUR_IP

# 4. deploy as cloud (run this ON the server)
cd ~/restart-demo && sudo ./deploy/deploy.sh cloud "AWS EC2 - your-region"

# 5. visit in a browser:  http://YOUR_IP/
```
