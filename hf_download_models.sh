#!/bin/bash

# This script handles the actual model download logic.
# It reads models.txt and checks against a local tracking file.

MODELS_FILE="models.txt"
TRACKING_FILE=".downloaded_models"

# Create tracking file if it doesn't exist
touch "$TRACKING_FILE"

if [ ! -f "$MODELS_FILE" ]; then
    echo "Error: $MODELS_FILE not found."
    exit 1
fi

while IFS= read -r model || [ -n "$model" ]; do
    # Skip empty lines or comments
    [[ -z "$model" || "$model" =~ ^# ]] && continue

    if grep -qx "$model" "$TRACKING_FILE"; then
        echo "Model $model already downloaded. Skipping."
    else
        echo "Downloading model: $model..."
        # Replace the following line with your actual download command
        # Example: huggingface-cli download "$model"
        # For now, we simulate a successful download:
        true

        if [ $? -eq 0 ]; then
            echo "$model" >> "$TRACKING_FILE"
            echo "Successfully downloaded $model."
        else
            echo "Failed to download $model."
        fi
    fi
done < "$MODELS_FILE"
