#! /usr/bin/env bash

set -eo pipefail

if [[ -z "${GITHUB_REPOSITORY}" ]]; then
  GITHUB_REPOSITORY='{owner}/{repo}'
fi

declare INPUT_REF DEFAULT_BRANCH ALLOWED
declare TARGET_SHA TARGET_NAME TARGET_TYPE

while (($#)); do
  case "$1" in
  --trace) TRACE=1 ;;
  --ref)
    INPUT_REF="$2"
    shift
    ;;
  --default)
    DEFAULT_BRANCH="$2"
    shift
    ;;
  --allowed)
    ALLOWED="$2"
    shift
    ;;
  esac

  shift
done

[[ -z "${ALLOWED:-}" ]] && ALLOWED="pr,branch,tag,commit"

allowed() {
  # shellcheck disable=SC2076
  [[ ",${ALLOWED}," =~ ,"$1", ]]
}

ref() {
  local ref

  if ! ref="$(gh api "repos/${GITHUB_REPOSITORY}/git/ref/$1" --jq .object.sha 2>&1)"; then
    echo "${ref}"
    return 1
  fi

  echo "${ref}"
}

commit() {
  local ref

  if ! ref="$(gh api "repos/${GITHUB_REPOSITORY}/git/commits/$1" --jq .sha 2>&1)"; then
    echo "${ref}"
    return 1
  fi

  echo "${ref}"
}

pulls() {
  local pull

  if ! pull="$(gh api "repos/${GITHUB_REPOSITORY}/pulls/$1" 2>&1)"; then
    echo "${pull}"
    return 1
  fi

  [[ "$(jq '.state == "closed"' <<<"${pull}")" == true ]] && return 1
  [[ "$(jq .merged <<<"${pull}")" == true ]] && return 1

  jq --raw-output .head.ref <<<"${pull}"
}

[[ ${TRACE:-} == 1 ]] && set -x

if [[ -z "${INPUT_REF:-}" ]] && [[ -z "${DEFAULT_BRANCH:-}" ]]; then
  # Neither input ref nor default branch have a value. Resolution will be based
  # on the repo default branch.
  declare repo_default_branch
  if ! repo_default_branch="$(gh api "repos/${GITHUB_REPOSITORY}" --jq .default_branch)"; then
    printf "::error ::Cannot find default branch and no ref provided:\n%s\n" \
      "${repo_default_branch}"
    exit 1
  fi

  if ! TARGET_SHA="$(ref "heads/${repo_default_branch}")"; then
    printf "::error ::Cannot resolve repo default branch %s into a SHA reference.\n%s\n" \
      "${repo_default_branch}" "${TARGET_SHA}"
    exit 1
  fi

  TARGET_NAME="${repo_default_branch}"
  TARGET_TYPE=repo-default-branch
elif [[ -z "${INPUT_REF:-}" ]]; then
  # Default branch has a value. Resolve it.
  if ! TARGET_SHA="$(ref "heads/${DEFAULT_BRANCH:-}" --jq .default_branch)"; then
    printf "::error ::Cannot resolve input default-branch %s into a SHA reference.\n%s\n" \
      "${DEFAULT_BRANCH:-}" "${TARGET_SHA}"
    exit 1
  fi

  TARGET_NAME="${DEFAULT_BRANCH}"
  TARGET_TYPE=default-branch
else
  if allowed pr && [[ "${INPUT_REF}" =~ ^#?([[:digit:]]+$) ]]; then
    declare pr_number pr_ref pr_branch
    pr_number="${BASH_REMATCH[1]}"

    if ! pr_ref="$(pulls "${pr_number}")"; then
      printf "::error ::Cannot resolve input ref %s to an open pull request.\n%s\n" \
        "${INPUT_REF}" "${pr_ref}"
      exit 1
    fi

    if ! pr_branch="$(ref "heads/${pr_ref}")"; then
      printf "::error ::Cannot resolve pull request #%s (%s) to an open pull request.\n%s\n" \
        "${pr_number}" "${pr_ref}" "${pr_branch}"
    else
      pr_ref="${pr_branch}"
    fi

    if ! TARGET_SHA="$(commit "${pr_ref}")"; then
      printf "::error ::Cannot resolve pull request #%s (%s) into a SHA reference.\n%s\n" \
        "${pr_number}" "${pr_ref}" "${TARGET_SHA}"
      exit 1
    fi

    TARGET_NAME="${pr_number}"
    TARGET_TYPE="pr"
  fi

  if [[ -z "${TARGET_SHA}" ]] && allowed branch; then
    if TARGET_SHA="$(ref "heads/${INPUT_REF}")"; then
      TARGET_NAME="${INPUT_REF}"
      TARGET_TYPE="branch"
    fi
  fi

  if [[ -z "${TARGET_SHA}" ]] && allowed tag; then
    if TARGET_SHA="$(ref "tags/${INPUT_REF}")"; then
      TARGET_NAME="${INPUT_REF}"
      TARGET_TYPE="tag"
    fi
  fi

  if [[ -z "${TARGET_SHA}" ]] && allowed commit; then
    if TARGET_SHA="$(commit "${INPUT_REF}")"; then
      TARGET_NAME="${INPUT_REF}"
      TARGET_TYPE="commit"
    fi
  fi

  if [[ -z "${TARGET_SHA}" ]]; then
    echo "::error ::Cannot resolve input ref ${INPUT_REF} to an allowed input (${ALLOWED//,/ })."
    exit 1
  fi
fi

if [[ ${TRACE:-} == 1 ]]; then
  set +x
  echo "sha=${TARGET_SHA}"
  echo "name=${TARGET_NAME}"
  echo "type=${TARGET_TYPE}"
fi

{
  echo "sha=${TARGET_SHA}"
  echo "name=${TARGET_NAME}"
  echo "type=${TARGET_TYPE}"
} >>"${GITHUB_OUTPUT:-/dev/stdout}"
