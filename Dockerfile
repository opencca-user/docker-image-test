# Dockerfile
FROM debian:bookworm-slim

ARG BUILD_DATE=none
ARG BUILD_REF=unknown
ARG BUILD_VERSION=none

# Labels
LABEL \
    org.opencontainers.image.title="opencca-docker-demo" \
    org.opencontainers.image.description="Build Environment to build OpenCCA." \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Andrin Bertschi <hi@abertschi.ch>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://opencca.github.io" \
    org.opencontainers.image.source="https://github.com/test" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}



CMD ["bash"]