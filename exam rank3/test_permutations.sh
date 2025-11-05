#!/usr/bin/env bash
set -uo pipefail

# --- Config ---
CC="${CC:-cc}"
CFLAGS="${CFLAGS:--Wall -Wextra -Werror}"
SRC="${SRC:-permutations.c}"
BIN="${BIN:-permutations}"

TMP_DIR="$(mktemp -d)"
PASS=0
FAIL=0

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

title() {
  printf "\n\033[1m=== %s ===\033[0m\n" "$*"
}

ok()   { printf "✅ %s\n" "$*"; ((PASS++)); }
fail() { printf "❌ %s\n" "$*"; ((FAIL++)); }

build() {
  if [[ -x "./$BIN" ]]; then
    ok "Found existing executable ./$BIN (skip build)"
    return 0
  fi
  if [[ -f "$SRC" ]]; then
    title "Build"
    if $CC $CFLAGS "$SRC" -o "$BIN"; then
      ok "Build succeeded"
    else
      fail "Build failed"
      exit 1
    fi
  else
    fail "No $BIN executable and no $SRC to build"
    exit 1
  fi
}

run_case() {
  local name="$1"; shift
  local input="$1"; shift
  local expected_file="$1"; shift

  local out="$TMP_DIR/out_$name.txt"
  if ./"$BIN" "$input" > "$out"; then
    : # normal
  else
    # 题目允许无特殊错误码，这里仅记录
    :
  fi

  if diff -u "$expected_file" "$out" > "$TMP_DIR/diff_$name.txt"; then
    ok "$name"
  else
    fail "$name"
    printf -- "---- expected ----\n"
    cat "$expected_file"
    printf -- "----- actual -----\n"
    cat "$out"
    printf -- "-------------------\n"
  fi
}

run_noarg_check() {
  local out="$TMP_DIR/out_noarg.txt"
  title "Sanity: no-arg behavior"
  if ./"$BIN" > "$out"; then :; fi
  # 预期只有一个换行
  if printf "\n" | cmp -s - "$out"; then
    ok "no args => prints single newline"
  else
    fail "no args => expected single newline"
    printf -- "----- actual -----\n"
    cat -v "$out"
    printf -- "-------------------\n"
  fi
}

# --- Prepare expected outputs ---
prep_expected() {
  # a
  cat > "$TMP_DIR/exp_a.txt" <<'EOF'
a
EOF

  # ab
  cat > "$TMP_DIR/exp_ab.txt" <<'EOF'
ab
ba
EOF

  # abc（字典序）
  cat > "$TMP_DIR/exp_abc.txt" <<'EOF'
abc
acb
bac
bca
cab
cba
EOF

  # abcd（字典序）
  cat > "$TMP_DIR/exp_abcd.txt" <<'EOF'
abcd
abdc
acbd
acdb
adbc
adcb
bacd
badc
bcad
bcda
bdac
bdca
cabd
cadb
cbad
cbda
cdab
cdba
dabc
dacb
dbac
dbca
dcab
dcba
EOF
}

# --- Main ---
title "permutations tester"
build
prep_expected
run_noarg_check

title "Deterministic cases"
run_case "single a" "a"       "$TMP_DIR/exp_a.txt"
run_case "two ab"   "ab"      "$TMP_DIR/exp_ab.txt"
run_case "three abc" "abc"    "$TMP_DIR/exp_abc.txt"
run_case "four abcd" "abcd"   "$TMP_DIR/exp_abcd.txt"

title "Order-insensitivity (input scrambled)"
# 即使输入乱序，输出也应与排序后同一套
run_case "scrambled cba -> abc perms"  "cba"   "$TMP_DIR/exp_abc.txt"
run_case "scrambled dacb -> abcd perms" "dacb" "$TMP_DIR/exp_abcd.txt"

title "Summary"
printf "Passed: %d, Failed: %d\n" "$PASS" "$FAIL"
[[ $FAIL -eq 0 ]]
