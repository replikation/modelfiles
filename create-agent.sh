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

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" &>/dev/null && pwd)
mapfile -t FOUND_MODELS < <(find "$SCRIPT_DIR" \( -name "Modelfile" -o -name "*.modelfile" \) -type f 2>/dev/null | sort)

if [[ -d "$SCRIPT_DIR/opencode" ]]; then
    while IFS= read -r -d '' file; do
        FOUND_MODELS+=("$file")
    done < <(find "$SCRIPT_DIR/opencode" -type f ! -name "*.md" ! -name ".*" -print0 2>/dev/null)
fi

# Filter templates and extract metadata for sorting
raw_list=()
for file in "${FOUND_MODELS[@]}"; do
    filename=$(basename "$file")
    # Skip templates (case-insensitive check)
    if [[ "$filename" =~ [Tt][Ee][Mm][Pp][Ll][Aa][Tt][Ee] ]] || [[ "$file" =~ /[Tt][Ee][Mm][Pp][Ll][Aa][Tt][Ee]/ ]]; then
        continue
    fi
    
    # Read metadata safely under set -euo pipefail
    vram_req=""
    if grep -q -i '^# VRAM_REQ:' "$file" 2>/dev/null; then
        vram_req=$(grep -i '^# VRAM_REQ:' "$file" | head -n 1 | sed -E 's/^# VRAM_REQ:\s*//I' | tr -d '\r' | xargs 2>/dev/null || true)
    fi
    vram_num=$(echo "$vram_req" | grep -o -E '[0-9]+' || true)
    vram_num=${vram_num:-0}
    
    model_name=""
    if grep -q -i '^# MODEL_NAME:' "$file" 2>/dev/null; then
        model_name=$(grep -i '^# MODEL_NAME:' "$file" | head -n 1 | sed -E 's/^# MODEL_NAME:\s*//I' | tr -d '\r' | xargs 2>/dev/null || true)
    fi
    
    hardware=""
    if grep -q -i '^# HARDWARE:' "$file" 2>/dev/null; then
        hardware=$(grep -i '^# HARDWARE:' "$file" | head -n 1 | sed -E 's/^# HARDWARE:\s*//I' | tr -d '\r' | xargs 2>/dev/null || true)
    fi
    
    description=""
    if grep -q -i '^# DESCRIPTION:' "$file" 2>/dev/null; then
        description=$(grep -i '^# DESCRIPTION:' "$file" | head -n 1 | sed -E 's/^# DESCRIPTION:\s*//I' | tr -d '\r' | xargs 2>/dev/null || true)
    fi
    
    raw_list+=("${vram_num};${vram_req};${model_name};${hardware};${description};${file}")
done

if [[ ${#raw_list[@]} -eq 0 ]]; then
    echo -e "${RED} No model files found in repo${NC}"
    exit 1
fi

# Sort by VRAM requirement (numerically)
mapfile -t sorted_raw < <(printf "%s\n" "${raw_list[@]}" | sort -t';' -k1,1n)

# Re-populate MODELS array and extract sorted details
MODELS=()
MODEL_NAMES=()
MODEL_VRAMS=()
MODEL_VRAM_NUMS=()
MODEL_HARDWARES=()
MODEL_DESCS=()

for row in "${sorted_raw[@]}"; do
    IFS=';' read -r v_num v_req m_name hw desc path <<< "$row"
    MODELS+=("$path")
    MODEL_NAMES+=("$m_name")
    MODEL_VRAMS+=("$v_req")
    MODEL_VRAM_NUMS+=("$v_num")
    MODEL_HARDWARES+=("$hw")
    MODEL_DESCS+=("$desc")
done

echo -e "${CYAN}Available models:${NC}"
echo ""
printf "${BOLD}%-5s %-27s  %-8s  %-18s  %s${NC}\n" "IDX" "MODEL NAME" "VRAM" "HARDWARE" "DESCRIPTION"
printf "${BOLD}%-5s %-27s  %-8s  %-18s  %s${NC}\n" "---" "----------" "----" "--------" "-----------"

for i in "${!MODELS[@]}"; do
    path="${MODELS[$i]}"
    m_name="${MODEL_NAMES[$i]}"
    v_req="${MODEL_VRAMS[$i]}"
    v_num="${MODEL_VRAM_NUMS[$i]}"
    hw="${MODEL_HARDWARES[$i]}"
    desc="${MODEL_DESCS[$i]}"
    
    display_name="${m_name:-$(basename "$path")}"
    
    # VRAM color coding: Green (<=12GB), Yellow (<=24GB), Red (>24GB)
    if [[ "$v_num" -eq 0 ]]; then
        vram_color="${NC}"
        vram_display="-"
    elif [[ "$v_num" -le 12 ]]; then
        vram_color="${GREEN}"
        vram_display="${v_req}"
    elif [[ "$v_num" -le 24 ]]; then
        vram_color="${YELLOW}"
        vram_display="${v_req}"
    else
        vram_color="${RED}"
        vram_display="${v_req}"
    fi
    
    printf "${GREEN}[%2d]${NC}  %-27.27s  ${vram_color}%-8s${NC}  %-18.18s  %s\n" \
        "$((i+1))" "$display_name" "$vram_display" "$hw" "$desc"
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
