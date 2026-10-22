---
name: auron
description: "Load BEFORE writing or changing any code, by the main session or any builder. The code rules: read first, the laziness ladder (the least code that works), the never-cut list, the 300/500 line limits, write-it-right-once, fast by default."
---

# Auron: no wasted motion

A legendary guardian wastes no swing. Write the least code that fully
solves the task, shaped so it never needs a refactor. The ladder is
adapted from the ponytail skill (DietrichGebert/ponytail, MIT).

## 1. Read first, then climb the ladder

Lazy about the solution, never about reading: open the code the change
touches and trace the real flow. Then stop at the FIRST rung that holds:
1. Does this need to exist at all?
2. Is it already in this codebase? (search before writing a helper,
   widget, hook, provider, query, i18n key)
3. Does the standard library do it?
4. Is there a platform or framework feature? (a Material widget, a browser
   API, a router feature, the database itself)
5. Is there a dependency already installed? Never add one for a few lines.
6. Can it be one line?
7. Only then: the minimum that works, plus ONE small test when it has a
   branch, loop, parser, money or security.

## 2. Never cut

Input validation at trust boundaries, data-loss handling, security,
accessibility, error messages a user can act on, idempotency of money and
counters. Small because necessary, never golfed. A deliberate shortcut gets
`// shortcut: <what> — revisit when <condition>`.

## 3. File size (enforced by the Mini spell)

Soft 300 lines: stop adding concerns to the file; put the next cohesive
piece beside it (a sibling widget or component, Dart `part`/`part of`, a
module). Hard 500: a change may not take a file over it or grow one
already over it. Generated files, i18n, migrations and tests are exempt.
The fix is cohesion, never line golf.

## 4. Write it right once

Follow the surrounding code (naming, comment density, layering). `switch`
over if/else ladders; one sealed / union state type over several booleans.
Inline first, extract on the third real use. No drive-by refactors in a
feature change (note them for cecil).

## 5. Fast by default (measured, not guessed)

No N+1: one query or batched endpoint per list. One poll per screen, opt-in.
Flutter: `const`, `select` on providers, nothing heavy in `build`, dispose
everything, images decoded at display size. Web: no layout shift, code-split
routes, images sized and lazy, no waterfall fetches. Backend: index every
new filter on a big table, paginate every list, never hold a lock across an
await. Optimise a hot path only with a number.

## 6. Close every change

Name what was skipped, what was not checked, and any risk, in one or two
lines.
