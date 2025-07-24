# Dockerfile
FROM debian:bookworm-slim

ARG BUILD_DATE=none
ARG BUILD_REF=unknown
ARG BUILD_VERSION=none

# Labels
LABEL org.opencontainers.image.title="opencca-docker-demo"
LABEL org.opencontainers.image.description="Build Environment to build OpenCCA."
LABEL org.opencontainers.image.vendor="OpenCCA"
LABEL org.opencontainers.image.authors="Andrin Bertschi <hi@abertschi.ch>"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.url="https://opencca.github.io"
LABEL org.opencontainers.image.source="https://github.com/test"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${BUILD_REF}"
LABEL org.opencontainers.image.version="${BUILD_VERSION}"



CMD ["bash"]