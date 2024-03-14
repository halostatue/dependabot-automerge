#! /usr/bin/env bash

set -eo pipefail

dn0="$(dirname "$0")"

while (($#)); do
  case "$1" in
  --trace) TRACE=1 ;;
  --changelog)
    INPUT_CHANGELOG="$2"
    shift
    ;;
  --version)
    INPUT_VERSION="$2"
    shift
    ;;
  --prefix)
    INPUT_PREFIX="$2"
    shift
    ;;
  --pattern)
    INPUT_PATTERN="$2"
    shift
    ;;
  esac

  shift
done

error() {
  printf "::error ::%s\n" "$1"
  exit 1
}

if [[ -z "${INPUT_VERSION}" ]]; then
  error "No version provided"
fi

if [[ -z "${INPUT_CHANGELOG}" ]]; then
  error "No changelog provided"
elif ! [[ -r "${INPUT_CHANGELOG}" ]]; then
  error "$(printf "Cannot find changelog %q" "{INPUT_CHANGELOG}")"
fi

case "${INPUT_PATTERN}" in
bare | '') INPUT_PATTERN="%v" ;;
bracket) INPUT_PATTERN="[%v]" ;;
*%v*) : ;;
*)
  error "$(printf "Invalid pattern input (missing %%v): %q" "${INPUT_PATTERN}")"
  ;;
esac

[[ -z "${INPUT_PREFIX}" ]] && INPUT_PREFIX='##'

EOF=$(dd if=/dev/urandom bs=15 count=1 status=none | base64)
{
  echo "contents<<$EOF"

  awk -v version="${INPUT_VERSION}" \
    -v prefix="${INPUT_PREFIX}" \
    -v base_pattern="${INPUT_PATTERN}" \
    -v trace="${TRACE}" \
    -f "${dn0}"/extract-changelog.awk \
    "${INPUT_CHANGELOG}"

  echo "$EOF"
} >>"$GITHUB_OUTPUT"
