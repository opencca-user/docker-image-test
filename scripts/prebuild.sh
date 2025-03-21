#!/usr/bin/env bash
set -euo pipefail

#
# Download snapshot artifacts from REPO_URL
#
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ENV_FILE=$SCRIPT_DIR/../buildconf/env.mk

# Get environment from makefile
# SNAPSHOT_DIR:
eval "$(make -f $ENV_FILE print-vars | sed 's/^/export /')" &>/dev/null || true

REPO_URL=${REPO_URL:-"https://raw.githubusercontent.com/opencca/opencca-release/opencca/main/"}
DOWNLOAD_DIR=${DOWNLOAD_DIR:-$SNAPSHOT_DIR}

# usage: download_latest "prefix" "download-directory"
# download site has form $REPO_URL/$name/latest
function download_latest {
    local name=$1 # kvmtool, linux, uboot
    local download_dir=$2

    local url=$REPO_URL/$name/latest
    local tmpfile=$(mktemp)
    local download_file_name="unknown"

    # 1: read latest file to get download file name
    curl -sSL "$url" -o "$tmpfile"
    download_file_name=$(<"$tmpfile")

    # 2: Download file
    local download_url=$REPO_URL/$name/$download_file_name
    local download_path=${download_dir}/${download_file_name}
    curl -L "$download_url" -o "$download_path"

    # 3: Extract to download_dir
    echo "Extracting $download_path to $download_dir directory"
    tar -xzvf  "$download_path" -C "$download_dir" 
}

function download_firmware { download_latest "uboot" $DOWNLOAD_DIR ; }
function download_rootfs { download_latest "rootfs_debos" $DOWNLOAD_DIR ; }
function download_kvmtool { download_latest "kvmtool" $DOWNLOAD_DIR ; }
function download_kernel { download_latest "linux" $DOWNLOAD_DIR ; }

function download_all {
    download_firmware
    download_rootfs
    download_kvmtool
    download_kernel
}

function main {
    mkdir -p "$DOWNLOAD_DIR"

    echo "Select which artifact to download:"
    echo "  1) all"
    echo "  2) rootfs"
    echo "  3) firmware"
    echo "  4) kvmtool"
    echo "  5) kernel"
    read -rp "Enter your choice [all/rootfs/firmware/kvmtool/kernel]: " choice

    case "$choice" in
        all) download_all ;;
        rootfs) download_rootfs ;;
        firmware) download_firmware ;;
        kvmtool) download_kvmtool ;;
        *)
            echo "Invalid option: $choice"
            exit 1
            ;;
    esac
}

main

