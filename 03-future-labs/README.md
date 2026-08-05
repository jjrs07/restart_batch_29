# Future Labs — Batch 29 (Placeholder)

This is a placeholder for **upcoming hands-on labs** for AWS re/Start Batch 29.
As new labs are ready, each gets its own numbered folder at the repo root
(e.g. `04-vpc-networking/`, `05-iam-deep-dive/`) and a row in the main
[README](../README.md) table.

## Ideas / backlog

Tick these off as they're built. Reorder freely.

- [ ] EC2 deeper dive (AMIs, user data, instance types, EBS)
- [ ] VPC & networking (subnets, route tables, security groups vs NACLs)
- [ ] IAM deep dive (users, roles, policies, least privilege)
- [ ] RDS / databases in the cloud
- [ ] CloudWatch monitoring & alarms
- [ ] Load balancing & auto scaling
- [ ] Cost management & billing alarms
- [ ] _add your own…_

## How to add a new lab

1. Create a numbered folder:
   ```bash
   mkdir 04-my-new-lab
   ```
2. Start from the template so every lab has a consistent shape:
   ```bash
   cp 03-future-labs/LAB-TEMPLATE.md 04-my-new-lab/README.md
   ```
3. Fill in the template, then add a row to the main [README](../README.md) table.

See [`LAB-TEMPLATE.md`](LAB-TEMPLATE.md) in this folder for the starting skeleton.
