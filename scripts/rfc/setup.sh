#!/usr/bin/env bash
# Prepares the local RFC toolchain: kramdown-rfc2629 (project-local gem dir,
# using a Homebrew/PATH Ruby >= 3.0 — never the Apple system Ruby) and xml2rfc
# (project-local Python virtual environment, pinned in requirements-rfc.txt).
# Idempotent: safe to re-run.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

echo "== RFC toolchain setup =="

# 1. Ruby + kramdown-rfc2629 -------------------------------------------------
RUBY_BIN="$(ruby_or_die)"
echo "ruby: ${RUBY_BIN} ($("${RUBY_BIN}" -e 'print RUBY_VERSION'))"

if [ -e "${GEMS_DIR}/bin/kramdown-rfc2629" ]; then
  echo "kramdown-rfc2629: already installed in ${GEMS_DIR}"
else
  echo "installing kramdown-rfc2629 into ${GEMS_DIR} ..."
  mkdir -p "${GEMS_DIR}"
  GEM_HOME="${GEMS_DIR}" GEM_PATH="${GEMS_DIR}" \
    "$(dirname "${RUBY_BIN}")/gem" install --no-document kramdown-rfc2629
fi
GEM_HOME="${GEMS_DIR}" GEM_PATH="${GEMS_DIR}" \
  "${RUBY_BIN}" "${GEMS_DIR}/bin/kramdown-rfc2629" --version

# 2. Python + xml2rfc ----------------------------------------------------------
if ! command -v python3 >/dev/null 2>&1; then
  echo "error: python3 not found. Install it (e.g. brew install python)." >&2
  exit 1
fi
if [ ! -x "${VENV_DIR}/bin/pip" ]; then
  echo "creating virtual environment ${VENV_DIR} ..."
  python3 -m venv "${VENV_DIR}"
fi
echo "installing xml2rfc (pinned in requirements-rfc.txt) ..."
"${VENV_DIR}/bin/pip" install --quiet --upgrade pip
"${VENV_DIR}/bin/pip" install --quiet -r "${REQUIREMENTS_FILE}"
"${VENV_DIR}/bin/xml2rfc" --version

# Output directories (draft/<version>/rfc/) are created per source by build.sh.
mkdir -p "${CACHE_DIR}" "${LOG_DIR}"
echo "== setup complete =="
