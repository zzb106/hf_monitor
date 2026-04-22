#!/bin/bash

# Exit on error
set -e

echo "Pulling latest updates from git..."
git pull origin main

echo "Triggering model downloads..."
./hf_download_models.sh

echo "Update and download process completed."
