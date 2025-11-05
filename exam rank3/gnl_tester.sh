#!/usr/bin/env bash
# gnl_tester.sh — Automated tester for get_next_line
# Usage: chmod +x gnl_tester.sh && ./gnl_tester.sh
# Requires: get_next_line.c and get_next_line.h in the same folder.
# Compiles any get_next_line*.c (utils supported). No libft required.

set -u

# ====== pretty colors ======
RED="\033[31m"; GRN="\033[32m"; YEL="\033[33m"; BLU="\033[34m"; DIM="\033[2m"; RST="\033[0m"

echo -e "${BLU}==> GNL auto-tester starting...${RST}"

# ====== sanity checks ======
if ! ls get_next_line*.c >/dev/null 2>&1; then
  echo -e "${RED}ERROR:${RST} missing get_next_line.c (and .h). Put them beside this script."
  exit 1
fi
if [ ! -f get_next_line.h ]; then
  echo -e "${RED}ERROR:${RST} missing get_next_line.h."
  exit 1
fi

# ====== build test driver main ======
TEST_MAIN=__gnl_test_driver.c
cat > "$TEST_MAIN" <<'MAIN_C'
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include "get_next_line.h"

/* minimal helpers: */
static void put_str(const char *s) { if (s) write(1, s, __builtin_strlen(s)); }
/* Fallback when no builtin strlen available (some compilers): */
#ifndef __has_builtin
#define __has_builtin(x) 0
#endif
#if !__has_builtin(__builtin_strlen)
static size_t my_len(const char *s){ size_t n=0; if(!s) return 0; while(s[n]) n++; return n; }
#undef put_str
static void put_str(const char *s) { if (s) write(1, s, my_len(s)); }
#endif

int main(int argc, char **argv)
{
    int fd = 0; /* default stdin */
    if (argc == 2 && !(argv[1][0] == '-' && argv[1][1] == '\0')) {
        fd = open(argv[1], O_RDONLY);
        if (fd < 0) return 1;
    }
    char *line;
    while ((line = get_next_line(fd)) != NULL) {
        /* Echo exactly what GNL returns; DO NOT add extra chars. */
        put_str(line);
        free(line);
    }
    if (fd > 0) close(fd);
    return 0;
}
MAIN_C

# ====== prepare fixtures ======
IN_DIR="__gnl_inputs"
OUT_DIR="__gnl_outputs"
BIN_DIR="__gnl_bins"
LOG_DIR="__gnl_logs"
rm -rf "$IN_DIR" "$OUT_DIR" "$BIN_DIR" "$LOG_DIR"
mkdir -p "$IN_DIR" "$OUT_DIR" "$BIN_DIR" "$LOG_DIR"

# helper: make a long line (length N) optionally with newline
mk_long() {
  local path="$1" len="$2" with_nl="$3"
  : > "$path"
  # Use perl for speed/portability; fallback to yes/head if not available
  if command -v perl >/dev/null 2>&1; then
    perl -e 'my $n=shift; print "a"x$n;' "$len" >> "$path"
  else
    yes a | head -c "$len" >> "$path"
  fi
  [ "$with_nl" = "1" ] && printf "\n" >> "$path"
}

# Files:
# 1) empty
: > "$IN_DIR/t1_empty.txt"

# 2) single newline only
printf "\n" > "$IN_DIR/t2_single_newline.txt"

# 3) single line, no trailing NL
printf "hello" > "$IN_DIR/t3_no_trailing_nl.txt"

# 4) multi-lines with empty lines inside (mix of \n and text)
cat > "$IN_DIR/t4_mixed.txt" <<'EOF'
first line
second line

fourth line (after an empty one)
EOF

# 5) long line > typical buffer (10_000 chars + \n), then "END\n", then "LAST"(no NL)
mk_long "$IN_DIR/t5_long_then_more.txt" 10000 1
printf "END\nLAST" >> "$IN_DIR/t5_long_then_more.txt"

# 6) many short lines (to check tight loops)
for i in $(seq 1 50); do echo "line $i"; done > "$IN_DIR/t6_many_short.txt"

# 7) only newlines (5 newlines)
printf "\n\n\n\n\n" > "$IN_DIR/t7_only_newlines.txt"

# ====== buffer sizes to test ======
BUFFER_SIZES=(1 2 3 4 5 7 8 16 32 64 128 1024)

# ====== compile & test ======
TOTAL=0; FAIL=0
FILES=("$IN_DIR"/t*.txt)

compile_one() {
  local bs="$1"
  local bin="$BIN_DIR/gnl_bs_${bs}"
  local log="$LOG_DIR/build_bs_${bs}.log"
  # Try to compile all get_next_line*.c with the driver
  if cc -Wall -Wextra -Werror -D BUFFER_SIZE="$bs" "$TEST_MAIN" get_next_line*.c -o "$bin" >"$log" 2>&1; then
    echo "$bin"
  else
    echo -e "${RED}[BUILD FAIL]${RST} BUFFER_SIZE=${bs}"
    echo -e "${DIM}$(sed -n '1,120p' "$log")${RST}"
    echo ""
    echo "" # return empty
  fi
}

