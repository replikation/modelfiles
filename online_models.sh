#!/bin/bash

MODEL=$1
if [ -z "$MODEL" ]; then
    echo "Usage: $0 <model_name>"
    exit 1
fi

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m"

printf "${CYAN}%-40s${NC} ${BLUE}%-12s${NC} ${YELLOW}%-12s${NC}\n" "MODEL" "SIZE" "CTX"
printf "${CYAN}%-40s${NC} ${BLUE}%-12s${NC} ${YELLOW}%-12s${NC}\n" "-----" "----" "---"

current_model=""
size=""
ctx=""
last_param=""

print_model() {
    local model="$1"
    local sz="$2"
    local c="$3"
    
    if [ -z "$model" ]; then
        return
    fi
    
    # Extract parameter size (e.g. from gemma:2b-instruct -> 2b)
    local param=""
    if [[ "$model" =~ : ]]; then
        local tag_part="${model#*:}"
        param="${tag_part%%-*}"
    fi
    
    # Print newline if parameter size changed
    if [ -n "$last_param" ] && [ "$last_param" != "$param" ]; then
        echo ""
    fi
    last_param="$param"
    
    printf "${CYAN}%-40s${NC} ${BLUE}%-12s${NC} ${YELLOW}%-12s${NC}\n" "$model" "$sz" "$c"
}

# Extract tags and attributes from the Ollama library page
# We identify tags by the presence of ':' and attributes by patterns like 'GB' or 'K'
while read -r line; do
    if [[ $line == *":"* ]]; then
        if [ -n "$current_model" ] && [[ "$current_model" == *"-"* ]]; then
            print_model "$current_model" "$size" "$ctx"
        fi
        current_model=$line
        size=""
        ctx=""
    elif [[ $line == *GB* ]]; then
        size=$line
    elif [[ $line == *K* ]]; then
        ctx=$line
    fi
done < <(curl -s "https://ollama.com/library/$MODEL/tags" | grep -oP 'value="\K[^"]+(?=")|text-\[13px\]">\K[^<]+(?=</p>)' | grep -v "Save changes")

# Print the last captured model
if [ -n "$current_model" ]; then
    print_model "$current_model" "$size" "$ctx"
fi
