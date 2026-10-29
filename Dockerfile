ARG GO_VERSION=1.24
FROM golang:${GO_VERSION}-bookworm AS build

ARG MINIO_RELEASE
ARG MINIO_COMMIT

RUN test -n "$MINIO_RELEASE" && test -n "$MINIO_COMMIT"
WORKDIR /src
RUN git clone --filter=blob:none https://github.com/minio/minio.git . \
 && git checkout --detach "$MINIO_RELEASE" \
 && test "$(git rev-parse HEAD)" = "$MINIO_COMMIT"
RUN CGO_ENABLED=0 go build -trimpath -o /out/minio ./

FROM debian:trixie-slim
ARG MINIO_RELEASE
ARG MINIO_COMMIT
ARG BUILD_DATE
LABEL org.opencontainers.image.title="MinIO Community source build" \
      org.opencontainers.image.source="https://github.com/minio/minio" \
      org.opencontainers.image.version="${MINIO_RELEASE}" \
      org.opencontainers.image.revision="${MINIO_COMMIT}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.licenses="AGPL-3.0-or-later"
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/*
COPY --from=build /out/minio /usr/local/bin/minio
COPY --from=build /src/LICENSE /licenses/MINIO-AGPL-3.0.txt
EXPOSE 9000 9001
VOLUME ["/data"]
ENTRYPOINT ["/usr/local/bin/minio"]
CMD ["server", "/data", "--console-address", ":9001"]
