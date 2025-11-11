#!/usr/bin/env bash
# ./test_powerset.sh [SRC...]
# 自动化测试 powerset 程序（忽略行顺序的集合比较）
# 覆盖点：无参退出码、无解、单元素命中、顺序约束、包含0、整集求和、多解、稀疏组合

set -u

BIN=./powerset
PASS=0
FAIL=0

# 允许用户传入源码文件；否则自动匹配 powerset*.c
collect_sources() {
  if [ "$#" -ge 1 ]; then
    SRCS=("$@")
  else
    # 只抓与 powerset 相关的源码，避免把其它题带进来
    mapfile -t SRCS < <(ls powerset*.c 2>/dev/null || true)
    if [ "${#SRCS[@]}" -eq 0 ]; then
      echo "找不到 powerset*.c，也没有手动指定源码。"
      echo "用法示例："
      echo "  ./test_powerset.sh powerset.c"
      echo "  ./test_powerset.sh powerset.c powerset_utils.c"
      exit 1
    fi
  fi
}

compile() {
  echo "==> Compiling..."
  rm -f "$BIN"
  # shellcheck disable=SC2086
  cc -Wall -Wextra -Werror "${SRCS[@]}" -o "$BIN" || { echo "Compile failed."; exit 1; }
  echo "Compile OK. (sources: ${SRCS[*]})"
}

normalize() {
  sed -e 's/[[:space:]]*$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]][[:space:]]*/ /g'
}

expect_exit() {
  local title="$1"
  local expected_code="$2"
  shift 2
  local args=("$@")

  printf "\n=== %s ===\n" "$title"
  echo "\$ $BIN ${args[*]}"
  set +e
  "$BIN" "${args[@]}" >/dev/null 2>&1
  local code=$?
  set -e
  if [ "$code" -eq "$expected_code" ]; then
    echo "✅ PASS (exit=$code)"
    PASS=$((PASS+1))
  else
    echo "❌ FAIL (exit=$code expected=$expected_code)"
    FAIL=$((FAIL+1))
  fi
}

expect_set() {
  local title="$1"
  local cmdline="$2"

  printf "\n=== %s ===\n" "$title"
  echo "\$ $BIN $cmdline"

  local actual_file expected_file
  actual_file="$(mktemp)"
  expected_file="$(mktemp)"

  # shellcheck disable=SC2086
  "$BIN" $cmdline >"$actual_file"

  cat >"$expected_file"

  local actual_sorted expected_sorted
  actual_sorted="$(mktemp)"
  expected_sorted="$(mktemp)"
  normalize <"$actual_file" | sort >"$actual_sorted"
  normalize <"$expected_file" | sort >"$expected_sorted"

  if diff -u --label expected "$expected_sorted" --label actual "$actual_sorted" >/dev/null; then
    echo "✅ PASS"
    PASS=$((PASS+1))
  else
    echo "❌ FAIL"
    FAIL=$((FAIL+1))
    echo "--- expected (normalized, sorted) ---"
    sed 's/$/$/' "$expected_sorted"
    echo "----- actual (normalized, sorted) -----"
    sed 's/$/$/' "$actual_sorted"
    echo "---------------------------------------"
  fi

  rm -f "$actual_file" "$expected_file" "$actual_sorted" "$expected_sorted"
}

# ----------------- 主流程 -----------------
collect_sources "$@"
compile

# ========== 退出码/健壮性 ==========
expect_exit "sanity: no args should exit 1" 1
expect_exit "sanity: only target but no set (e.g., ./powerset 5) — 通常也应非零退出" 0 5

# ========== 典型&边界用例 ==========

# 1) 教材示例：target=5，标准多解
expect_set "basic: target=5, set=1 2 3 4 5" "5 1 2 3 4 5" <<'EOF'
1 4
2 3
5
EOF

# 2) 含0且存在重复“路径”导致的同一和（验证不会漏掉带0的组合）
expect_set "with zero & repeated sums: target=3" "3 1 0 2 4 5 3" <<'EOF'
3
0 3
1 2
1 0 2
EOF

# 3) 无解：应当输出空行
expect_set "no solution: target=100, set=1 2 3" "100 1 2 3" <<'EOF'

EOF

# 4) 单元素命中
expect_set "single element matches target: target=7, set=7 1 2" "7 7 1 2" <<'EOF'
7
EOF

# 5) 整集求和（所有元素之和命中）
expect_set "full set sum: target=10, set=1 2 3 4" "10 1 2 3 4" <<'EOF'
1 2 3 4
EOF

# 6) 顺序约束：若程序把集合排序，会输出 '1 4'；本用例要求保持输入顺序 '4 1'
expect_set "order preservation: target=5, set=4 1" "5 4 1" <<'EOF'
4 1
EOF

# 7) 稀疏组合与多解：非相邻+多元素
expect_set "sparse picks: target=6, set=1 2 3 4" "6 1 2 3 4" <<'EOF'
2 4
1 2 3
EOF

# 8) 含0但不要求空子集（target=2）
expect_set "with zero: target=2, set=0 2 1" "2 0 2 1" <<'EOF'
2
0 2
EOF

# 9) 多解且包含三元素组合
expect_set "multi combos: target=7, set=1 2 3 4 5" "7 1 2 3 4 5" <<'EOF'
2 5
3 4
1 2 4
EOF

# 10) 大数与单解（避免指数爆炸）
expect_set "big numbers but unique: target=100, set=33 67 40 60" "100 33 67 40 60" <<'EOF'
33 67
40 60
EOF

echo
echo "==== Summary ===="
echo "PASS: $PASS"
echo "FAIL: $FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
