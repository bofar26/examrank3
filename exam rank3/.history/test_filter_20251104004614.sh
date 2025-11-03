#!/usr/bin/env bash
# test_filter.sh — tests for the "filter" assignment program.
# Usage: chmod +x test_filter.sh && ./test_filter.sh

set -u

FILTER="./filter"   # 如果你的程序不是 ./filter，这里改一下
PASS=0
FAIL=0

# 生成与 pat 等长的星号
stars_of_len() {
  local n="$1"
  /usr/bin/printf '%*s' "$n" '' | tr ' ' '*'
}

# 得到“字面量替换”的期望输出：
# 优先用 perl（\Q...\E 可避免正则语义），否则退化用 sed（仅安全于字母数字的 pat）
expected_output() {
  local input="$1"
  local pat="$2"
  local stars
  stars="$(stars_of_len "${#pat}")"

  if command -v perl >/dev/null 2>&1; then
    perl -pe "s/\Q${pat}\E/${stars}/g" <<< "$input"
  else
    # 退化：尽量少用元字符。随机测试里我们只生成 a-z，避免误差。
    local escaped="${pat//|/\\|}"
    sed "s|${escaped}|${stars}|g" <<< "$input"
  fi
}

# 断言工具（全部使用安全 printf）
assert_eq() {
  local expect="$1"
  local got="$2"
  local name="$3"
  if [[ "$expect" == "$got" ]]; then
    /usr/bin/printf '%s\n' "✅ PASS: $name"
    ((PASS++))
  else
    /usr/bin/printf '%s\n' "❌ FAIL: $name"
    /usr/bin/printf '%s\n' '---- expected ----'
    /usr/bin/printf '%s\n' "$expect"
    /usr/bin/printf '%s\n' '----- actual -----'
    /usr/bin/printf '%s\n' "$got"
    /usr/bin/printf '%s\n' '-------------------'
    ((FAIL++))
  fi
}

# 运行一个功能用例：给定 pat 和 input
run_case() {
  local name="$1"
  local pat="$2"
  local input="$3"

  # 明确从 printf 提供输入，避免读取 tty
  local out
  out="$(/usr/bin/printf '%s' "$input" | "$FILTER" "$pat" </dev/null)" || true
  local exp
  exp="$(expected_output "$input" "$pat")"
  assert_eq "$exp" "$out" "$name (pat='$pat')"
}

# 校验退出码（无参 / 空参 / 多参）：强制把 stdin 关成空，避免程序阻塞
expect_exit() {
  local name="$1"
  shift
  local code=0
  "$FILTER" "$@" </dev/null >/dev/null 2>&1 || code=$?
  if [[ "$code" -eq 1 ]]; then
    /usr/bin/printf '%s\n' "✅ PASS: $name (exit=1)"
    ((PASS++))
  else
    /usr/bin/printf '%s\n' "❌ FAIL: $name (exit=$code, expect 1)"
    ((FAIL++))
  fi
}

# -------------------- Tests --------------------

/usr/bin/printf '%s\n' "=== Sanity: exit code checks ==="
expect_exit "no args"                           # 无参数
expect_exit "empty arg"           ""            # 空参数
expect_exit "multiple args"       "abc" "def"   # 多参数

/usr/bin/printf '\n%s\n' "=== Deterministic cases ==="
run_case "simple replace"           "abc" "abcdefaaaabcdeabcabcdabc"
run_case "overlap-sensitive"        "ababc" "ababcabababc"     # 经典重叠
run_case "no match"                 "xyz"  "hello world"
run_case "all match"                "aaa"  "aaaaaa"
run_case "mixed lines"              "foo"  $'foo\nbarfoo\nbaz'
run_case "boundary start"           "he"   "hello"
run_case "boundary end"             "ld"   "hello world"
run_case "adjacent repeats"         "aba"  "ababa"             # 相邻匹配推进
run_case "long pattern"             "bonjour" "bonjour bon jourbonjourx"
run_case "unicode safe (no hit)"    "éé"   "hello world"       # 非 ASCII 模式不命中

/usr/bin/printf '\n%s\n' "=== Random fuzz (letters only) ==="
rand_str() {
  local n="$1"
  tr -dc 'a-z' </dev/urandom | head -c "$n"
}

for i in $(seq 1 20); do
  L=$((50 + RANDOM % 151))   # 输入长度 50~200
  P=$((1 + RANDOM % 6))      # 模式长度 1~6
  IN="$(rand_str "$L")"
  PAT="$(rand_str "$P")"
  # 提高命中率：硬塞入几次 PAT
  IN="${IN:0:10}${PAT}${IN:10:20}${PAT}${IN:30}"
  run_case "fuzz#$i" "$PAT" "$IN"
done

/usr/bin/printf '\n%s\n' "=== Large input (stream-like) ==="
BIG="$(rand_str 50000)"
PAT="abc"
BIG="abc${BIG}zzzabc${BIG}endabc"
run_case "big-stream" "$PAT" "$BIG"

/usr/bin/printf '\n=== Summary ===\nPASS: %d  FAIL: %d\n' "$PASS" "$FAIL"
exit $(( FAIL > 0 ))
