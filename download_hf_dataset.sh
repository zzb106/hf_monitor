#!/bin/bash

REPO=$1
TARGET="/raid/datasets/${REPO##*/}"
MAX_WORKERS=8
export HF_HUB_DOWNLOAD_TIMEOUT=120

mkdir -p $TARGET

download () {
    find $TARGET/.cache/ -name "*.incomplete" -type f -delete;
    hf download --repo-type dataset $REPO --local-dir $TARGET --cache-dir $TARGET/.cache/ --local-dir-use-symlinks False --max-workers $MAX_WORKERS;
}

until download; do
    echo "Sleep 5min to next retry"
    sleep 300
done
