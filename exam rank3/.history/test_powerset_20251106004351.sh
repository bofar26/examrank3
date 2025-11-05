#!/usr/bin/env bash
# ./test_powerset.sh
# 自动化测试 powerset 程序（忽略行顺序的集合比较）

set -u

BIN=./powerset

# -------- 编译 --------
compile() {
  echo "==> Compiling..."
  rm -f "$BIN"
  cc -Wall -Wextra -Werror *.c -o "$BIN" || { echo "Compile failed."; exit 1; }
  echo "Compile OK."
}

# -------- 规范化输出：去首尾空白、压缩多空格为单空格 --------
normalize() {
  # 逐行 trim，并把多个空格压成一个空格；保留空行（用于 target=0 的空集）
  sed -e 's/[[:space:]]*$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]][[:space:]]*/ /g'
}

# -------- 比较两组行（忽略行顺序）--------
# 用法：expect_set "标题" "<命令行>" <<'EOF'
# 期望行1
# 期望行2
# ...
# EOF
expect_set() {
  local title="$1"
  local cmdline="$2"

  printf "\n=== %s ===\n" "$title"
  echo "\$ $BIN $cmdline"

  # 运行被测程序并抓取标准输出
  local actual_file expected_file
  actual_file="$(mktemp)"
  expected_file="$(mktemp)"

  # 注意：我们只比较 stdout；若你想看 cat -e 效果，可取消下一行注释：
  # "$BIN" $cmdline | cat -e

  # 真实执行
  # shellcheck disable=SC2086
  "$BIN" $cmdline >"$actual_file"

  # 读入期望（来自 heredoc）
  cat >"$expected_file"

  # 规范化 + 排序
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
    cat "$expected_sorted" | sed 's/$/$/'
    echo "----- actual (normalized, sorted) -----"
    cat "$actual_sorted" | sed 's/$/$/'
    echo "---------------------------------------"
  fi

  rm -f "$actual_file" "$expected_file" "$actual_sorted" "$expected_sorted"
}

PASS=0
FAIL=0

compile

# -------- 用例（来自题目示例）--------

# 1) ./powerset 5 1 2 3 4 5
expect_set "basic: target=5, set=1 2 3 4 5" "5 1 2 3 4 5" <<'EOF'
1 4
2 3
5
EOF

# 2) ./powerset 3 1 0 2 4 5 3
# 题目示例显示了 4 行（没有空集）
expect_set "with zero & repeated sums: target=3" "3 1 0 2 4 5 3" <<'EOF'
3
0 3
1 2
1 0 2
EOF

# 3) ./powerset 12 5 2 1 8 4 3 7 11
expect_set "bigger set: target=12" "12 5 2 1 8 4 3 7 11" <<'EOF'
8 4
1 11
1 4 7
1 8 3
2 3 7
5 7
5 4 3
5 2 1 4
EOF

# 4) ./powerset 0 1 -1
# 空集 + (1 -1)
expect_set "zero target with negatives" "0 1 -1" <<'EOF'

1 -1
EOF

# 5) ./powerset 7 3 8 2   （无解 => 空输出）
expect_set "no solution -> empty output" "7 3 8 2" <<'EOF'
EOF

# 6) 更多覆盖：含负数、0、较长序列
expect_set "mixed: target=0 set includes negatives and zero" "0 -1 1 2 3 -2" <<'EOF'

-1 1
-1 1 2 -2
2 -2
EOF

expect_set "mixed: target=-1" "-1 1 2 3 4 5 -10" <<'EOF'
-10 1 2 3 4
-10 1 2 8
-10 3 6
-10 4 5
EOF

# -------- 总结 --------
echo
echo "=== SUMMARY ==="
echo "PASS: $PASS"
echo "FAIL: $FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
