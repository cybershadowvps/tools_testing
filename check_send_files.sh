#!/bin/bash

# Define variables
CONFIG_FILE="./config.yaml"
BOT_API_KEY=""
CHAT_ID=""

# Check if a file name is provided
if [[ -z "$1" ]]; then
    echo "Usage: ./send_files.sh <filename>"
    exit 1
fi

FILE="$1"
COMPRESSED_FILE="$FILE.gz"

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

# Check if the specified file exists
if [[ ! -f "$FILE" ]]; then
    echo "Error: File '$FILE' not found!"
    exit 1
fi

# Compress the file
echo "Compressing file: $FILE..."
gzip -c "$FILE" > "$COMPRESSED_FILE"

# Send the compressed file to Telegram
echo "Uploading compressed file: $COMPRESSED_FILE"

curl -F "chat_id=$CHAT_ID" -F document=@"$COMPRESSED_FILE" "https://api.telegram.org/bot$BOT_API_KEY/sendDocument"

echo "File $COMPRESSED_FILE sent successfully!"
