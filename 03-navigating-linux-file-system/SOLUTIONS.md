# Solutions — Navigating the Linux File System

> Try the challenges yourself first! These assume you start at **base camp**:
> `.../practice/cloudmart`. Replace `~/restart_batch_29` with wherever you cloned the repo.

## Part 6 — Challenges

**1. Go to Project Beta (relative), then cat its README:**
```bash
cd departments/engineering/projects/beta
pwd
cat README.txt
```

**2. From Project Beta to HR policies (relative):**
```bash
cd ../../../hr/policies
pwd
```
Read it as: up out of `beta` → `projects` → `engineering` → into `departments`, then down to `hr/policies`. That's three `..` then `hr/policies`.

**3. To the 2025 finance report (absolute), from anywhere:**
```bash
cd ~/restart_batch_29/03-navigating-linux-file-system/practice/cloudmart/departments/finance/reports/2025
cat q4.txt
```
(Absolute path — starts from `~`, which expands to `/home/<you>`.)

**4. From 2025 report to 2026 report (relative, siblings):**
```bash
cd ../2026
pwd
```
Up one level to `reports`, then down into `2026`.

**5. Go home, then return:**
```bash
cd            # (or: cd ~)  -> home
cd -          # -> back to where you were
```

**6. Read alpha/notes.txt without cd (relative path to cat):**
```bash
# from base camp (cloudmart):
cat departments/engineering/projects/alpha/notes.txt
```

**7. Bonus — `cd ../../../../../../..`:**
It walks up seven levels. Once you reach `/` (the root), extra `..` just stays at `/` — you **cannot go higher than root**, because root has no parent. Verify:
```bash
cd /
cd ..
pwd     # still shows /
```

---

## Self-Check Answers

1. **Absolute** starts at the root `/` and works from anywhere; **relative** starts from your current directory (`pwd`) and depends on where you are.
2. Relative from `.../departments/hr`:
   ```bash
   cat ../engineering/team.txt
   ```
3. Absolute (same target):
   ```bash
   cat ~/restart_batch_29/03-navigating-linux-file-system/practice/cloudmart/departments/engineering/team.txt
   ```
4. `cd -` jumps back to the **previous** directory you were in (a toggle between two locations).
5. `./` means "in **this** folder." Without it, the shell only looks in the directories listed in `$PATH`, and your local `setup.sh` isn't there, so it wouldn't be found.
6. `pwd` (print working directory).

---

*AWS re/Start Batch 29 — instructor answer key.*
