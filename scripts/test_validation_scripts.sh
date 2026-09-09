#!/usr/bin/env bash

set -euo pipefail

# Exported stubs keep these failure-path checks independent of installed tools.
# Every case fails before the test script can invoke this check recursively.
cargo() {
  if [[ "${1:-}" == "${FAIL_COMMAND}" ]]; then
    return 73
  fi
  case "${1:-}" in
    --list) printf 'hack\n' ;;
    update|fmt|clippy|hack|test) return 0 ;;
    *) return 99 ;;
  esac
}

rustup() {
  if [[ "${FAIL_COMMAND}" == rustup ]]; then
    return 73
  fi
}

export -f cargo rustup
precommit=${1:-"$(dirname "${BASH_SOURCE[0]}")/precommit.sh"}

for command in update fmt rustup clippy hack test; do
  status=0
  expected=73
  if [[ ${command} == rustup ]]; then
    expected=1
  fi
  FAIL_COMMAND=${command} bash "${precommit}" >/dev/null 2>&1 || status=$?
  if [[ ${status} -ne ${expected} ]]; then
    printf 'precommit returned %s for %s failure; expected %s\n' "${status}" "${command}" "${expected}" >&2
    exit 1
  fi
done

printf 'Validation script failure propagation: passed\n'
