# stage: toolchain
FROM debian:bookworm AS toolchain
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /build
RUN apt update && apt install -y curl wget tar build-essential
COPY buildconf/download-arm-toolchain.sh /build/
RUN /build/download-arm-toolchain.sh linux && \
    /build/download-arm-toolchain.sh none

# stage: build container
FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV IN_CONTAINER=1
ENV HOME=/root

RUN apt update -y 
RUN apt install -y build-essential autoconf automake libtool ccache device-tree-compiler
RUN apt install -y emacs-nox nano vim sudo curl wget git \
    unzip htop tmux screen bash-completion lsof fish tmux bash \
    iproute2 net-tools dnsutils iputils-ping traceroute socat tcpdump nmap \
    build-essential cmake pkg-config gdb gdb-multiarch strace  \
    python3 python3-pip python3-venv python3-dev
RUN apt install -y usbutils udev libusb-1.0-0-dev coreutils expect

RUN ln -s /usr/bin/python3 /usr/bin/python || true

# build uboot
RUN apt-get install -y bc bison build-essential coccinelle \
  device-tree-compiler dfu-util efitools flex gdisk graphviz imagemagick \
  liblz4-tool libgnutls28-dev libguestfs-tools libncurses-dev \
  libpython3-dev libsdl2-dev libssl-dev lz4 lzma lzma-alone openssl \
  pkg-config python3 python3-asteval python3-coverage python3-filelock \
  python3-pkg-resources python3-pycryptodome python3-pyelftools \
  python3-pytest python3-pytest-xdist python3-sphinxcontrib.apidoc \
  python3-sphinx-rtd-theme python3-subunit python3-testtools \
  python3-virtualenv swig uuid-dev

# Install Toolchain
COPY --from=toolchain /build/ /build/
ENV PATH="/build/aarch64-none-elf/bin:/build/aarch64-none-linux-gnu/bin:$PATH"

# Ccache
ENV CCACHE_DIR="/build/.ccache"
RUN ccache --max-size=10G

# Install Debos
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libostree-1-1 \
    ca-certificates \
    systemd-container \
    binfmt-support \
    parted \
    dosfstools \
    e2fsprogs \
    bmap-tools \
    qemu-system-x86 \
    qemu-user-static \
    busybox \
    linux-image-amd64 \
    systemd \
    dbus \
    systemd systemd-resolved \
    mmdebstrap
    
RUN apt install -y golang git libglib2.0-dev libostree-dev qemu-system-x86 \
    qemu-user-static debootstrap systemd-container 

ENV GOPATH=/build/gocode
RUN go install -v github.com/go-debos/debos/cmd/debos@latest
RUN /build/gocode/bin/debos --help

ENV PATH="/build/gocode/bin:$PATH"

RUN  git config --global --add safe.directory "*"

CMD ["/bin/bash"]