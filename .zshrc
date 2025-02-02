# -----------
# To get shortcuts to open apps
# brew install koekeishiya/formulae/skhd
# skhd --start-service
# ~/.config/skhd/skhdrc
# skhd --restart-service
# -----------

# History (From https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/history.zsh)
# -----------------------------------------------------------------------------

# History wrapper
function omz_history {
  # parse arguments and remove from $@
  local clear list stamp
  zparseopts -E -D c=clear l=list f=stamp E=stamp i=stamp

  if [[ $# -eq 0 ]]; then
    # if no arguments provided, show full history starting from 1
    builtin fc $stamp -l 1
  elif [[ -n "$clear" ]]; then
    # if -c provided, clobber the history file
    echo -n >| "$HISTFILE"
    fc -p "$HISTFILE"
    echo >&2 History file deleted.
  else
    # otherwise, run `fc -l` with a custom format
    builtin fc $stamp -l "$@"
  fi
}

# Timestamp format
case ${HIST_STAMPS-} in
  "mm/dd/yyyy") alias history='omz_history -f' ;;
  "dd.mm.yyyy") alias history='omz_history -E' ;;
  "yyyy-mm-dd") alias history='omz_history -i' ;;
  "") alias history='omz_history' ;;
  *) alias history="omz_history -t '$HIST_STAMPS'" ;;
esac

## History file configuration
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
[ "$HISTSIZE" -lt 50000 ] && HISTSIZE=50000
[ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000

## History command configuration
setopt appendhistory
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

function countLoc() {
	git ls-files | xargs wc -l | tail -n1 | awk '{print $1}'
}

j() {
    local selected_dir
    selected_dir=$(find . 2>/dev/null | fzf --height 40% --reverse --border)
    if [[ -n "$selected_dir" ]]; then
        cd "$selected_dir"
    fi
}

jc () {
        if [[ -n "$1" ]]; then
                cursor "$1"
                return
        fi

        local selected_file
        selected_file=$(find . -type f 2>/dev/null | fzf --height 40% --reverse --border)
        if [[ -n "$selected_file" ]]
        then
                cursor "$selected_file"
                print -s "jc $selected_file"
        fi
}

# must brew install bat rg
js() {
    local selected_file
    local include_vendor=false
    local search_term=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--vendor) include_vendor=true; shift ;;
            *) search_term="$1"; shift ;;
        esac
    done

    # Set default search term if none provided
    search_term=${search_term:-".*"}

    # Use rg with built-in colors
    local rg_command="rg --smart-case --line-number --color always \
        --colors=path:fg:blue --colors=path:style:bold \
        --colors=line:fg:green --colors=line:style:bold \
        --colors=match:none"

    if [ "$include_vendor" = false ]; then
        rg_command="$rg_command --glob '!vendor/*'"
    fi

    selected_file=$(eval "$rg_command \"$search_term\"" | \
        fzf --ansi --preview-window=default --preview='
            file=$(echo {} | cut -d ":" -f1 | head -n1)
            line=$(echo {} | cut -d ":" -f2 | head -n1)
            if [ -n "$file" ] && [ -n "$line" ]; then
                bat --style=numbers,grid --color=always --highlight-line "$line" --line-range "$((line > 10 ? line - 10 : 1)):$((line + 10))" "$file"
            fi
        ')

    if [[ -n "$selected_file" ]]; then
        local file line
        file=$(echo "$selected_file" | cut -d ":" -f1 | head -n1)
        line=$(echo "$selected_file" | cut -d ":" -f2 | head -n1)

        if [[ -f "$file" ]]; then
            print -s "cursor -g \"$file:$line\""
            cursor -g "$file:$line"
        fi
    fi
}

# After entering these, you need to log out and log back in. On OSX, these make your keys get entered much faster!
defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

## Kills the dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 1000
defaults write com.apple.dock autohide-time-modifier -float 0
killall Dock

## Make dock normal
#defaults delete com.apple.dock autohide
#defaults delete com.apple.dock autohide-delay
#defaults delete com.apple.dock autohide-time-modifier
#killall Dock

function createCodeCov() {
	go test ./... -coverprofile=cover.out && go tool cover -html=cover.out
}
alias 'clear'='echo STOP'
alias ls='eza --group-directories-first --icons'
alias ll='eza --group-directories-first --icons -l'
alias la='eza --group-directories-first --icons -la'
alias tree='eza --group-directories-first --icons --tree'
alias '..'='cd ..'
alias '~'='cd ~'

# git aliases
alias ga='git add'
alias gaa='git add --all'
gs() { git status | grep -vE '\(use "git .*?".*?)'; }
alias gcm='git commit -m'
alias gc='git commit'
alias grs='git restore'
alias grbi='git rebase -i'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gpl='git pull'
alias gps='git push'
alias gpo='git push origin'
alias gm='git merge'
alias gst='git stash'
alias gstp='git stash pop'
alias glog='git log --stat'

function mkcd() {
	mkdir $1 && cd $1
}

function serve() {
  echo "serving $(pwd) on http://$(hostname):8000"
  python3 -m http.server
}

function g() {
  cd $(git rev-parse --show-toplevel)
}

function syncPos {
  currentDir=$(pwd)
  cd ~/workplace/pos && git pull &
  cd ~/workplace/pos-backend && git pull &
  cd $currentDir
}

# Plugins
# -----------------------------------------------------------------------------
#     brew install zsh-completion

# https://github.com/zsh-users/zsh-completions/issues/433
# https://stackoverflow.com/questions/13762280/zsh-compinit-insecure-directories
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

# ignore case in autocompletion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# 	  brew install fzf
eval "$(fzf --zsh)"

