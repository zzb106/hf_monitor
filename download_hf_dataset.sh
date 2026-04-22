#!/bin/bash

REPO=$1
TARGET="/raid/datasets/${REPO##*/}"
LOCKFILE="$TARGET/.download.lock"
MAX_WORKERS=8
export HF_HUB_DOWNLOAD_TIMEOUT=120

mkdir -p $TARGET

# Prevent multiple instances for the same dataset
exec 200>"$LOCKFILE"
if ! flock -n 200; then
    echo "Another download instance for $REPO is already running. Skipping."
    exit 0
fi

download () {
    find $TARGET/.cache/ -name "*.incomplete" -type f -delete;
    hf download --repo-type dataset $REPO --local-dir $TARGET --cache-dir $TARGET/.cache/ --max-workers $MAX_WORKERS;
}

until download; do
    echo "Sleep 5min to next retry"
    sleep 300
done
