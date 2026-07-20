#!/usr/bin/env bash
# Removes the generated draft/<version>/rfc/ outputs for the configured
# sources (and the log directory). Leaves unrelated files, the toolchain, and
# the caches in place.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

while IFS= read -r src; do
  base="$(out_base "${src}")"
  rel_out="$(out_dir "${src}")"
  for ext in xml html txt; do
    f="${REPO_ROOT}/${rel_out}/${base}.${ext}"
    if [ -f "${f}" ]; then
      rm -f "${f}"
      echo "removed ${rel_out}/${base}.${ext}"
    fi
  done
  rmdir "${REPO_ROOT}/${rel_out}" 2>/dev/null || true
done < <(read_sources)
rm -rf "${LOG_DIR}"
echo "clean complete"
