#!/usr/bin/env bash
set -euo pipefail

gh_bin="${GH_BIN:-gh}"
release_json="$($gh_bin api repos/minio/minio/releases/latest)"

# GitHub's latest endpoint excludes prereleases; validate it and resolve the
# annotated or lightweight tag to its exact commit instead of trusting a branch
# name in target_commitish.
release_tag="$(printf '%s' "$release_json" | python3 -c '
import json, sys
r = json.load(sys.stdin)
if r.get("draft") or r.get("prerelease") or not r.get("tag_name"):
    raise SystemExit("latest release is not a published stable release")
print(r["tag_name"])
')"
source_revision="$(git ls-remote https://github.com/minio/minio.git "refs/tags/${release_tag}^{}" "refs/tags/${release_tag}" | awk 'NR == 1 { print $1 }')"
test -n "$source_revision" || { echo "unable to resolve release tag ${release_tag}" >&2; exit 1; }

printf 'release_tag=%s\nsource_revision=%s\n' "$release_tag" "$source_revision"
