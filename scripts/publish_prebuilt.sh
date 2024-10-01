#!/usr/bin/env bash
set -euo pipefail

#
# Run this in opencca-build container
#
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# Get environment from makefile
BUILDCONF_DIR=$SCRIPT_DIR/../buildconf/
ENV_FILE=$BUILDCONF_DIR/env.mk

eval "$(make -f $ENV_FILE print-vars | sed 's/^/export /')" &>/dev/null || true
env

BUILD_DIR="$SCRIPT_DIR/build-publish/build-$(date +%Y-%m-%d_%H-%M-%S)"
LOG_DIR=$SCRIPT_DIR/build-publish/
LOG_FILE=$LOG_DIR/$0.log

mkdir -p $BUILD_DIR $LOG_DIR

# Colors
COLOR="\e[35m"
RESET="\e[0m"

function log() { echo -e "${COLOR}$1${RESET}"; }

exec &> >(tee -a "$LOG_FILE")
log "$0: $(date +%Y-%m-%d_%H-%M-%S):"


function release_kernel {
    LOCALVERSION=-opencca-wip
    SNAPSHOT_DIR=$BUILD_DIR/linux
    DEBIAN_RELEASE_DIR=$SNAPSHOT_DIR/linux-debian-release

    RUN_ARGS="SNAPSHOT_DIR=$SNAPSHOT_DIR LOCALVERSION=$LOCALVERSION DEBIAN_RELEASE_DIR=$DEBIAN_RELEASE_DIR"

    log "RUN_ARGS: $RUN_ARGS"

    mkdir -p $SNAPSHOT_DIR $DEBIAN_RELEASE_DIR
    cd $BUILDCONF_DIR

    ./linux.mk clean $RUN_ARGS && \
    ./linux.mk help $RUN_ARGS && \
    ./linux.mk debian $RUN_ARGS || { echo "Fail during build"; exit 1; }

    
    ls -al $DEBIAN_RELEASE_DIR

    create_archive $DEBIAN_RELEASE_DIR linux $SNAPSHOT_DIR/..
}

function create_archive {
    local source_dir=$1
    local name=$2 # no suffix
    local target_dir=$3
    local comment=${4:-""}

    local timestamp=$(date +%Y%m%d-%H%M%S)
    local release_file=$source_dir/release.txt
    local release_name=${name}-${timestamp}.tar.gz
    local target_path=$target_dir/$release_name

    mkdir -p $target_dir

    touch $release_file
    echo "timestamp: $timestamp" >> $release_file
    echo "name: $name" >> $release_file

    tar -czf "$target_path" -C "$source_dir" .
    echo "$release_name" > $target_dir/latest
}

function release_firmware {
    SNAPSHOT_DIR=$BUILD_DIR/uboot
    RUN_ARGS="SNAPSHOT_DIR=$SNAPSHOT_DIR"
    log "RUN_ARGS: $RUN_ARGS"

    mkdir -p $SNAPSHOT_DIR
    cd $BUILDCONF_DIR

    ./firmware_opencca.mk clean $RUN_ARGS && \
    ./firmware_opencca.mk help $RUN_ARGS && \
    ./firmware_opencca.mk build $RUN_ARGS 

    ls -al $SNAPSHOT_DIR

    create_archive $SNAPSHOT_DIR uboot $SNAPSHOT_DIR/..
}

function release_kvmtool {
    SNAPSHOT_DIR=$BUILD_DIR/kvmtool
    RUN_ARGS="SNAPSHOT_DIR=$SNAPSHOT_DIR"
    log "RUN_ARGS: $RUN_ARGS"

    mkdir -p $SNAPSHOT_DIR
    cd $BUILDCONF_DIR

    ./kvmtool.mk clean && \
    ./kvmtool.mk build 

    create_archive $SNAPSHOT_DIR kvmtool $SNAPSHOT_DIR/..
}

function upload {
    local tar_file=$1
    local git_repo

}


#
# Main
# 
set -x
set +u
echo "Executing command: $1 ..."

case "$1" in
    kernel) release_kernel ;;
    firmware) release_firmware ;;
    kvmtool) release_kvmtool ;;
    upload) upload ;;
    *) exit ;;
esac







