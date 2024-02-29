# qwe

## How to install?
`brew install matyash12/personaltap/qwe`

## Docs
Usage: qwe [OPTIONS] 'What do you want to do'

    This command interacts with the OpenAI API.

    Options:
      -h, --help                Show this help message and exit
      -v, --verbose             Enable debug mode, providing additional output for troubleshooting
      -t, --tokens TOKENS       Set the maximum number of tokens for the API request (default: 255)
      -m, --model MODEL         Set the model for the API request (default: 'gpt-3.5-turbo')
      -p, --pc_info PC_INFO     Set the PC info (default: output of 'uname -s')
      -s, --skip                For debugging. Won't connect to API
      -sk, --set_key API_KEY    Save OpenAI key for future use in ~/.bash_profile
      -k, -key API_KEY          Set OpenAI key only for this command

    Examples:
      qwe -t 200 -m 'text-davinci-002'
      qwe --verbose --pc_info 'My Custom PC Info and verbose mode'