# use fzf in vim
set rtp+=/opt/homebrew/opt/fzf

#     brew install zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

#     brew install zsh-syntax-highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#     brew install zoxide
eval "$(zoxide init zsh --cmd cd)"

# Global Settings
# -----------------------------------------------------------------------------
alias grep='grep --color=auto'

# Mac Settings
# -----------------------------------------------------------------------------
if [[ $(uname) == "Darwin" ]]; then
  # Brew
  eval $(/usr/local/bin/brew shellenv)

  # Colors
  export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
  export CLICOLOR=1
fi


# Linux Settings
# -----------------------------------------------------------------------------
if [[ $(uname) == "Linux" ]]; then
  # Brew
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

  # Normalize pbcopy/paste
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'

  # Colors
  color_prompt=yes
  alias ls='ls --color=auto'
fi

## Colorful man pages:
man() { LESS_TERMCAP_mb=$'\e[01;31m' LESS_TERMCAP_md=$'\e[01;38;5;220m' LESS_TERMCAP_me=$'\e[0m' LESS_TERMCAP_se=$'\e[0m' LESS_TERMCAP_so=$'\e[38;5;63m' LESS_TERMCAP_ue=$'\e[0m' LESS_TERMCAP_us=$'\e[04;38;5;202m' command man $1 ; }

# PROMPT
# -----------------------------------------------------------------------------

# Git prompt configuration

parse_git_branch() {
  BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  if [[ ! "${BRANCH}" == "" ]]; then
    if [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working tree clean" ]]; then
       STATUS="\e[0;31m✘"
     else
       STATUS="\e[0;32m✔"
     fi
    printf " \e[0;32m${BRANCH} ${STATUS}"
  else
    printf ""
  fi
}

current_venv() {
  if [[ ! -z "$VIRTUAL_ENV" ]]; then
    # Show this info only if virtualenv is activated:
    local dir=$(basename "$VIRTUAL_ENV")
    echo "($dir) "
  fi
}

## Simone Vim
bindkey -v
bindkey -M vicmd ':' undefined-key
function delete-line-and-exit-cmd {
    zle kill-whole-line
    zle vi-insert
}
bindkey -M vicmd '^U' delete-line-and-exit-cmd

setopt PROMPT_SUBST
# # Vim Binds Prompt
PROMPT='(%*) %n@%m %{%}%F{#FFFFFF}%B%~%B%F{#CDD6F3}%{%}$(parse_git_branch)
 %F{red}➜%f '

# Vim Binds Cursor Type
function _set_block_cursor() { echo -ne '\e[2 q'; }
function _set_beam_cursor() { echo -ne '\e[6 q'; }

function zle-keymap-select {
    if [[ $KEYMAP == vicmd ]]; then
        _set_block_cursor
    else
        _set_beam_cursor
    fi
}
zle -N zle-keymap-select

preexec_functions+=(_set_block_cursor)
precmd_functions+=(_set_beam_cursor)

# Reduce vi mode switching delay (makes it so that zsh checks every 0.01 seconds for a completed key sequence)
export KEYTIMEOUT=1

zle -N zle-keymap-select

# Fix backspace in vi insert mode
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

# Fix
bindkey -M viins '^I' fzf-completion
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^F' forward-char
bindkey '^B' backward-char
bindkey '^D' delete-char
bindkey '^H' backward-delete-char
bindkey '^K' kill-line
bindkey '^U' backward-kill-line
bindkey '^W' backward-kill-word
bindkey '^Y' yank
bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history
bindkey '^L' clear-screen

# Text object support for quotes, brackets, etc. (ci", vi", va", etc)
autoload -U select-quoted select-bracketed
zle -N select-quoted
zle -N select-bracketed

# Enable support for different quote types
for m in visual viopp; do
    for c in {a,i}{\',\",\`}; do
        bindkey -M $m $c select-quoted
    done
    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M $m $c select-bracketed
    done
done

## Make it so pressing 'vv' in normal mode opens vim
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd "v" edit-command-line

# Enable surround-style operations
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -a cs change-surround
bindkey -a ds delete-surround
bindkey -a ys add-surround
bindkey -M visual S add-surround

bindkey -r ^R
zle -N fzf-file-widget
bindkey ^K fzf-history-widget
function cdi_and_accept() {
    # Zle -I and the || case make it so that this behaves just like how history lookup for fuzzy find works.

    zle -I   # Tell zsh this is an interactive command
    # Store current cursor position
    local old_cursor=$CURSOR
    cdi || {
        # On abort/escape, restore cursor position and redraw the line
        CURSOR=$old_cursor
        zle redisplay
        return 1
    }
}
zle -N cdi_and_accept
bindkey ^J cdi_and_accept

export PATH="$PATH:/Users/jakobberg/workplace/flutter/bin"
export PATH="$PATH:$(go env GOPATH)/bin"
export PATH="$PATH:/Users/jakobberg/workplace/github/scripts"

x=$(echo $PATH | tr ":" "\n" | sort | uniq | tr "\n" ":")
export PATH="${x::-1}"
# Ruby needs to go at the start so that it beats the system default ruby
export PATH="/usr/local/opt/ruby/bin:$PATH"
unset x

function tmuxSourceAll() {
    tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}' | xargs -I {} tmux send-keys -t {} 'source ~/.zshrc' Enter
}

export FZF_DEFAULT_OPTS="\
--ansi \
--multi \
--bind='ctrl-j:down,ctrl-k:up,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-f:toggle+clear-query+first,ctrl-q:clear-query+clear-selection+first,ctrl-s:toggle-preview' \
--preview='bat --color=always {}' \
--preview-window=hidden
"

if [ -z "$TMUX" ]; then
    start-tmux.sh
fi