run_case() {
  local bs="$1" bin="$2" input="$3"
  local base="${input##*/}"
  local out="$OUT_DIR/${base}.bs${bs}.out"
  local ref="$OUT_DIR/${base}.ref"
  # Reference output = cat the file
  cat "$input" > "$ref"
  # Run test program
  if ! "$bin" "$input" > "$out" 2>"$LOG_DIR/run_${base}_bs${bs}.log"; then
    echo -e "  ${RED}RUN ERR${RST} ${base}"
    return 1
  fi
  if diff -u --label="gnl($base,bs=$bs)" --label="cat($base)" "$out" "$ref" >"$LOG_DIR/diff_${base}_bs${bs}.log"; then
    echo -e "  ${GRN}PASS${RST} ${base}"
    return 0
  else
    echo -e "  ${RED}FAIL${RST} ${base} (see ${LOG_DIR}/diff_${base}_bs${bs}.log)"
    return 1
  fi
}

run_stdin_case() {
  local bs="$1" bin="$2" name="$3" payload="$4"
  local out="$OUT_DIR/${name}.bs${bs}.out"
  local ref="$OUT_DIR/${name}.ref"
  printf "%b" "$payload" > "$ref"
  if ! printf "%b" "$payload" | "$bin" - > "$out" 2>"$LOG_DIR/run_${name}_bs${bs}.log"; then
    echo -e "  ${RED}RUN ERR${RST} ${name}"
    return 1
  fi
  if diff -u --label="gnl(stdin:$name,bs=$bs)" --label="echo:$name" "$out" "$ref" >"$LOG_DIR/diff_${name}_bs${bs}.log"; then
    echo -e "  ${GRN}PASS${RST} ${name}"
    return 0
  else
    echo -e "  ${RED}FAIL${RST} ${name} (see ${LOG_DIR}/diff_${name}_bs${bs}.log)"
    return 1
  fi
}

echo -e "${BLU}==> Building & running across BUFFER_SIZE: ${BUFFER_SIZES[*]}${RST}"
for bs in "${BUFFER_SIZES[@]}"; do
  echo -e "${YEL}-- BUFFER_SIZE=${bs} --${RST}"
  bin="$(compile_one "$bs")"
  if [ -z "${bin}" ]; then
    # count a single fail for the whole BS group
    ((FAIL++))
    continue
  fi

  # file-based cases
  for f in "${FILES[@]}"; do
    ((TOTAL++))
    if ! run_case "$bs" "$bin" "$f"; then ((FAIL++)); fi
  done

  # stdin cases
  ((TOTAL++)); run_stdin_case "$bs" "$bin" "stdin_simple" "abc\ndef\n" || ((FAIL++))
  ((TOTAL++)); run_stdin_case "$bs" "$bin" "stdin_no_nl" "last_line_no_nl" || ((FAIL++))
  # long stdin > buffer with and without trailing newline
  ((TOTAL++)); run_stdin_case "$bs" "$bin" "stdin_long_nl" "$(printf 'x%.0s' {1..8192}; printf '\nEND\n')" || ((FAIL++))
  ((TOTAL++)); run_stdin_case "$bs" "$bin" "stdin_long_no_nl" "$(printf 'y%.0s' {1..5000})" || ((FAIL++))
done

# ====== optional valgrind check (if present) ======
if command -v valgrind >/dev/null 2>&1; then
  echo -e "${BLU}==> Optional: quick valgrind leak check (BUFFER_SIZE=32, t5_long_then_more.txt)...${RST}"
  bin="$(compile_one 32)"
  if [ -n "$bin" ]; then
    valgrind --leak-check=full --error-exitcode=42 "$bin" "$IN_DIR/t5_long_then_more.txt" \
      >/dev/null 2>"$LOG_DIR/valgrind.log"
    if [ $? -eq 0 ]; then
      echo -e "  ${GRN}VALGRIND PASS${RST}"
    else
      echo -e "  ${RED}VALGRIND FAIL${RST} (see ${LOG_DIR}/valgrind.log)"
      ((FAIL++))
    fi
  fi
fi

# ====== summary ======
PASS=$((TOTAL - FAIL))
echo ""
if [ $FAIL -eq 0 ]; then
  echo -e "${GRN}All tests passed!${RST} ${PASS}/${TOTAL}"
else
  echo -e "${YEL}Summary:${RST} ${PASS}/${TOTAL} passed, ${FAIL} failed"
  echo -e "${DIM}Inspect logs in ${LOG_DIR}/ for diffs or build errors.${RST}"
fi

exit $([ $FAIL -eq 0 ] && echo 0 || echo 1)
