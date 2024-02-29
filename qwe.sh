#!/bin/bash

function qwe() {
    # Check if the API key is set
    if [ -z "$OPENAI_API_KEY" ]; then
        echo "Error: OPENAI_API_KEY is not set. Please set your OpenAI API key."
        return
    fi

    # Check if input is provided as a command-line argument
    if [ "$#" -eq 0 ]; then
        echo "Usage: gpt <input_text>"
        return
    fi

    # Set the input text from the command-line argument
    input_text="$1"

    # Info about the PC
    pc_info=$(uname -s)
    model_name="gpt-3.5-turbo"
    max_tokens="255"

    # OpenAI API endpoint (adjust the URL based on the API version you're using)
    api_url="https://api.openai.com/v1/chat/completions"

    # Make the API request using curl
    response=$(
        curl -s -X POST "$api_url" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $OPENAI_API_KEY" \
            -d '{
        "messages": [
            {
            "role": "user",
            "content": "answer only with the command. This is what the command should do: '"$input_text"'. Info about the pc: '"$pc_info"'"
            }
        ],
            "model": "'"$model_name"'",
            "max_tokens": '$max_tokens'
        }'
    )
    # Extract and print the generated text from the response
    content=$(echo $response | jq -r '.choices[0].message.content')

    if [[ "$content" == "null" ]]; then
        echo "Request to openai failed"
        return
    fi

    echo "$content"

    # Prompt user for input
    printf 'Run this command (y/n)? '
    read answer

    if [ "$answer" != "${answer#[Yy]}" ] ;then 
        eval $content
    fi
}
