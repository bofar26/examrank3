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

# run one deterministic case
run_case() {
  name=$1
  pat=$2
  input=$3
  out=$(printf '%s' "$input" | "$FILTER" "$pat" </dev/null)
  # 期望值用 sed（我们只测字母模式，安全）
  # 生成等长星号
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
if [ $code -eq 1 ]; then say "✅ PASS: empty arg (exit=1)"; PASS=$((PASS+1)); else say "❌ FAIL: empty arg (exit=$code, expect 1)"; FAIL=$((FAIL+1)); fi
# 多参数
"$FILTER" abc def </dev/null >/dev/null 2>&1
code=$?
if [ $code -eq 1 ]; then say "✅ PASS: multiple args (exit=1)"; PASS=$((PASS+1)); else say "❌ FAIL: multiple args (exit=$code, expect 1)"; FAIL=$((FAIL+1)); fi

say ""
say "=== Deterministic cases ==="
run_case "simple replace"   "abc"     "abcdefaaaabcdeabcabcdabc"
run_case "overlap"          "ababc"   "ababcabababc"
run_case "no match"         "xyz"     "hello world"
run_case "all match"        "aaa"     "aaaaaa"
run_case "boundary start"   "he"      "hello"
run_case "boundary end"     "ld"      "hello world"
run_case "adjacent repeats" "aba"     "ababa"
run_case "long pattern"     "bonjour" "bonjour bon jourbonjourx"

# 多行（不用 $'...\n'，用 printf 喂换行）
in_multiline=$(printf 'foo\nbarfoo\nbaz\n')
out=$(printf '%s' "$in_multiline" | "$FILTER" "foo" </dev/null)
exp=$(printf '%s' "$in_multiline" | sed "s/foo/***/g")
assert_eq "multiline (pat='foo')" "$exp" "$out"

say ""
printf '=== Summary ===\nPASS: %d  FAIL: %d\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
