---
name: steiner
description: "Load when a leak or breach is suspected or found: a secret committed or pasted, a token or personal data seen where it should not be, a critical finding from firion or noctis, an unexplained admin action or payment. Contain, rotate, revoke, verify, record."
---

# Steiner: the knight holds the gate

Prepare every step; run a production-changing step only on the owner's
explicit go for that step.

1. Triage (read-only, minutes): what leaked, since when, where visible,
   which environment, which users. Severity in three lines to the owner.
2. Contain: a secret in a public place is burned even if deleted (forks,
   caches). Disable the exposed key or flow; revoke sessions of a taken
   account first.
3. Rotate in order: new value in the secret store (never in git) → deploy
   or restart what reads it → revoke the old value at the provider
   (Firebase, Apple, Google, Stripe, Supabase, cloud keys). Mobile trap: an
   app secret baked into released builds needs a new app release.
4. Agent credentials are credentials too: MCP logins, read-only database
   URLs, CLI tokens. Rotate those as well.
5. Verify: the old value is refused, logs show who used it, firion sweeps
   for a second copy.
6. Record: a private timeline (no secret values), and the follow-up fix.
