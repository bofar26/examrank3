#!/usr/bin/env bash
# ./test_powerset.sh [SRC...]
# 自动化测试 powerset 程序（忽略行顺序的集合比较）

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

# 用例（和之前一致）
expect_set "basic: target=5, set=1 2 3 4 5" "5 1 2 3 4 5" <<'EOF'
1 4
2 3
5
EOF

expect_set "with zero & repeated sums: target=3" "3 1 0 2 4 5 3" <<'EOF'
3
0 3
1 2
1 0 2
