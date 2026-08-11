# Navigating the Linux File System — Absolute vs Relative Paths

**AWS re/Start — Batch 29**
**Duration:** 30–45 minutes
**Format:** Follow along in your own terminal (WSL, EC2, or any Linux shell). Type every command yourself — don't copy-paste the whole thing.

---

## Before You Start

You need a Linux shell. Any of these works:
- **WSL** on Windows (Ubuntu)
- An **EC2** instance you SSH into
- The lab machine your instructor gives you

Get the practice files by building them with the setup script in this folder:

```bash
cd 03-navigating-linux-file-system
./setup.sh
```

That creates a `practice/cloudmart/` folder tree for you to explore. If you ever mess it up, just run `./setup.sh` again to reset it.

> If `./setup.sh` says *permission denied*, make it executable first: `chmod +x setup.sh`.

---

## Learning Objectives

By the end of this exercise you will be able to:

1. Explain the difference between an **absolute path** and a **relative path**
2. Use `pwd`, `ls`, and `cd` to move around the file system
3. Use the shortcuts `/`, `~`, `.`, `..`, and `cd -`
4. Reach any file or folder using **either** an absolute or a relative path
5. Read a file with `cat` to confirm you landed in the right place

---

## Part 0 — The Vocabulary (3 min)

| Term | What it means | Example |
|---|---|---|
| **Path** | The "address" of a file or folder | `/home/jsant/notes.txt` |
| **Absolute path** | Starts from the **root** `/`. Works from **anywhere**. | `/home/jsant/practice/cloudmart` |
| **Relative path** | Starts from **where you are right now** (`pwd`). | `departments/hr` |
| `/` | The **root** of the whole file system (the very top) | `cd /` |
| `~` | Shortcut for **your home** directory (e.g. `/home/jsant`) | `cd ~` |
| `.` | **This** directory (where you are now) | `./setup.sh` |
| `..` | The **parent** directory (one level up) | `cd ..` |
| `pwd` | **Print Working Directory** — "where am I?" | `pwd` |

> **The one rule to remember:**
> **Absolute paths start with `/`. Relative paths don't.**
> If a path begins with `/`, the shell reads it from the root. If it doesn't, the shell reads it starting from your current location.

---

## Part 1 — Where am I? (`pwd`) (3 min)

1. Open your terminal and go into the practice tree:

```bash
cd 03-navigating-linux-file-system/practice/cloudmart
```

2. Ask the shell where you are:

```bash
pwd
```

You'll see something like:

```
/home/jsant/restart_batch_29/03-navigating-linux-file-system/practice/cloudmart
```

**That full line — starting with `/` — is your absolute path.** Write it down; it is your "base camp" for this lab. Yours will differ depending on where you cloned the repo and your username.

> **Teaching point:** `pwd` is the most important command when you're lost. Any time a command "can't find" a file, run `pwd` first and ask: *"Relative to here, does my path make sense?"*

---

## Part 2 — Look around (`ls`) (4 min)

1. List what's in the current folder:

```bash
ls
```

You should see: `README.txt` and `departments`.

2. List with more detail (long format, shows folders vs files):

```bash
ls -l
```

3. List everything, including a peek two levels down:

```bash
ls departments
ls departments/engineering
```

Notice you just used **relative paths** (`departments`, `departments/engineering`) — they don't start with `/`, so `ls` read them starting from where you are.

**Checkpoint:** `ls departments` shows `engineering`, `finance`, and `hr`.

---

## Part 3 — Absolute paths (works from anywhere) (7 min)

An absolute path always begins with `/`, so it doesn't matter where you currently are.

1. First jump somewhere totally unrelated:

```bash
cd /
pwd        # you are now at the root
```

2. Now go **straight** to the finance 2026 reports using an **absolute path**. Replace the front part with **your** base camp from Part 1:

```bash
cd /home/<you>/restart_batch_29/03-navigating-linux-file-system/practice/cloudmart/departments/finance/reports/2026
pwd
ls
```

**Checkpoint:** `ls` shows `q1.txt` and `q2.txt`.

3. Confirm you're really there by reading a file:

```bash
cat q1.txt
```

It prints its own location — proof you navigated correctly.

> **Tip — save typing with `~`:** If your repo is under your home folder, `~` replaces the `/home/<you>` part:
> ```bash
> cd ~/restart_batch_29/03-navigating-linux-file-system/practice/cloudmart
> ```
> `~` is still an absolute path (it expands to `/home/<you>`), it's just shorter.

