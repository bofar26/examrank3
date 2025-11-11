#!/usr/bin/env bash
set -euo pipefail

# === CONFIG ===
SRC="n_queen.c"
EXE="n_queen"
CFLAGS="-std=c99 -O2 -Wall -Wextra -Werror"
TEST_SET=(1 2 3 4 5 6 7 8 9 10)

# === EXPECTED SOLUTION COUNTS ===
expected_count() {
  case "$1" in
    1)  echo 1 ;;
    2)  echo 0 ;;
    3)  echo 0 ;;
    4)  echo 2 ;;
    5)  echo 10 ;;
    6)  echo 4 ;;
    7)  echo 40 ;;
    8)  echo 92 ;;
    9)  echo 352 ;;
    10) echo 724 ;;
    *)  echo -1 ;;
  esac
}

# === COMPILE (auto make or fallback cc) ===
echo "==> Building project..."
if [[ -f Makefile ]]; then
  make -s re || make -s || true
fi

if [[ ! -f "$EXE" ]]; then
  echo "No executable '$EXE' found after make, compiling manually..."
  cc $CFLAGS "$SRC" -o "$EXE"
fi

if [[ ! -x "$EXE" ]]; then
  echo "❌ Compilation failed: no executable '$EXE'"
  exit 1
fi
echo "✅ Build OK: $EXE"
echo

# === VALIDATOR ===
validate_output() {
  local file="$1" n="$2"
  awk -v n="$n" '
  NF>0{
    if (NF != n){ printf("FORMAT FAIL line %d: field count %d (expect %d)\n", NR, NF, n); exit 3 }
    split("", seen)
    for (i=1;i<=NF;i++){
      if ($i !~ /^-?[0-9]+$/){ printf("FORMAT FAIL line %d: non-int\n", NR); exit 3 }
      v = $i + 0
      if (v < 0 || v >= n){ printf("FORMAT FAIL line %d: out of range %d\n", NR, v); exit 3 }
      if (seen[v]){ printf("FORMAT FAIL line %d: duplicate row %d\n", NR, v); exit 3 }
      seen[v]=1
    }
    # 对角线冲突检测
    for (i=1;i<=NF;i++){
      for (j=i+1;j<=NF;j++){
        r1=$i+0; r2=$j+0;
        if ((r1 - r2 == j - i) || (r2 - r1 == j - i)){
          printf("CONFLICT FAIL line %d: col %d vs %d\n", NR, i-1, j-1)
          exit 3
        }
      }
    }
  }
  END{ print "OK" }
  ' "$file" >/dev/null
}

# === MAIN TEST LOOP ===
PASS=0; TOTAL=0
echo "==> Running tests..."

for n in "${TEST_SET[@]}"; do
  TOTAL=$((TOTAL+1))
  exp=$(expected_count "$n")
  if [[ "$exp" -lt 0 ]]; then
    echo "[SKIP] n=$n (no expected count)"
    continue
  fi
  tmp=$(mktemp)
  if ! "./$EXE" "$n" > "$tmp"; then
    echo "[FAIL] n=$n → program crashed"
    rm -f "$tmp"; continue
  fi
  got=$(wc -l < "$tmp" | tr -d ' ')
  if [[ "$got" != "$exp" ]]; then
    echo "[FAIL] n=$n → expected $exp lines, got $got"
    head -n 3 "$tmp"
    rm -f "$tmp"; continue
  fi
  if ! validate_output "$tmp" "$n"; then
    echo "[FAIL] n=$n → invalid output format/conflict"
    rm -f "$tmp"; continue
  fi
  echo "[OK] n=$n → $got solutions"
  PASS=$((PASS+1))
  rm -f "$tmp"
done

echo
echo "Summary: $PASS / $TOTAL tests passed ✅"
exit $(( TOTAL - PASS ))
