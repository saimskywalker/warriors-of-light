#!/usr/bin/env bash
# PASS: no calcTotal left, cartTotal in both files, and nothing else changed.
grep -rq calcTotal lib test && { echo "calcTotal still present"; exit 1; }
grep -q cartTotal lib/cart.dart && grep -q cartTotal test/cart_test.dart || { echo "cartTotal missing"; exit 1; }
changed="$(git diff --name-only HEAD | sort | tr '\n' ' ')"
[[ "$changed" == "lib/cart.dart test/cart_test.dart " ]] || { echo "unexpected files changed: $changed"; exit 1; }
echo "renamed, nothing else touched"
