# Quickstart: Validate the Nightly MinIO Image Build

## Prerequisites

- GitHub Actions enabled for this repository.
- Permission to publish public packages under `lasdolphin`.
- A published stable MinIO release.

## No-update validation

1. Manually run the workflow after the latest release tag exists in GHCR.
2. Confirm outcome `no-update`.
3. Confirm no source build, image publication, or `stable` change occurred.

**Recorded 2026-10-29:** [run 40954434656](https://github.com/lasdolphin/minio-image/actions/runs/40954434656)
completed successfully. It selected `RELEASE.2025-10-15T17-29-55Z`, reported
`No build required`, and skipped `build-verify-publish`.

## New-release validation

1. Run the workflow for a stable release tag absent from GHCR.
2. Confirm source evidence identifies its tag and full commit.
3. Confirm GHCR exposes the matching release-version tag and recorded digest.
4. Confirm startup and all four certificate-validation checks pass.
5. Confirm `stable` resolves to the verified image.

**Recorded 2026-10-29:** [run 40953793300](https://github.com/lasdolphin/minio-image/actions/runs/40953793300)
built MinIO at `9e49d5e7a648f00e26f2246f4dc28e6b07f8c84a`, completed the
startup and four-chain certificate-rejection checks, then published
`RELEASE.2025-10-15T17-29-55Z` and `stable` at
`sha256:43f9e2559942792b73345974b86197b2f46a2755a5250773ebf792d529e5e281`.
That run ended non-zero only while rendering its post-publication digest
summary; the command was corrected in commit `de49fdd` and independently
verified against the published image. An anonymous registry pull-token check
returned HTTP 200 for the release manifest, confirming public access.

## Failure validation

1. Force a non-production verification failure.
2. Confirm outcome `failed`.
3. Confirm no release tag and no `stable` update occurred.

## Production boundary

This workflow never changes the cluster. A separate reviewed GitOps change must
select a published version and validate the persistent-data rollout.
