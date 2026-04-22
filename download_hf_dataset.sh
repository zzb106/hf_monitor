#!/bin/bash

# Change directory to where the script is located
cd "$(dirname "$0")"

REPO=$1
TARGET="/raid/datasets/${REPO##*/}"
LOCKDIR="$TARGET/.download.lock"
MAX_WORKERS=8
export HF_HUB_DOWNLOAD_TIMEOUT=120

mkdir -p $TARGET

# Prevent multiple instances for the same dataset using an atomic directory creation
if ! mkdir "$LOCKDIR" 2>/dev/null; then
    echo "Another download instance for $REPO is already running. Skipping."
    exit 0
fi

# Ensure the lock directory is removed on exit (success, error, or interrupt)
trap 'rmdir "$LOCKDIR"' EXIT

download () {
    find $TARGET/.cache/ -name "*.incomplete" -type f -delete;
    hf download --repo-type dataset $REPO --local-dir $TARGET --cache-dir $TARGET/.cache/ --max-workers $MAX_WORKERS;
}

until download; do
    echo "Sleep 5min to next retry"
    sleep 300
done
