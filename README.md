# AWS re/Start — Batch 29 · Labs & Demos

Hands-on labs, demos, and walkthroughs for **AWS re/Start Batch 29**.
Each lab lives in its own numbered folder and is self-contained — open the folder
for today's session and follow its `README.md`.

---

## 📚 Labs

| # | Topic | What you'll do | Folder |
|---|---|---|---|
| 01 | **On-Prem vs Cloud — Website Deployment** | Deploy one *identical* web app two ways: on-premise (your WSL machine) and in the cloud (AWS EC2 with Apache). See that deployment is about the *environment*, not the code. | [`01-onprem-vs-cloud-website/`](01-onprem-vs-cloud-website/) |
| 02 | **Amazon S3 — Hands-On (Console)** | Buckets, objects & keys, versioning, encryption at rest, the three access-control layers, presigned URLs, storage classes & lifecycle, and cleanup. | [`02-s3-lab/`](02-s3-lab/) |
| 03 | **Future Labs** | Placeholder for upcoming labs (VPC, IAM, EC2 deep-dive, etc.). | [`03-future-labs/`](03-future-labs/) |

---

## 🎓 For students

1. Get the materials (your instructor will share the link or a zip):
   ```bash
   git clone <repo-url> restart-batch29
   cd restart-batch29
   ```
   *(Or download the ZIP and unzip it.)*
2. Open the folder for today's lab, e.g. `02-s3-lab/`.
3. Read that folder's `README.md` and follow along in **your own sandbox account**.
4. **Always do the Clean Up step** at the end of each lab so you're not billed.

---

## 🧑‍🏫 For the instructor

- Each lab is a numbered folder with its own `README.md`.
- To add a new lab, copy the template and fill it in:
  ```bash
  mkdir 04-my-new-lab
  cp 03-future-labs/LAB-TEMPLATE.md 04-my-new-lab/README.md
  ```
- Update the **Labs** table above with a new row so students can find it.
- Instructor-only tooling (preview server, user-data generator) is listed in
  `.gitignore` so it stays out of the student clone.

---

*AWS re/Start — Batch 29 · Maintained by the instructor.*
