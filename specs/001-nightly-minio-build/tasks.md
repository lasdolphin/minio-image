# Tasks: Nightly MinIO Image Build

**Input**: Design documents from `specs/001-nightly-minio-build/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [publication contract](contracts/publish-contract.md)

**Tests**: Workflow and container verification are explicitly required by the feature specification.

**Organization**: Tasks are grouped by user story so each story can be built and validated independently.

## Phase 1: Setup

**Purpose**: Establish the repository layout and public licensing baseline.

- [X] T001 Create CI, script, and license directories in `.github/workflows/`, `scripts/`, and `LICENSES/`
- [X] T002 [P] Add AGPLv3 license and MinIO upstream attribution in `LICENSES/AGPL-3.0.txt` and `LICENSES/UPSTREAM.md`
- [X] T003 [P] Expand project purpose, public package location, and production boundary in `README.md`

---

## Phase 2: Foundational

**Purpose**: Implement shared source, image, and verification primitives required by every story.

**⚠️ CRITICAL**: Complete this phase before user-story workflow wiring.

- [X] T004 Create a reproducible source-build Dockerfile accepting exact release tag and source revision in `Dockerfile`
- [X] T005 [P] Implement a stable-release discovery helper that returns only published, non-draft, non-prerelease releases in `scripts/discover-release.sh`
- [X] T006 [P] Implement a GHCR release-tag existence helper in `scripts/release-exists.sh`
- [X] T007 [P] Implement a runtime startup check in `scripts/verify-candidate.sh`
- [X] T008 Build candidate verification orchestration in `scripts/verify-candidate.sh`

**Checkpoint**: Source discovery, candidate image building, and behavioral verification are available to the workflow.

---

## Phase 3: User Story 1 - Obtain a current verified image (Priority: P1) 🎯 MVP

**Goal**: Run nightly checks and build/publish only an absent latest stable MinIO release.

**Independent Test**: A manual workflow run with an existing release tag returns `no-update` with no build/push; a run for an absent stable release builds and starts it.

- [X] T009 [P] [US1] Add shell tests for stable/non-prerelease selection and malformed release data in `tests/discover-release.test.sh`
- [X] T010 [P] [US1] Add startup verification coverage in `scripts/verify-candidate.sh`
- [X] T011 [US1] Implement nightly and manual triggers plus least-privilege read permissions in `.github/workflows/nightly-build.yml`
- [X] T012 [US1] Wire release discovery and exact release-tag no-update exit into `.github/workflows/nightly-build.yml`
- [X] T013 [US1] Wire exact source checkout, candidate build, startup smoke check, and `scripts/verify-candidate.sh` into `.github/workflows/nightly-build.yml`
- [X] T014 [US1] Publish only a verified absent release-version tag and emit source revision plus OCI digest in `.github/workflows/nightly-build.yml`

**Checkpoint**: The MVP creates a verified public image only for a newly available stable upstream release.

---

## Phase 4: User Story 2 - Select a safe deployment candidate (Priority: P2)

**Goal**: Promote `stable` only after the matching release-version candidate passes verification.

**Independent Test**: A passing release run updates `stable`; a forced verification failure leaves the prior `stable` reference unchanged.

- [X] T015 [P] [US2] Add stable-promotion and no-mutation-on-failure workflow assertions in `tests/workflow/promotion-contract.md`
- [X] T016 [US2] Add post-verification `stable` promotion and digest comparison in `.github/workflows/nightly-build.yml`
- [X] T017 [US2] Add failure-path guards that prevent release and `stable` publication after any failed verification in `.github/workflows/nightly-build.yml`

**Checkpoint**: `stable` can only identify a candidate that passed the same behavioral checks as its release-version tag.

---

## Phase 5: User Story 3 - Audit source and licensing (Priority: P3)

**Goal**: Give public users enough information to identify source, build evidence, and license obligations.

**Independent Test**: A user can inspect a published image and repository documentation to find its upstream tag, source revision, build date, license, and build workflow evidence.

- [X] T018 [P] [US3] Add OCI source, revision, created-date, license, and version labels to `Dockerfile`
- [X] T019 [P] [US3] Document image tag contract, source retrieval, and AGPLv3 corresponding-source path in `README.md`
- [X] T020 [US3] Add workflow build summary containing release tag, source revision, digest, and verification result in `.github/workflows/nightly-build.yml`

**Checkpoint**: Every public candidate has discoverable provenance and licensing evidence.

---

## Phase 6: Polish & Cross-Cutting Validation

**Purpose**: Verify the end-to-end contract and prevent accidental cluster deployment.

- [X] T021 [P] Confirm README commands and expected outcomes against `specs/001-nightly-minio-build/quickstart.md`
- [X] T022 [P] Add repository guidance excluding cluster credentials and production deployment logic in `README.md`
- [X] T023 Run a manual no-update workflow and a controlled new-release workflow; record outcomes in `specs/001-nightly-minio-build/quickstart.md`
- [X] T024 Verify the published package is public, uses exact upstream release-version tags, and has no overwritten release tag in `README.md`

## Dependencies & Execution Order

- Setup (T001–T003) has no dependencies.
- Foundational work (T004–T008) depends on T001; T008 depends on T007.
- US1 (T009–T014) depends on Phase 2; T011–T014 execute in order after the helpers and tests.
- US2 (T015–T017) depends on successful US1 publication behavior.
- US3 (T018–T020) can begin after Phase 2, but T020 integrates with the workflow created by US1.
- Polish (T021–T024) depends on the desired user stories.

## Parallel Opportunities

- T002 and T003 may proceed in parallel after T001.
- T005, T006, and T007 may proceed in parallel after T001.
- T009 and T010 may proceed in parallel after the associated helper/probe design is established.
- T015, T018, and T019 may proceed in parallel after the MVP workflow exists.
- T021 and T022 may proceed in parallel in the final phase.

## Implementation Strategy

### MVP First

1. Complete T001–T008.
2. Complete T009–T014.
3. Run the US1 independent test: one `no-update` result and one verified release image.
4. Stop before `stable` promotion if operator review is required.

### Incremental Delivery

1. Deliver US1 for safe release-version images.
2. Add US2 to expose only verified candidates as `stable`.
3. Add US3 provenance and licensing information.
4. Complete cross-cutting validation without changing the production cluster.

## Format Validation

Every task follows `- [ ] T### [P?] [US#?] Description with file path`.
