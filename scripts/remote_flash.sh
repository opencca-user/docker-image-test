#!/bin/bash
set -euo pipefail

set -x 
HOST=${HOST:-opencca@192.33.93.160}
HOST_FLASH_HOME=${HOST_TARGET:-/home/opencca/opencca/opencca-flashserver/flash}

ssh $HOST "make -f $HOST_FLASH_HOME/Makefile flash mmc"
