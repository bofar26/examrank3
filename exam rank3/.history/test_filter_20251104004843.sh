#!/bin/sh
# Minimal, POSIX-only test script for ./filter

FILTER="./filter"
PASS=0
FAIL=0

say() { printf '%s\n' "$*"; }

# simple assert (exact string match)
assert_eq() {
  name=$1
  expect=$2
  got=$3
  if [ "x$expect" = "x$got" ]; then
    say "✅ PASS: $name"
    PASS=$((PASS+1))
  else
    say "❌ FAIL: $name"
    say "---- expected ----"
    printf '%s\n' "$expect"
    say "----- actual -----"
    printf '%s\n' "$got"
    say "-------------------"
    FAIL=$((FAIL+1))
  fi
}

# run one deterministic case (⚠️ 不要给 </dev/null ！)
run_case() {
  name=$1
  pat=$2
  input=$3
  out=$(printf '%s' "$input" | "$FILTER" "$pat")
  # 期望值用 sed（这里测的都是字母模式，安全）
  stars=$(printf '%*s' $(printf '%s' "$pat" | wc -c) '' | tr ' ' '*')
  exp=$(printf '%s' "$input" | sed "s/${pat}/${stars}/g")
  assert_eq "$name (pat='$pat')" "$exp" "$out"
}

# ----- exit code checks -----
say "=== Sanity: exit code checks ==="
# 无参数
"$FILTER" </dev/null >/dev/null 2>&1
code=$?
if [ $code -eq 1 ]; then say "✅ PASS: no args (exit=1)"; PASS=$((PASS+1)); else say "❌ FAIL: no args (exit=$code, expect 1)"; FAIL=$((FAIL+1)); fi
# 空参数
"$FILTER" "" </dev/null >/dev/null 2>&1
code=$?
if [ $code -eq 1 ]; then say "✅ PASS: empty arg
