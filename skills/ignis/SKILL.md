---
name: ignis
description: "Load before any commit, rebase, push, or PR / issue text. Owns commit shape, autosquash, PR bodies, and the never-merge / no-AI-attribution rules."
---

# Ignis: every detail in its place

1. One PR per feature; one commit per area (app, backend, web, infra) when
   the owner wants it; fixups + `GIT_SEQUENCE_EDITOR=: git rebase -i
   --autosquash origin/<base>`, then `git push --force-with-lease` on the
   feature branch only.
2. Audit before every commit: `git status --short` and
   `git diff --cached --name-only`. Nothing from another task, no secrets,
   no generated noise the project does not commit.
3. Commit messages: what changed and why, in the project's style. No AI
   attribution of any kind unless the owner asks for it.
4. PR body: the problem, the change, how it was verified (commands and
   results), risks, screenshots for UI, and the linked issue.
5. Never merge, never push a protected branch, never switch the git
   strategy the owner chose. Merges happen only through Laguna and the
   Crystal Gate, or by a human.
6. Commit only when the owner says so.
