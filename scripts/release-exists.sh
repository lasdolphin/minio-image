#!/usr/bin/env bash
set -euo pipefail

image="${1:?image reference is required}"
release_tag="${2:?release tag is required}"
imagetools="${IMAGETOOLS_BIN:-docker buildx imagetools}"

if $imagetools inspect "${image}:${release_tag}" >/dev/null 2>&1; then
  printf 'exists=true\n'
else
  printf 'exists=false\n'
fi
