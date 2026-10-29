# Implementation Plan: Nightly MinIO Image Build

**Branch**: `main` | **Date**: 2026-10-29 | **Spec**: [spec.md](spec.md)

## Summary

Run a GitHub Actions workflow nightly and on demand. It checks the latest
published non-prerelease MinIO release. If its exact release tag already exists
in GHCR, it exits successfully as `no-update`. Otherwise it builds that exact
source revision, verifies startup and eMudhra TLS rejection, then publishes the
release-version tag and promotes `stable`.

## Technical Context

**Language/Version**: GitHub Actions YAML, POSIX shell, Dockerfile; MinIO source requires Go 1.24+

**Primary Dependencies**: GitHub Releases REST API, Docker Buildx, GHCR, `github.com/minio/minio`

**Storage**: Git files and GHCR package metadata; no application database

**Testing**: Workflow-dispatch integration run; source build; container startup; four-endpoint certificate-validation probe

**Target Platform**: GitHub-hosted Linux runner; `linux/amd64` OCI image initially

**Project Type**: CI-managed OCI image factory

**Performance Goals**: No-update check completes within 5 minutes; required build within 30 minutes

**Constraints**: Build only an absent stable release tag; never overwrite a release-version tag; promote `stable` only after verification; preserve AGPLv3 attribution; never deploy production from this workflow

**Scale/Scope**: One source repository, one nightly workflow, one public GHCR package, one image per upstream release

## Constitution Check

The generated constitution is an unratified template and defines no enforceable
project-specific gates. This design independently requires source attribution,
release-version tags, verification before promotion, and a separate production
deployment approval.

**Pre-design gate**: PASS — specification and research contain no unresolved decisions.

**Post-design gate**: PASS — release discovery, build, verification, publication, and production adoption are separated.

## Project Structure

### Documentation

```text
specs/001-nightly-minio-build/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── contracts/publish-contract.md
```

### Source Code

```text
.github/workflows/nightly-build.yml
scripts/discover-release.sh
scripts/verify-candidate.sh
tests/tls-probe/
Dockerfile
LICENSES/
README.md
```

**Structure Decision**: A single CI image-factory repository. Scripts isolate
release discovery and verification; the workflow orchestrates them. No MinIO
data, application service, or GitOps manifests live here.

## Complexity Tracking

No constitution violations or additional architectural complexity require justification.
