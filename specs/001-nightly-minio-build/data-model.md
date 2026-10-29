# Data Model: Nightly MinIO Image Build

## UpstreamRelease

| Field | Validation |
|---|---|
| release_tag | Published, non-draft, non-prerelease, non-empty |
| source_revision | Full immutable commit identifier |
| discovered_at | UTC timestamp |

## BuildRecord

| Field | Validation |
|---|---|
| run_id | Unique workflow execution identifier |
| release_tag | Matches selected UpstreamRelease |
| outcome | `no-update`, `published`, or `failed` |
| image_digest | Required only when outcome is `published` |
| verification | Required and passing for `published` |

## PublishedCandidate

| Field | Validation |
|---|---|
| release_tag | Exact upstream tag; never overwritten |
| stable_reference | Changes only after a published result |
| image_digest | Audit evidence for the release tag |
| source_revision | Matches UpstreamRelease |

## State Transitions

`discovered` → `no-update` when the selected release tag exists.

`discovered` → `building` → `verifying` → `published` when all checks pass.

Any state → `failed` on error; existing release tags and `stable` remain unchanged.
