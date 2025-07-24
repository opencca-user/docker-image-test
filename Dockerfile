# Dockerfile
FROM debian:bookworm-slim

ARG VERSION
LABEL org.opencontainers.image.title="opencca-docker-demo"
LABEL org.opencontainers.image.description="Description"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.authors="Opencca"
LABEL org.opencontainers.image.source="https://github.com/my-org/my-builder"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.created="${BUILD_DATE}"

RUN apt-get update && apt-get install -y build-essential curl git

CMD ["bash"]