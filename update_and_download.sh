#!/bin/bash

# Exit on error
set -e

# Tracking files for downloads
MODEL_TRACKING=".downloaded_models"
DATASET_TRACKING=".downloaded_datasets"

touch "$MODEL_TRACKING" "$DATASET_TRACKING"

echo "Pulling latest updates from git..."
git pull origin main

# Process models
if [ -f "models.txt" ]; then
    echo "Checking for model updates..."
    while IFS= read -r model || [ -n "$model" ]; do
        [[ -z "$model" || "$model" =~ ^# ]] && continue
        if grep -qx "$model" "$MODEL_TRACKING"; then
            echo "Model $model already downloaded. Skipping."
        else
            echo "Triggering download for model: $model..."
            if ./download_hf_model.sh "$model"; then
                echo "$model" >> "$MODEL_TRACKING"
            else
                echo "Failed to download model $model"
            fi
        fi
    done < "models.txt"
fi

# Process datasets
if [ -f "datasets.txt" ]; then
    echo "Checking for dataset updates..."
    while IFS= read -r dataset || [ -n "$dataset" ]; do
        [[ -z "$dataset" || "$dataset" =~ ^# ]] && continue
        if grep -qx "$dataset" "$DATASET_TRACKING"; then
            echo "Dataset $dataset already downloaded. Skipping."
        else
            echo "Triggering download for dataset: $dataset..."
            if ./download_hf_dataset.sh "$dataset"; then
                echo "$dataset" >> "$DATASET_TRACKING"
            else
                echo "Failed to download dataset $dataset"
            fi
        fi
    done < "datasets.txt"
fi

echo "Update and download process completed."
