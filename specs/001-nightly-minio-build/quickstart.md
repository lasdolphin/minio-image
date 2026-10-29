# Quickstart: Validate the Nightly MinIO Image Build

## Prerequisites

- GitHub Actions enabled for this repository.
- Permission to publish public packages under `lasdolphin`.
- A published stable MinIO release.

## No-update validation

1. Manually run the workflow after the latest release tag exists in GHCR.
2. Confirm outcome `no-update`.
3. Confirm no source build, image publication, or `stable` change occurred.

## New-release validation

1. Run the workflow for a stable release tag absent from GHCR.
2. Confirm source evidence identifies its tag and full commit.
3. Confirm GHCR exposes the matching release-version tag and recorded digest.
4. Confirm startup and all four certificate-validation checks pass.
5. Confirm `stable` resolves to the verified image.

## Failure validation

1. Force a non-production verification failure.
2. Confirm outcome `failed`.
3. Confirm no release tag and no `stable` update occurred.

## Production boundary

This workflow never changes the cluster. A separate reviewed GitOps change must
select a published version and validate the persistent-data rollout.
