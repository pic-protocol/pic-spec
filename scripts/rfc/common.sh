#!/usr/bin/env bash
# Shared helpers for the RFC build pipeline (kramdown-rfc2629 + xml2rfc).
# Sourced by setup.sh / check.sh / build.sh / clean.sh.
set -euo pipefail

RFC_SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${RFC_SCRIPTS_DIR}/../.." && pwd)"

TOOLS_DIR="${REPO_ROOT}/.tools"
GEMS_DIR="${TOOLS_DIR}/gems"
VENV_DIR="${TOOLS_DIR}/xml2rfc-venv"
CACHE_DIR="${REPO_ROOT}/.cache/xml2rfc"
LOG_DIR="${REPO_ROOT}/.cache/rfc-logs"
SOURCES_FILE="${RFC_SCRIPTS_DIR}/sources.txt"
REQUIREMENTS_FILE="${REPO_ROOT}/requirements-rfc.txt"

# find_ruby prints the path of a Ruby >= 3.0. Preference order:
#   1. `ruby` on PATH (if new enough — the Apple system Ruby 2.6 is not);
#   2. the Homebrew ruby, discovered dynamically via `brew --prefix ruby`.
# System Ruby is never used to install gems.
find_ruby() {
  local candidates=() c v
  if command -v ruby >/dev/null 2>&1; then
    candidates+=("$(command -v ruby)")
  fi
  if command -v brew >/dev/null 2>&1; then
    local brew_ruby
    brew_ruby="$(brew --prefix ruby 2>/dev/null || true)/bin/ruby"
    [ -x "${brew_ruby}" ] && candidates+=("${brew_ruby}")
  fi
  for c in "${candidates[@]:-}"; do
    [ -x "${c}" ] || continue
    v="$("${c}" -e 'print RUBY_VERSION' 2>/dev/null || true)"
    case "${v}" in
      3.* | [4-9].*) printf '%s\n' "${c}"; return 0 ;;
    esac
  done
  return 1
}

# ruby_or_die prints the usable Ruby or exits with install instructions.
ruby_or_die() {
  if ! find_ruby; then
    echo "error: no Ruby >= 3.0 found." >&2
    echo "  Install one with Homebrew:  brew install ruby" >&2
    echo "  (the Apple system Ruby is too old and is never used for gems)" >&2
    exit 1
  fi
}

# kramdown_rfc runs the project-local kramdown-rfc2629 with the chosen Ruby.
kramdown_rfc() {
  local ruby_bin
  ruby_bin="$(ruby_or_die)"
  if [ ! -e "${GEMS_DIR}/bin/kramdown-rfc2629" ]; then
    echo "error: kramdown-rfc2629 is not installed. Run: task rfc:setup" >&2
    exit 1
  fi
  GEM_HOME="${GEMS_DIR}" GEM_PATH="${GEMS_DIR}" \
    "${ruby_bin}" "${GEMS_DIR}/bin/kramdown-rfc2629" "$@"
}

# xml2rfc_bin runs xml2rfc from the project-local virtual environment.
xml2rfc_bin() {
  if [ ! -x "${VENV_DIR}/bin/xml2rfc" ]; then
    echo "error: xml2rfc is not installed. Run: task rfc:setup" >&2
    exit 1
  fi
  "${VENV_DIR}/bin/xml2rfc" "$@"
}

# read_sources prints the configured source paths (repo-relative), skipping
# comments and blank lines.
read_sources() {
  grep -Ev '^[[:space:]]*(#|$)' "${SOURCES_FILE}"
}

# out_base prints the output basename (no extension) for a source path.
out_base() {
  local src="$1"
  basename "${src}" .md
}

# out_dir prints the repo-relative output directory for a source path:
# outputs live next to their sources, in <version dir>/rfc/
# (draft/0.2/pic-spec.md -> draft/0.2/rfc). One build run therefore updates
# every version configured in sources.txt.
out_dir() {
  local src="$1"
  printf '%s/rfc\n' "$(dirname "${src}")"
}

# src_tag prints a unique per-source tag for logs and temp files, so equally
# named specs from different versions (draft/0.1/pic-spec.md vs
# draft/0.2/pic-spec.md) never collide: draft/0.2/pic-spec.md -> 0.2-pic-spec.
src_tag() {
  local src="$1"
  printf '%s-%s\n' "$(basename "$(dirname "${src}")")" "$(out_base "${src}")"
}
