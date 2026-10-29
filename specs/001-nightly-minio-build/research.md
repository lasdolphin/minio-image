# Research: Nightly MinIO Image Build

## Build exact stable source releases

**Decision**: Build the selected MinIO release from its exact source revision.

**Rationale**: MinIO Community is source-only, documents source/container
builds, and requires Go 1.24 or newer. Record the selected tag and source
revision in metadata and build evidence.

**Alternatives considered**: `bitnamilegacy/minio` is not updated; upstream
prebuilt Community images are no longer maintained; default-branch builds do
not satisfy the stable-release requirement.

## Detect release changes without rebuilding unchanged releases

**Decision**: Query GitHub's latest published full release each night. If that
exact tag is already public under `ghcr.io/lasdolphin/minio-image`, exit as
`no-update`; otherwise build it.

**Rationale**: GitHub defines latest release as published, non-draft and
non-prerelease. Exact tag existence avoids invalid lexical comparison of
MinIO's timestamp-shaped release names and permits retries after failures.

**Alternatives considered**: Daily rebuilding violates the clarification;
default-branch lookup is not a stable release; string sorting is unreliable.

## Publish release-version and stable tags after checks

**Decision**: Publish the exact upstream release tag after verification; then
promote `stable`. Record the OCI digest as evidence, not as the primary public
reference.

**Rationale**: The owner chose source release version as the public contract.
Release tags are never overwritten; `stable` moves only after success.

**Alternatives considered**: Digest-only tagging conflicts with the required
public contract; promotion before tests risks exposing a bad build.

## Use GitHub Actions token for GHCR

**Decision**: Give the workflow `contents: read` and `packages: write` and use
the built-in workflow token to publish the public package.

**Rationale**: GitHub documents this least-privilege package publishing path;
it avoids a long-lived personal registry credential.

**Alternatives considered**: Personal access token adds credential lifecycle
and broader exposure; private packaging conflicts with the requested public
image.

## Verify certificate trust behavior before promotion

**Decision**: Require startup success and certificate-validation rejection for
all four eMudhra endpoints before publishing/promoting the candidate.

**Rationale**: Base-image or toolchain version is not behavioral proof. Save
per-host results in the workflow log.

**Alternatives considered**: Testing a single endpoint or relying only on a
base image version cannot establish closure.

## Sources

- [MinIO Community source-only README](https://github.com/minio/minio)
- [GitHub Releases API](https://docs.github.com/en/rest/releases/releases)
- [GitHub Packages publishing guidance](https://docs.github.com/en/packages/managing-github-packages-using-github-actions-workflows/publishing-and-installing-a-package-with-github-actions)
