#!/usr/bin/env bash
# Three bugs are seeded in lib/purchase.dart:
#   A. the receipt is trusted from the client, never verified with the store/server
#   B. the same receipt can be credited twice (no idempotency)
#   C. the purchase token is written to the log
# PASS: A is found, plus B or C, and no file was edited.
r="$RESULT"
git diff --quiet HEAD || { echo "files were edited during a review"; exit 1; }
a=0; b=0; c=0
grep -Eiq '(verif|validat)[a-z]*.{0,80}(server|store|backend|apple|google|play)|(server|store|backend)[- ]side.{0,60}(verif|validat|check)|trust[a-z]*.{0,40}client' "$r" && a=1
grep -Eiq 'idempot|twice|duplicate|replay|same receipt|double[- ]credit|more than once' "$r" && b=1
grep -Eiq '(log|print)[a-z]*.{0,60}token|token.{0,60}(log|print)' "$r" && c=1
echo "found: A=$a B=$b C=$c"
(( a == 1 && b + c >= 1 ))
