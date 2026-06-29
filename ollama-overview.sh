#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m"

printf "${CYAN}%-35s${NC} ${BLUE}%-12s${NC} ${YELLOW}%-12s${NC} ${GREEN}%-12s${NC} ${RED}%-12s${NC}\n" "MODEL" "PARAMS" "QNT" "CTX LEN" "TEMP"
printf "${CYAN}%-35s${NC} ${BLUE}%-12s${NC} ${YELLOW}%-12s${NC} ${GREEN}%-12s${NC} ${RED}%-12s${NC}\n" "-----" "------" "---" "-------" "----"

ollama list | tail -n +2 | while read -r line; do
    model=$(echo "$line" | awk '{print $1}')
    
    params=$(ollama show "$model" 2>/dev/null | grep 'parameters' | awk '{print $2}' | tr -d ' ')
    qnt=$(ollama show "$model" 2>/dev/null | grep 'quantization' | awk '{print $2}' | tr -d ' ')
    ctx=$(ollama show "$model" 2>/dev/null | grep 'context length' | awk '{print $3}' | tr -d ' ')
    temp=$(ollama show "$model" --parameters 2>/dev/null | grep 'temperature' | awk '{print $2}' | tr -d ' ')
    
    printf "${CYAN}%-35s${NC} ${BLUE}%-12s${NC} ${YELLOW}%-12s${NC} ${GREEN}%-12s${NC} ${RED}%-12s${NC}\n" "$model" "$params" "$qnt" "$ctx" "$temp"
done

echo
echo -e "${BLUE}Params:${NC} Model size in Billions (B) of parameters"
echo -e "${YELLOW}QNT:${NC} Quantization: Q4_K_M (smallest/faster) -> Q8 (higher quality) -> bf16 (best quality/largest)"
echo -e "${GREEN}CTX LEN:${NC} Context length (max tokens for input+output)"
echo -e "${RED}TEMP:${NC} Temperature (randomness of outputs: 0=deterministic, 1=random)"
