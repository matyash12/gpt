#!/bin/bash

function qwe() {

    # Set variables
    pc_info=$(uname -s)
    model_name="gpt-3.5-turbo"
    max_tokens="255"
    api_url="https://api.openai.com/v1/chat/completions"
    help_string="
    Usage: qwe [OPTIONS]

    This command interacts with the OpenAI API.

    Options:
      -h, --help                Show this help message and exit
      -v, --verbose             Enable debug mode, providing additional output for troubleshooting
      -t, --tokens TOKENS       Set the maximum number of tokens for the API request (default: 255)
      -m, --model MODEL         Set the model for the API request (default: 'gpt-3.5-turbo')
      -p, --pc_info PC_INFO     Set the PC info (default: output of 'uname -s')
      -s, --skip                For debugging. Won't connect to API

    Examples:
      qwe -t 200 -m 'text-davinci-002'
      qwe --debug --pc_info 'My Custom PC Info'
    "


    verbose_mode=0
    #This if for when debugging i dont wanna waste tokens
    #0 = returns before curl request
    #1 = runs normally
    connect_to_api=1

    #Clearning the PARAMS
    PARAMS=""
    # Parse options
    while (( "$#" )); do
        case "$1" in
            -h|--help)
                echo "$help_string"
                return
                ;;
            -v|--verbose)
                verbose_mode=1
                shift
                ;;
            -t|--tokens)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    max_tokens=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    return
                fi
                ;;
            -m|--model)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    model_name=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    return
                fi
                ;;
            -p|--pc_info)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    pc_info=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    return
                fi
                ;;
            -s|--skip)
                connect_to_api=0
                shift
                ;;
            -*|--*=) # unsupported flags
                echo "Error: Unsupported flag $1" >&2
                return
                ;;
            *) # preserve positional arguments
                PARAMS="$PARAMS $1"
                shift
                ;;
        esac
    done

    if [[ "$verbose_mode" == 1 ]]; then
        echo "verbose (debug) mode on"
    fi

    # Check if the API key is set
    if [ -z "$OPENAI_API_KEY" ]; then
        echo "Error: OPENAI_API_KEY is not set. Please set your OpenAI API key."
        return
    fi

    # Check if input is provided as a command-line argument
    if [ -z "$PARAMS" ]; then
        echo "qwe: try 'qwe --help' for more information"
        return
    fi

    # Set variables
    input_text="$PARAMS"

    if [[ "$verbose_mode" == 1 ]]; then
        echo "Variables before sending curl request"

        echo "verbose_mode:$verbose_mode"
        echo "input_text:$input_text"
        echo "pc_info:$pc_info"
        echo "model_name:$model_name"
        echo "max_tokens:$max_tokens"
        echo "api_url:$api_url"
    fi

    if [[ "$connect_to_api" == 0 ]]; then
        echo "Ending the command"
        return
    fi


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
        eval $command_to_run
    fi
}
