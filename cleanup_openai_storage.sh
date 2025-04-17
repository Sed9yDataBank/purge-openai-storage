#!/bin/bash

# Check if OPENAI_API_KEY is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "Error: OPENAI_API_KEY environment variable is not set"
    echo "Please set it using: export OPENAI_API_KEY='your-api-key'"
    exit 1
fi

# Function to sleep for random duration between 1-2 seconds
random_sleep() {
    # Generate random number between 10-20 (for 1.0-2.0 seconds)
    local sleep_time=$(( (RANDOM % 11 + 10) ))
    sleep "0.${sleep_time}"
}

echo "Fetching all vector stores..."

# Get list of all vector stores with proper pagination
fetch_and_delete_vector_stores() {
    local after_id=""
    local has_more="true"

    while [ "$has_more" = "true" ]; do
        local url="https://api.openai.com/v1/vector_stores"
        if [ -n "$after_id" ]; then
            url="${url}?after=${after_id}"
        fi

        # Fetch vector stores
        response=$(curl -s "$url" \
            -H "Authorization: Bearer $OPENAI_API_KEY")
        random_sleep

        # Extract vector store IDs using grep and sed
        echo "$response" | grep -o '"id": *"[^"]*"' | sed 's/"id": *"//;s/"$//' | while read -r store_id; do
            echo "Deleting vector store: $store_id"
            curl -s -X DELETE "https://api.openai.com/v1/vector_stores/$store_id" \
                -H "Authorization: Bearer $OPENAI_API_KEY"
            echo
            random_sleep
        done

        # Check if there are more pages
        has_more=$(echo "$response" | grep -o '"has_more": *[^,}]*' | sed 's/"has_more": *//;s/[,}]$//')
        if [ "$has_more" = "true" ]; then
            after_id=$(echo "$response" | grep -o '"last_id": *"[^"]*"' | sed 's/"last_id": *"//;s/"$//')
        fi
    done
}

# Execute vector store cleanup
fetch_and_delete_vector_stores

echo "Fetching all files from OpenAI..."

# Get list of all files
response=$(curl -s "https://api.openai.com/v1/files" \
    -H "Authorization: Bearer $OPENAI_API_KEY")
random_sleep

# Extract and delete each file
echo "$response" | grep -o '"id": *"[^"]*"' | sed 's/"id": *"//;s/"$//' | while read -r file_id; do
    echo "Deleting file: $file_id"
    curl -s -X DELETE "https://api.openai.com/v1/files/$file_id" \
        -H "Authorization: Bearer $OPENAI_API_KEY"
    echo
    random_sleep
done

echo "Cleanup completed!" 
