#!/usr/bin/env bash
# PASS: the tests pass and the test file was not touched.
dart test/cart_test.dart >/dev/null 2>&1 || { echo "tests still fail"; exit 1; }
git diff --quiet HEAD -- test/ || { echo "the test file was edited"; exit 1; }
echo "fixed, test untouched"
