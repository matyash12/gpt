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

    # Set variables
    input_text="$1"
    pc_info=$(uname -s)
    model_name="gpt-3.5-turbo"
    max_tokens="255"
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
    command_to_run=$(echo $response | jq -r '.choices[0].message.content')

    #Check if the command is not empty
    if [[ "$command_to_run" == "null" ]]; then
        echo "Request to openai failed"
        return
    fi

    #Show user the command
    echo "$command_to_run"

    # Ask user if he wants to run command
    printf 'Run this command (y/n)? '
    read answer

    # Run command if he says "y"
    if [ "$answer" != "${answer#[Yy]}" ]; then
        eval $content
    fi
}
