REPO=$1
TARGET="/raid/models/${REPO##*/}"
MAX_WORKERS=8
export HF_HUB_DOWNLOAD_TIMEOUT=120

mkdir -p $TARGET

download () { 
	find $TARGET/.cache/ -name "*.incomplete" -type f -delete;
	hf download --repo-type model $REPO --local-dir $TARGET  --cache-dir $TARGET/.cache/ --max-workers $MAX_WORKERS; }


#huggingface-cli download --repo-type $REPO --local-dir $TARGET  --cache-dir $TARGET/.cache/ --local-dir-use-symlinks False

#download

until download; do
    # Sleep to prevent DDOS
    echo Sleep 5min to next retry
    sleep 300
done

#CODE=$?
#echo "Exit Code: $CODE"
