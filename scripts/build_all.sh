#!/usr/bin/env bash
set -euo pipefail

#
# Wrapper that bulk builds all components
# See individual components in buildconf/* 
# for fine grained builds
#
# Run:
#   build_all.sh
#
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ENV_FILE=$SCRIPT_DIR/../buildconf/env.mk

# Get environment from makefile
eval "$(make -f $ENV_FILE print-vars | sed 's/^/export /')" &>/dev/null || true

# Colors
COLOR="\e[35m"
RESET="\e[0m"

# Paths
BUILDCONF_DIR=$OPENCCA_BUILD_DIR/buildconf
LOG_DIR="$SCRIPT_DIR/build_log"
LOG_FILE="$LOG_DIR/stdout.log"

build_order=(
    build_kvmtool
    build_linux
    build_firmware
    build_debos_rootfs_host
)

declare -A build_status
for key in "${build_order[@]}"; do
    build_status["$key"]="not executed"
done

trap 'echo "Error on line $LINENO with exit code $?" && exit 1' ERR SIGINT

function log() { echo -e "${COLOR}$1${RESET}"; }

# Build Functions:
function build_kvmtool {
    cd $BUILDCONF_DIR
    make -f kvmtool.mk build
}

function build_linux {
    cd $BUILDCONF_DIR
    make -f linux.mk kernel && \
    make -f linux.mk debian 
}

function build_firmware {
    cd $BUILDCONF_DIR
    make -f firmware_opencca.mk build
}

function build_debos_rootfs_host {
    cd $BUILDCONF_DIR
    make -f debos_rootfs_host.mk build
}

function run_builds() {
    for func in "${build_order[@]}"; do
        log "\nBuilding $func...\n"
        set -x
        $func 2>&1 | tee -a "$LOG_DIR/$func.log" \
            && build_status["$func"]="Success (see $func.log)" \
            || { build_status["$func"]="Failed (see $func.log)"; }

        set +x
    done
}

function print_status() {
    set +x

    log "\nBuild Summary:\n"
    for key in "${!build_status[@]}"; do
        msg=$(printf "  %-30s: %s\n" "$key" "${build_status[$key]}")
        log "$msg"
    done

    log "\nLog directory: $LOG_DIR"
    log "Full log: $LOG_FILE\n"    
    log "Snapshot directory $SNAPSHOT_DIR:\n"

    for entry in $(ls $SNAPSHOT_DIR); do
        msg=$(printf "  %s" "$entry")
        log "$msg"
    done 
    
}

# Main
mkdir -p $LOG_DIR
exec &> >(tee -a "$LOG_FILE")
log "Date: $(date +%Y-%m-%d_%H-%M-%S):"


time run_builds

print_status
