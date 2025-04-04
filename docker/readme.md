# OpenCCA Build Environment

This repository contains the Docker configuration for the OpenCCA build environment.

The Dockerfile allow you to build and run a Docker container equipped with all necessary tools
for building OpenCCA.

## Makefile Goals

The Makefile includes various targets to simplify the build and run process:

- **pull**: Pull a prebuilt image.
- **start**: Start the interactive development container.
- **enter**: Enter the running container.
- **run CMD='...'**: Run a command inside the container.
- **stop**: Stop the container.
- **build**: Build the Docker image locally.
- **clean**: Remove the container and unused images.

## Getting Started

To pull a pre-built the Docker image:
```sh
make pull
```

To start the interactive development container:
```sh
make start
```

To enter the running container:
```sh
make enter
```
The docker container mounts the parent directory of this repository
to `/opencca/`.

For more details on usage, refer to the comments in the Makefile.
```sh
make help
```