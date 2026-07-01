# these are custom sub agents

* here we put markdown files, each markdown file is an agent with a specific task

## install a new sub agent

e.g. a new **review** agent

```bash
mkdir -p ~/.config/opencode/agents/
cp ./review.md ~/.config/opencode/agents/review.md
```

* you can call this subagent inside the prompot with an `@review`
* **the agent will be launched automaticly**


## create a new agent
* just write an md file.
* store them in this dir