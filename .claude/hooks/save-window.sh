#!/bin/bash

# Save the tmux window index for this Claude session
input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id // empty')

if [ -n "$session_id" ]; then
    tmux display-message -p '#{window_index}' > "$HOME/.claude/hooks/claude-window-$session_id"
fi
