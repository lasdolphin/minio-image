# Stable Promotion Contract Test

Run the workflow twice using `workflow_dispatch`.

1. With a latest release tag absent from GHCR, require a successful candidate
   verification, then confirm both that exact release tag and `stable` resolve
   to the same digest.
2. Force the verification step to fail in a non-production branch run. Confirm
   that the release tag is absent and the pre-existing `stable` digest is
   unchanged.
3. Run again after the exact release tag exists. Confirm the `release-check`
   job reports `no-update` and the build/publish job is skipped.
