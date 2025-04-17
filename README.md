# Script to cleanup and purge all OpenAI storage, including vector storage and files.

Run it from the command line.

1. chmod +x cleanup_openai.sh
2. export OPENAI_API_KEY='your-api-key'
3. while true; do echo "Starting new cleanup run at $(date)"; ./cleanup_openai.sh; sleep 5; done

# Notes
This will purge all the Storage.
Vector storage `has_more` sometimes lag, so run the script in an infinite loop to clear up any clogged vectors.
use this responsbility, if you get banned or rate limited, it's your fault only.
