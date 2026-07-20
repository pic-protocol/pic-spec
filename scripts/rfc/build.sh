#!/usr/bin/env bash
# Builds every configured RFC source: Markdown → RFCXML v3 (kramdown-rfc2629)
# → HTML + TXT (xml2rfc). Outputs land next to their sources, in
# draft/<version>/rfc/, so a single run updates every version configured in
# sources.txt. Atomic per document: outputs land in the version's rfc/ only if
# all three artifacts were produced; a failed document never clobbers a
# previous good build. Exit code is non-zero if any document failed.
#
# Usage: build.sh [--check-only]
#   --check-only  validate and convert into a scratch directory, leaving the
#                 rfc/ output directories untouched (used by check.sh).
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

CHECK_ONLY=0
[ "${1:-}" = "--check-only" ] && CHECK_ONLY=1

mkdir -p "${CACHE_DIR}" "${LOG_DIR}"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/pic-rfc.XXXXXX")"
trap 'rm -rf "${TMP_DIR}"' EXIT

failures=0
built=()

while IFS= read -r src; do
  abs="${REPO_ROOT}/${src}"
  base="$(out_base "${src}")"
  tag="$(src_tag "${src}")"
  rel_out="$(out_dir "${src}")"
  log="${LOG_DIR}/${tag}.log"
  echo "-- ${src}"
  if [ ! -f "${abs}" ]; then
    echo "   ERROR: source not found" | tee "${log}" >&2
    failures=$((failures + 1))
    continue
  fi

  txml="${TMP_DIR}/${tag}.xml"
  thtml="${TMP_DIR}/${tag}.html"
  ttxt="${TMP_DIR}/${tag}.txt"

  if ! kramdown_rfc --v3 "${abs}" > "${txml}" 2> "${log}"; then
    echo "   ERROR: kramdown-rfc2629 failed (log: ${log})" >&2
    sed 's/^/   | /' "${log}" >&2 || true
    failures=$((failures + 1))
    continue
  fi
  if ! xml2rfc_bin "${txml}" --html -o "${thtml}" --cache "${CACHE_DIR}" >> "${log}" 2>&1; then
    echo "   ERROR: xml2rfc --html failed (log: ${log})" >&2
    tail -n 20 "${log}" | sed 's/^/   | /' >&2 || true
    failures=$((failures + 1))
    continue
  fi
  if ! xml2rfc_bin "${txml}" --text -o "${ttxt}" --cache "${CACHE_DIR}" >> "${log}" 2>&1; then
    echo "   ERROR: xml2rfc --text failed (log: ${log})" >&2
    tail -n 20 "${log}" | sed 's/^/   | /' >&2 || true
    failures=$((failures + 1))
    continue
  fi

  if [ "${CHECK_ONLY}" -eq 1 ]; then
    echo "   OK (validated; outputs untouched)"
  else
    mkdir -p "${REPO_ROOT}/${rel_out}"
    mv "${txml}" "${REPO_ROOT}/${rel_out}/${base}.xml"
    mv "${thtml}" "${REPO_ROOT}/${rel_out}/${base}.html"
    mv "${ttxt}" "${REPO_ROOT}/${rel_out}/${base}.txt"
    echo "   OK -> ${rel_out}/${base}.{xml,html,txt}"
  fi
  built+=("${tag}")
done < <(read_sources)

echo
if [ "${failures}" -gt 0 ]; then
  echo "RFC build: ${failures} document(s) FAILED, ${#built[@]} OK." >&2
  exit 1
fi
echo "RFC build: all ${#built[@]} document(s) OK: ${built[*]}"
