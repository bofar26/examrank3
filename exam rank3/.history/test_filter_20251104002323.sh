#!/usr/bin/env bash
set -u

FILTER="./filter"   # 如果你的程序不叫 ./filter，这里改一下
PASS=0
FAIL=0

# 生成与 pat 等长的星号
stars_of_len() {
  local n="$1"
  # 用 printf 生成 n 个空格再替换成 *
  printf "%${n}s" "" | tr ' ' '*'
}

# 尝试用 perl 得到“字面量替换”的期望结果；若无 perl，则用 sed（仅适合字母数字的 pat）
expected_output() {
  local input="$1"
  local pat="$2"
  local stars
  stars="$(stars_of_len "${#pat}")"

  if command -v perl >/dev/null 2>&1; then
    # \Q...\E 让 pat 按“字面量”匹配，不当正则
    perl -pe "s/\Q${pat}\E/${stars}/g" <<< "$input"
  else
    # 退化方案：仅对 a-z0-9 的 pat 安全，复杂字符会当正则——
    # 所以随机测试里我们只生成 a-z，保障可用
    # 使用 '|' 作为分隔符减少转义
    local escaped="${pat//|/\\|}"
    sed "s|${escaped}|${stars}|g" <<< "$input"
  fi
}

# 单例断言工具
assert_eq() {
  local expect="$1"
  local got="$2"
  local name="$3"
  if [[ "$expect" == "$got" ]]; then
    printf "✅ PASS: %s\n" "$name"
    ((PASS++))
  else
    printf "❌ FAIL: %s\n" "$name"
    printf "---- expected ----\n%s\n" "$expect"
    printf "----- actual -----\n%s\n" "$got"
    printf "-------------------\n"
    ((FAIL++))
  fi
}

# 运行一个功能用例：给定 pat 和 input
run_case() {
  local name="$1"
  local pat="$2"
  local input="$3"

  local out
  out="$(printf "%s" "$input" | "$FILTER" "$pat")" || true
  local exp
  exp="$(expected_output "$input" "$pat")"
  assert_eq "$exp" "$out" "$name (pat='$pat')"
}

# 校验退出码的工具
expect_exit() {
  local name="$1"
  shift
  local code=0
  "$FILTER" "$@" >/dev/null 2>&1 || code=$?
  if [[ "$code" -eq 1 ]]; then
    printf "✅ PASS: %s (exit=1)\n" "$name"
    ((PASS++))
  else
    printf "❌ FAIL: %s (exit=%d, expect 1)\n" "$name" "$code"
    ((FAIL++))
  fi
}

echo "=== Sanity: exit code checks ==="
expect_exit "no args"                           # 无参数
expect_exit "empty arg"           ""            # 空参数
expect_exit "multiple args"       "abc" "def"   # 多参数

echo
echo "=== Deterministic cases ==="
run_case "simple replace"           "abc" "abcdefaaaabcdeabcabcdabc"
run_case "overlap-sensitive"        "ababc" "ababcabababc"     # 重叠场景
run_case "no match"                 "xyz"  "hello world"
run_case "all match"                "aaa"  "aaaaaa"
run_case "mixed lines"              "foo"  $'foo\nbarfoo\nbaz'
run_case "boundary start"           "he"   "hello"
run_case "boundary end"             "ld"   "hello world"
run_case "adjacent repeats"         "aba"  "ababa"             # 注意匹配推进位置
run_case "long pattern"             "bonjour" "bonjour bon jourbonjourx"

echo
echo "=== Random fuzz (letters only) ==="
rand_str() {
  # 生成给定长度的随机小写字符串
  local n="$1"
  tr -dc 'a-z' </dev/urandom | head -c "$n"
}

for i in $(seq 1 20); do
  # 随机长度：输入 50~200，模式 1~6
  L=$((50 + RANDOM % 151))
  P=$((1 + RANDOM % 6))
  IN="$(rand_str "$L")"
  # 为了更容易命中，把 pat 放进输入里几次
  PAT="$(rand_str "$P")"
  IN="${IN:0:10}${PAT}${IN:10:20}${PAT}${IN:30}"

  run_case "fuzz#$i" "$PAT" "$IN"
done

echo
echo "=== Large input (stream-like) ==="
BIG="$(rand_str 50000)"
PAT="abc"
# 插入若干次 pat
BIG="abc${BIG}zzzabc${BIG}endabc"
run_case "big-stream" "$PAT" "$BIG"

echo
printf "=== Summary ===\nPASS: %d  FAIL: %d\n" "$PASS" "$FAIL"
exit $(( FAIL > 0 ))
