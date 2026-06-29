#!/usr/bin/env bash
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}       Ollama Agent Creator${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

mapfile -t MODELS < <(find . \( -name "Modelfile" -o -name "*.modelfile" \) -type f 2>/dev/null | sort)

if [[ -d "./opencode" ]]; then
    while IFS= read -r -d '' file; do
        MODELS+=("$file")
    done < <(find ./opencode -type f ! -name "*.md" ! -name ".*" -print0 2>/dev/null)
fi

if [[ ${#MODELS[@]} -eq 0 ]]; then
    echo -e "${RED} No model files found in repo${NC}"
    exit 1
fi

echo -e "${CYAN}Available models:${NC}"
echo ""

for i in "${!MODELS[@]}"; do
    model_path="${MODELS[$i]}"
    model_dir=$(dirname "$model_path")
    model_file=$(basename "$model_path")
    
    if [[ "$model_file" == "Modelfile" ]]; then
        agent_name="$model_dir"
    else
        agent_name="$model_file"
    fi
    
    echo -e "  ${GREEN}[$((i+1))]${NC} ${YELLOW}$model_dir/${model_file}${NC}"
    echo -e "          ${CYAN}→${NC} Agent: ${BOLD}$agent_name${NC}"
    echo ""
done

echo -n -e "${CYAN}Select model (1-${#MODELS[@]}): ${NC}"
read -r choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [[ $choice -lt 1 ]] || [[ $choice -gt ${#MODELS[@]} ]]; then
    echo -e "${RED} Invalid selection${NC}"
    exit 1
fi

selected_index=$((choice-1))
model_path="${MODELS[$selected_index]}"
model_dir=$(dirname "$model_path")
model_file=$(basename "$model_path")

if [[ "$model_file" == "Modelfile" ]]; then
    default_name=$(basename "$model_dir")
else
    default_name="$model_file"
fi

echo ""
echo -e "${GREEN}✓${NC} Selected: ${YELLOW}$model_path${NC}"
echo ""

echo -n -e "${CYAN}Enter agent name (default: ${BOLD}$default_name${NC}${CYAN}): ${NC}"
read -r agent_name
agent_name=${agent_name:-$default_name}

echo ""
echo -e "${BLUE}----------------------------------------${NC}"
echo -e "${CYAN}Creating agent: ${BOLD}$agent_name${NC}"
echo -e "${CYAN}From model: ${BOLD}$model_path${NC}"
echo -e "${BLUE}----------------------------------------${NC}"
echo ""

cd "$model_dir"
echo -e "${YELLOW}Running:${NC} ollama create ${BOLD}$agent_name${NC} -f ${BOLD}$model_file${NC}"
echo ""

if ollama create "$agent_name" -f "$model_file"; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  ✓ Agent '${agent_name}' created!${NC}"
    echo -e "${GREEN}========================================${NC}"
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}  ✗ Failed to create agent${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
fi
