# minio-image

Public, source-built MinIO Community OCI images.

The scheduled workflow checks upstream nightly. It builds and publishes only
when the newest published stable upstream release tag is absent from GHCR.
Published images are available as `ghcr.io/lasdolphin/minio-image:<release>`;
the tag exactly matches the upstream release. `stable` moves only after startup
and eMudhra certificate-validation checks pass.

Each build summary records the upstream tag, exact source revision, build date,
and OCI digest. The image is derived unchanged from MinIO Community source;
see [LICENSES/UPSTREAM.md](LICENSES/UPSTREAM.md) for AGPLv3 source and license
information.

This repository does not contain cluster credentials, deployment manifests, or
automatic production rollout logic. Production adoption must be reviewed in a
separate GitOps change.

