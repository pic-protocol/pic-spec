#!/usr/bin/env bash
# Validates the RFC pipeline without touching rfc/: verifies the toolchain and
# the configured sources, then converts and validates every document into a
# scratch directory. Exits non-zero if anything fails.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

echo "== RFC check =="

# toolchain present?
ruby_or_die >/dev/null
if [ ! -e "${GEMS_DIR}/bin/kramdown-rfc2629" ]; then
  echo "error: kramdown-rfc2629 missing — run: task rfc:setup" >&2
  exit 1
fi
if [ ! -x "${VENV_DIR}/bin/xml2rfc" ]; then
  echo "error: xml2rfc missing — run: task rfc:setup" >&2
  exit 1
fi

# sources present?
missing=0
while IFS= read -r src; do
  if [ ! -f "${REPO_ROOT}/${src}" ]; then
    echo "error: configured source missing: ${src}" >&2
    missing=$((missing + 1))
  fi
done < <(read_sources)
[ "${missing}" -gt 0 ] && exit 1

# full conversion + validation, rfc/ untouched.
"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/build.sh" --check-only
echo "== check complete =="
