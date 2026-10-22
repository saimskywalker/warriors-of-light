---
name: rikku
description: "Load when a PR has red or cancelled checks, or when asked why CI failed."
---

# Rikku: take the machine apart, find the broken gear

1. Send lightning for the failing items (file:line + first real error).
2. Classify: REAL (fix it), FLAKE (rerun once, then treat as REAL),
   INFRA (runner lost, cancelled, quota: rerun, do not touch code).
3. REAL static errors → warrior-of-light; REAL test failures → clive.
4. Reproduce locally only with the narrowest command, through the queue.
5. After a fix: push, wait with ONE background waiter, report each check.
Never mark a check as passing by skipping it or loosening a test.
