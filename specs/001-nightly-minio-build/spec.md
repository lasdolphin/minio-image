# Feature Specification: Nightly MinIO Image Build

**Feature Branch**: `main`
**Created**: 2026-10-29
**Status**: Draft
**Input**: User description: "create a nightly build of stable release of minio source and publish as oci image under lasdolphin/minio-image, build using github actions"

## Clarifications

### Session 2026-10-29

- Q: Should the scheduled workflow rebuild an unchanged upstream release? → A: Run nightly, but build and publish only when a newer stable release is available.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Obtain a current verified image (Priority: P1)

As the platform owner, I need the newest stable MinIO Community source release built when it becomes available, so that the cluster has a maintained, traceable replacement for the unmaintained legacy image.

**Why this priority**: This delivers the security-maintenance path needed for the production object store.

**Independent Test**: Trigger a build against a known stable release and verify that a public image exists with the matching release-version tag and recorded source revision.

**Acceptance Scenarios**:

1. **Given** a newer stable upstream release is available, **When** the nightly build runs, **Then** it publishes an OCI image with the exact same release-version tag.
2. **Given** the newest stable upstream release has not changed, **When** the nightly workflow runs, **Then** it records that no build is needed and does not retrieve source, build, publish, or replace the existing release-version image.
3. **Given** source retrieval, build, or verification fails, **When** the nightly build completes, **Then** it reports failure and does not publish or promote the failed candidate.

---

### User Story 2 - Select a safe deployment candidate (Priority: P2)

As the platform owner, I need a stable-candidate reference that only points to a successfully verified release image, so deployment changes can be reviewed against a known upstream version.

**Why this priority**: A convenient candidate reference supports operations while the matching release version makes provenance clear.

**Independent Test**: Complete one successful build and verify that the stable-candidate reference resolves to the release-version image created by that build.

**Acceptance Scenarios**:

1. **Given** a nightly build passes all required checks, **When** it is published, **Then** the stable-candidate reference resolves to that release-version image.
2. **Given** a nightly build fails a required check, **When** publication is evaluated, **Then** the existing stable-candidate reference remains unchanged.

---

### User Story 3 - Audit source and licensing (Priority: P3)

As the public image maintainer, I need every published build to identify its upstream source and license obligations, so downstream users can audit and obtain the corresponding source.

**Why this priority**: The image is publicly distributed and derived from AGPL-licensed source.

**Independent Test**: Inspect a published image and repository metadata to locate the upstream release, source revision, build date, and license notice.

**Acceptance Scenarios**:

1. **Given** a published image, **When** a user inspects its metadata, **Then** they can identify the upstream release, exact source revision, and build date.
2. **Given** a published image, **When** a user consults the repository, **Then** they can find the applicable license and a path to the corresponding source.

### Edge Cases

- The upstream release feed is unavailable, malformed, or contains only prereleases.
- A newly discovered stable release cannot be built or fails verification.
- Publication succeeds but updating the stable-candidate reference fails.
- A release tag is withdrawn or retargeted after discovery.
- The registry is unavailable or rejects publication.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The project MUST run a scheduled nightly release check without manual input and MUST allow an owner to start the same check on demand.
- **FR-002**: The release check MUST select the newest upstream MinIO Community release marked stable, excluding prereleases and release candidates.
- **FR-002a**: The project MUST retrieve source, build, verify, and publish an image only when the selected stable release is newer than the newest release-version image already published by this project.
- **FR-003**: The build MUST obtain source from the selected release and retain the exact release identifier and source revision as build evidence.
- **FR-004**: The build MUST publish the resulting OCI image publicly under `ghcr.io/lasdolphin/minio-image`.
- **FR-005**: Each successful build MUST use an image tag exactly matching the upstream MinIO release version; it MUST record the resulting content digest as build evidence, but MUST NOT substitute a digest for the release-version tag.
- **FR-006**: The stable-candidate reference MUST advance only after the associated build and verification checks succeed.
- **FR-007**: Each candidate image MUST pass a startup smoke check and reject all four eMudhra advisory certificate chains through certificate validation before it may become the stable candidate.
- **FR-008**: A failed discovery, build, publication, or verification MUST leave the current stable candidate unchanged and provide a diagnosable failure result.
- **FR-009**: Published image metadata and repository documentation MUST state the upstream release, source revision, build date, and AGPLv3 licensing obligations.
- **FR-010**: The feature MUST not automatically update the production MinIO deployment; production adoption remains a separately reviewed GitOps change.

### Key Entities *(include if feature involves data)*

- **Upstream release**: A stable MinIO Community source release, including its release identifier and immutable source revision.
- **Build record**: The dated result of one scheduled or manual execution, including outcome, source evidence, verification evidence, image references, and content digest.
- **Published candidate**: A successfully verified OCI image identified primarily by the matching upstream release-version tag.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 99% of scheduled nightly release checks over a 30-day period complete with a recorded success, no-update, or failure result within 30 minutes.
- **SC-002**: 100% of successfully published candidate images use a tag exactly matching their upstream release and expose source-release evidence.
- **SC-003**: 100% of stable-candidate promotions have a passing startup check and four recorded certificate-validation rejections for the eMudhra advisory endpoints.
- **SC-004**: 0 failed or unverified builds replace the previously available stable candidate.
- **SC-005**: An operator can identify the exact upstream source and build date for any published candidate in under five minutes using public repository and image metadata.

## Assumptions

- The public GitHub repository `lasdolphin/minio-image` and its GitHub Actions environment can publish public OCI packages under the same owner.
- “Stable” means the newest upstream non-prerelease release; release candidates and prereleases are excluded.
- A nightly check that finds no newer stable release is a successful no-update outcome and performs no image build or publication.
- Upstream MinIO Community source remains available under AGPLv3 and can be built in the automated environment.
- The repository will retain documentation and source references sufficient for public AGPLv3 compliance.
- A later, separately approved MinIO migration will select a published release-version image from this project; it is not part of this feature.
