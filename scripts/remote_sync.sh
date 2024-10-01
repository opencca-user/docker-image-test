#!/bin/bash
set -euo pipefail

# .sync-ignore format: .gitignore format
# run:
#  HOST=opencca@192.33.93.199 HOST_TARGET=/home/opencca/opencca/snapshot \
# ./snapshot_sync.sh 

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
SNAPSHOT_DIR=$SCRIPT_DIR/../../snapshot

SYNC_DIR=${SYNC_DIR:-$SNAPSHOT_DIR}
HOST=${HOST:-not-set}
HOST_TARGET=${HOST_TARGET:-/home/opencca/opencca/opencca-flashserver/flash/snapshot}

echo "SYNC_DIR: $SYNC_DIR"
echo "HOST: $HOST"
echo "HOST_TARGET: $HOST_TARGET"

IGNORE_FILE=$SYNC_DIR/.sync-ignore
echo "IGNORE_FILE: $IGNORE_FILE"

CMD="rsync -v --exclude-from=$IGNORE_FILE -a $SYNC_DIR/ $HOST:$HOST_TARGET/"

echo -e "\n\nCMD=$CMD\n\n"
echo "Press any key to start"
read

function sync {
   set -x
   $CMD 
   set +x
}

touch $IGNORE_FILE
cd $SYNC_DIR

sync
while true; do
    sync
    sleep 1
done