> **Teaching point:** Scripts and cron jobs almost always use **absolute paths**, because they can run from any working directory and must not guess where "here" is.

---

## Part 4 — Relative paths (from where you stand) (8 min)

Relative paths are shorter and are what you'll use most while working interactively. They start from your current location. The magic words are `..` (up one level) and the folder names going down.

1. Go back to base camp:

```bash
cd ~/restart_batch_29/03-navigating-linux-file-system/practice/cloudmart
pwd
```

2. Move **down** into HR's policies using a **relative** path (no leading `/`):

```bash
cd departments/hr/policies
pwd
ls
cat leave.txt
```

3. Now move **up** one level with `..`:

```bash
cd ..
pwd        # you're back in departments/hr
```

4. Go from `hr` **across** to `engineering` in one move. You go up to `departments`, then down into `engineering`:

```bash
cd ../engineering/projects/alpha
pwd
cat README.txt
```

Read that command out loud: *"up to departments (`..`), then down into engineering/projects/alpha."*

5. Stack `..` to jump up several levels at once. From `alpha`, go up **four** levels back to `cloudmart`:

```bash
cd ../../../..
pwd        # should be ...practice/cloudmart
```

> **Checkpoint:** `pwd` ends in `practice/cloudmart`.

> **Common mistake:** Forgetting the leading `/` difference. `cd departments` (relative) works from `cloudmart`. `cd /departments` (absolute) fails, because there is no `departments` folder at the root of the whole system.

---

## Part 5 — Handy shortcuts (5 min)

| Command | What it does |
|---|---|
| `cd` (alone) or `cd ~` | Jump to your **home** directory |
| `cd -` | Jump **back** to the last directory you were in (like a toggle) |
| `cd ..` | Up one level |
| `cd ../..` | Up two levels |
| `cd .` | Stay put (rarely useful alone, but `.` matters in `./script.sh`) |

Try the toggle:

```bash
cd ~/restart_batch_29/03-navigating-linux-file-system/practice/cloudmart/departments/finance
cd ~            # go home
cd -            # go straight back to finance
pwd
```

> **Why `./` before a script?** When you run `./setup.sh`, the `./` says *"the setup.sh in THIS folder"*. Without it, the shell searches its `PATH` (a list of system folders) and won't find your local script.

---

## Part 6 — Challenges (10 min)

Do these **without peeking** at `SOLUTIONS.md`. For each one, get there, run `pwd` to prove it, and `cat` a file to confirm. Start each challenge from base camp (`cloudmart`) unless told otherwise.

1. Go to **Project Beta** using a **relative** path, then `cat` its `README.txt`.
2. From Project Beta, go to the **HR policies** folder using a **relative** path (hint: lots of `..`).
3. From anywhere, go to the **2025** finance report using an **absolute** path. `cat q4.txt`.
4. From the 2025 report, reach the **2026** report using a **relative** path (they're siblings).
5. Go **home** with a single word, then return to where you were with a single command.
6. From base camp, reach `alpha/notes.txt` and read it **without using `cd`** — just `cat` a relative path.
7. **Bonus:** What does `cd ../../../../../../..` do from deep inside the tree? Try it, run `pwd`, and explain why you can't go higher than `/`.

Check your commands against [`SOLUTIONS.md`](SOLUTIONS.md) when you're done.

---

## Reset / Clean Up

- To **reset** the tree to its original state (e.g. after deleting files): run `./setup.sh` again.
- To **remove** the practice files entirely:

```bash
rm -rf 03-navigating-linux-file-system/practice
```

---

## Quick Reference Card

- **Absolute path** = starts with `/`, works from anywhere: `/home/you/dir`
- **Relative path** = no leading `/`, starts from `pwd`: `departments/hr`
- `pwd` — where am I? · `ls` — what's here? · `cd` — go there
- `~` = home · `/` = root · `.` = here · `..` = up one · `cd -` = previous dir
- Lost? Run **`pwd`** first, then decide if your path should be absolute or relative.

---

## Self-Check Questions

1. In one sentence, what is the difference between an absolute and a relative path?
2. You're in `/home/you/practice/cloudmart/departments/hr`. Write a **relative** path to `engineering/team.txt`.
3. Write the same journey as an **absolute** path.
4. What does `cd -` do?
5. Why do you type `./setup.sh` and not just `setup.sh`?
6. What is the one command that always tells you where you are?

---

*AWS re/Start Batch 29 — Navigating the Linux File System*
