#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat >"$tmp/gh" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' '{"tag_name":"RELEASE.2025-10-15T17-29-55Z","draft":false,"prerelease":false}'
EOF
chmod +x "$tmp/gh"
cat >"$tmp/git" <<'EOF'
#!/usr/bin/env bash
printf '%s\t%s\n' '0123456789abcdef' 'refs/tags/RELEASE.2025-10-15T17-29-55Z^{}'
EOF
chmod +x "$tmp/git"

output="$(PATH="$tmp:$PATH" GH_BIN="$tmp/gh" "$root/scripts/discover-release.sh")"
grep -Fx 'release_tag=RELEASE.2025-10-15T17-29-55Z' <<<"$output"
grep -Fx 'source_revision=0123456789abcdef' <<<"$output"

cat >"$tmp/gh" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' '{"tag_name":"rc","target_commitish":"deadbeef","draft":false,"prerelease":true}'
EOF
chmod +x "$tmp/gh"
if PATH="$tmp:$PATH" GH_BIN="$tmp/gh" "$root/scripts/discover-release.sh"; then
  echo 'prerelease must be rejected' >&2
  exit 1
fi
