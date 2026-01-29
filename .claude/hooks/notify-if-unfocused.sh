#!/bin/bash

# Play sound only if Claude Code window is not focused
SOUND="/System/Library/Sounds/Glass.aiff"

# Read hook input from stdin
input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id // empty')

# Get Claude's window from the saved file (written at SessionStart)
if [ -n "$session_id" ] && [ -f "$HOME/.claude/hooks/claude-window-$session_id" ]; then
    CLAUDE_WINDOW=$(cat "$HOME/.claude/hooks/claude-window-$session_id")
else
    CLAUDE_WINDOW=$(tmux display-message -p '#{window_index}' 2>/dev/null)
fi

# Check if Alacritty is the focused app (system-level check via yabai)
focused_app=$(yabai -m query --windows --window 2>/dev/null | jq -r '.app // empty')

if [ "$focused_app" != "Alacritty" ]; then
    afplay "$SOUND" &
    exit 0
fi

# In Alacritty - check which tmux window is active
active_window=$(tmux list-windows -F '#{?window_active,#{window_index},}' 2>/dev/null | grep -v '^$')

if [ "$active_window" != "$CLAUDE_WINDOW" ]; then
    afplay "$SOUND" &
fi

exit 0
