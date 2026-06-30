Model files
===

Repo containing some model files and descriptions for it etc.


# how to create an specific agent using the model files here

```bash
./create-agents.sh
```

# how to get an overview about agents your local models

```bash
./ollama-overivew.sh
```

# how to check online at ollama what models are available

* needs a search term

```bash
./online_models.sh
```

# Models to test


qwen 3.6


# hardcode configure a model into opencode (to avoid ollama launch)

```
nano ~/.config/opencode/opencode.jsonc
```

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (Local)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "gemma4__12b-q4:latest": {
          "name": "gemma4__12b-q4:latest",
          "capabilities": ["text", "image", "tools"]
        }
      }
    }
  }
}
```

# images and files
* the @ context only works for git staged files
* opencode reads this through the git staging and git lists