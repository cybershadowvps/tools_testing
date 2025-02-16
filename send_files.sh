#!/bin/bash

# Define variables
DIR="./"
CONFIG_FILE="./config.yaml"
BOT_API_KEY=""  # This will be extracted from config.yaml
CHAT_ID=""      # This will be extracted from config.yaml

# Function to extract values from config.yaml
extract_values() {
    BOT_API_KEY=$(grep "telegram_api_key" "$CONFIG_FILE" | awk -F '"' '{print $2}')
    CHAT_ID=$(grep "telegram_chat_id" "$CONFIG_FILE" | awk -F '"' '{print $2}')
}

# Check if config.yaml exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: $CONFIG_FILE not found! Run setup first."
    exit 1
fi

# Extract API Key and Chat ID from config.yaml
extract_values

# Check if API Key and Chat ID are extracted
if [[ -z "$BOT_API_KEY" || -z "$CHAT_ID" ]]; then
    echo "Error: Could not extract API Key or Chat ID from config.yaml!"
    exit 1
fi

# Check if there are files to send
if [[ -z $(find "$DIR" -maxdepth 1 -type f ! -name "config.yaml" ! -name "send_files.sh") ]]; then
    echo "Error: No files found in the directory!"
    exit 1
fi

# Loop through all files and send them one by one
for file in "$DIR"*; do
    if [[ -f "$file" && "$file" != "$CONFIG_FILE" && "$file" != "$0" ]]; then
        echo "Uploading file: $file"

        curl -F "chat_id=$CHAT_ID" -F document=@"$file" "https://api.telegram.org/bot$BOT_API_KEY/sendDocument"

        echo "File $file sent successfully!"
    fi
done

echo "All files have been sent to Telegram!"
