#!/bin/bash

# ===== CONFIG =====
tars_directory="/home/on-prem-admin/podxs/tars"
logs_directory="/home/on-prem-admin/podxs/logs"
date_time=$(date '+%Y-%m-%d_%H-%M-%S')
log_file="${logs_directory}/cronlog_${date_time}.log"

# ===== START LOGGING =====
echo "=== $(date) : Cron job started ===" >> "$log_file"

# Check if localhost/podxs-fnf:latest exists
if ctr -n k8s.io images list | grep -q "localhost/podxs-fnf:latest"; then
    echo "[INFO] Image localhost/podxs-fnf:latest is found." >> "$log_file"
    echo "=== Job completed ===" >> "$log_file"
    exit 0
fi

# If image not found, go to tar directory
cd "$tars_directory" || {
    echo "[ERROR] Failed to access tar directory: $tars_directory" >> "$log_file"
    exit 1
}

echo "[INFO] Current directory: $(pwd)" >> "$log_file"

# Search for tar file
if [[ ! -f "podxs-fnf.tar" ]]; then
    echo "[ERROR] podxs-fnf.tar not found in $tars_directory" >> "$log_file"
    exit 1
fi

# Import tar file
if ctr -n k8s.io image import "podxs-fnf.tar" >> "$log_file" 2>&1; then
    echo "[INFO] Import step done." >> "$log_file"
else
    echo "[ERROR] Failed to import podxs-fnf.tar" >> "$log_file"
    exit 1
fi

# Check if imported image exists
if ctr -n k8s.io images list | grep -q "docker.io/library/podxs-fnf:latest"; then
    if ctr -n k8s.io images tag docker.io/library/podxs-fnf:latest localhost/podxs-fnf:latest >> "$log_file" 2>&1; then
        echo "[INFO] Image tagged with localhost/podxs-fnf:latest and ready to be used." >> "$log_file"
    else
        echo "[ERROR] Failed to tag image with localhost." >> "$log_file"
        exit 1
    fi
else
    echo "[ERROR] Issue happened after importing: docker.io/library/podxs-fnf:latest not found." >> "$log_file"
    exit 1
fi

echo "=== Job completed successfully ===" >> "$log_file"

