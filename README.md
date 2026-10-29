# minio-image

Public, source-built MinIO Community OCI images.

The scheduled workflow checks upstream nightly. It builds and publishes only
when the newest published stable upstream release tag is absent from GHCR.
Published images are available as `ghcr.io/lasdolphin/minio-image:<release>`;
the tag exactly matches the upstream release. `stable` moves only after startup
and eMudhra certificate-validation checks pass.

## Use and verify

Trigger a check manually with:

```sh
gh workflow run nightly-build.yml --repo lasdolphin/minio-image
```

Inspect the public image and its digest with:

```sh
docker buildx imagetools inspect \
  ghcr.io/lasdolphin/minio-image:RELEASE.2025-10-15T17-29-55Z
```

Release-version tags are immutable publication records: the workflow never
rebuilds or overwrites a tag that is already in GHCR. Only `stable` is a moving
tag, and it is promoted by the same workflow only after the candidate starts
and rejects all four eMudhra test chains during certificate validation.

Each build summary records the upstream tag, exact source revision, build date,
and OCI digest. The image is derived unchanged from MinIO Community source;
see [LICENSES/UPSTREAM.md](LICENSES/UPSTREAM.md) for AGPLv3 source and license
information.

This repository does not contain cluster credentials, deployment manifests, or
automatic production rollout logic. Production adoption must be reviewed in a
separate GitOps change.

