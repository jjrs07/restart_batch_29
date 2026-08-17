# Student Exercises — Linux Log Management

Try each task before opening the instructor notes. Ask what each command tells you about the log.

1. From `04-linux-log-management`, run `./scripts/generate-log.sh` manually.
2. Display `~/log-demo/app.log` with both `cat` and `tail`.
3. Run `generate-log.sh` five times. Confirm that older entries remain.
4. Compare these commands:

   ```bash
   ls -l ~/log-demo/app.log
   ls -lh ~/log-demo/app.log
   wc -c ~/log-demo/app.log
   du -h ~/log-demo/app.log
   ```

5. Divide the byte count by the number of entries to calculate average bytes per entry.
6. Predict the size after 24 hours when one entry is written every five minutes.
7. Run `./scripts/calculate-log-size.sh` and compare its estimate with yours.
8. Open `cron/crontab-example.txt`, find your repository's absolute path, and manually create the five-minute entry with `crontab -e`. Ask your instructor before saving it.
9. Run `./scripts/generate-sample-logs.sh 50`, then inspect the result.
10. Read `logrotate/app-log.conf`. Explain each directive in your own words.
11. With instructor supervision, inspect and force the documented logrotate demo.
12. Run `journalctl -n 20`.
13. Run `journalctl --disk-usage`.
14. Find SSH or cron events if your system has them. Try `sudo journalctl -u sshd` or `sudo journalctl -u crond`; the unit names may instead be `ssh` and `cron`.
15. Reflect: **If storage were unlimited, should we keep every log forever? Why or why not?**

<details>
<summary>Instructor Notes / Suggested Answers</summary>

- `>>` appends, so repeated runs preserve earlier entries. `>` would overwrite them.
- `cat` prints the whole file; `tail` shows its last lines.
- `ls -l` and `wc -c` report logical file size in bytes. `ls -lh` displays that size with readable units. `du -h` reports allocated disk space, which may differ because filesystems allocate storage in blocks.
- Average bytes per entry = total bytes / total entries. At five-minute intervals, there are `24 * 60 / 5 = 288` entries per day. Estimated daily bytes = average bytes per entry × 288.
- Cron automates when the generator runs. Logrotate manages the log file lifecycle; it does not create the application entries.
- Unlimited storage does not remove privacy, security, legal-discovery, compliance, search-performance, and governance concerns. Retention must still follow policy.

</details>
