#!/usr/bin/env bash

# Runs an installed tool on real code, which `<tool> --version` does not do.
#
# clang-tidy, clang-query and clang-include-cleaner need clang's builtin
# headers (stddef.h, stdarg.h, ...) in ../lib/clang/<version>/include next to
# the executable. The first test file includes only those headers, so it
# passes on every platform when the plugin installed them, and fails with
# "'stddef.h' file not found" when it did not.
#
# Usage: scripts/test-code.bash <tool> [hosted]
#   hosted  also check a file that includes the system's C library
#           (needs the system headers: an SDK on macOS, libc6-dev on Linux)

set -euo pipefail

tool="$1"
hosted="${2:-}"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cat >"$work/builtin.cpp" <<'EOF'
#include <limits.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

int sum(int count, ...) {
  va_list args;
  va_start(args, count);
  int total = 0;
  for (int i = 0; i < count; ++i)
    total += va_arg(args, int);
  va_end(args);
  return total;
}

const size_t int_size = sizeof(int32_t);
const bool positive = INT_MAX > 0;
int *pointer = 0;
EOF
builtin_flags=(-std=c++11 -ffreestanding -nostdlibinc)

cat >"$work/hosted.c" <<'EOF'
#include <stddef.h>
#include <stdio.h>
#include <string.h>

size_t length(const char *text) {
  printf("%s\n", text);
  return strlen(text);
}
int *pointer = 0;
EOF

# Prints the output and fails when the tool reports an error.
check() {
  local output status=0
  echo ">>> $*"
  output=$("$@" 2>&1) || status=$?
  echo "$output"
  if [ "$status" -ne 0 ] || echo "$output" | grep -q "error:"; then
    echo "FAILED: $1 exited with $status or reported an error" >&2
    exit 1
  fi
}

cd "$work"
case "$tool" in
clang-tidy)
  check clang-tidy --checks='-*,bugprone-*' builtin.cpp -- "${builtin_flags[@]}"
  if [ -n "$hosted" ]; then
    check clang-tidy --checks='-*,bugprone-*' hosted.c --
  fi
  ;;
clang-query)
  check clang-query -c 'match varDecl(hasName("pointer"))' builtin.cpp -- "${builtin_flags[@]}"
  if [ -n "$hosted" ]; then
    check clang-query -c 'match varDecl(hasName("pointer"))' hosted.c --
  fi
  ;;
clang-include-cleaner)
  check clang-include-cleaner --print=changes builtin.cpp -- "${builtin_flags[@]}"
  ;;
*)
  echo "No code test for $tool"
  ;;
esac
