# Publication Contract

## Inputs

| Input | Required behavior |
|---|---|
| Latest upstream release | Must be published, non-draft, and non-prerelease |
| Existing GHCR release tag | Determines whether a build is required |
| Source revision | Must match the release target commit |

## Outputs

| Outcome | Public effect |
|---|---|
| `no-update` | No source checkout, build, image push, or tag mutation |
| `published` | Creates `ghcr.io/lasdolphin/minio-image:<upstream-release-tag>` and updates `stable` |
| `failed` | Creates no release tag and leaves `stable` unchanged |

## Verification Gate

Before publication and promotion, the candidate must pass a server startup
smoke check and reject `dv-g3b`, `dv-g3b-aaa`, `dv-g3b-noct`, and
`dv-g3b-aaa-noct` on certificate validation.
