# AGENTS.md

## Purpose
This repo contains Ollama model files for custom agents. Each subdirectory holds a `Modelfile` or similar configuration.

## Structure
- `opencode/` — Model files for OpenCode agents
- `openclaude/` — Model files for OpenClaude agents

## Workflow
To create an agent from a model file:
```bash
ollama create <name> -f ./Modelfile
```

The main `Modelfile` in the root creates the `gemma4-agent`.

## Notes
- Model files derive from official Ollama library models (e.g., `gemma4:31b-coding-mtp-bf16`)
- Customize parameters (`num_ctx`, `temperature`, `top_p`, `top_k`) in each `Modelfile` as needed
