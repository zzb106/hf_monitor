# HF Monitor

This repository provides automation scripts to monitor and download models and datasets from Hugging Face.

## Files

- `models.txt`: List of Hugging Face model repositories to download.
- `datasets.txt`: List of Hugging Face dataset repositories to download.
- `update_and_download.sh`: Main entry point. Pulls latest git updates and triggers the download scripts for any new entries in the `.txt` files.
- `download_hf_model.sh`: Script to download a specific model.
- `download_hf_dataset.sh`: Script to download a specific dataset.

## Usage

To update the repository and download any new models or datasets:

```bash
chmod +x *.sh
./update_and_download.sh
```

## Tracking

The system uses local tracking files (`.downloaded_models` and `.downloaded_datasets`) to ensure that repositories are not redownloaded once successfully acquired. These tracking files are not committed to the repository.
