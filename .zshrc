function scopedfzf() {
	find . -maxdepth $1 2>&1 | grep -v 'Operation not permitted' | fzf
}

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

jp() {
    local selected_dir
    selected_dir=$(dirs -pl | sort | uniq | fzf --height 40% --reverse --border)
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

js ()  {
        if [[ -n "$1" ]]; then
                cursor -g "$1"
                return
        fi

        local selected_file
        selected_file=$(git grep -Ein ".*" | fzf)
        if [ -n "$selected_file" ]; then
            file=$(echo "$selected_file" | cut -d ":" -f1)
            line=$(echo "$selected_file" | cut -d ":" -f2)
            if [ -f "$file" ]; then
                cursor -g "$file:$line"
                print -s "js $file:$line"
            fi
        fi
}

# tmux
if [ -z "$TMUX" ]; then
    tmux attach-session -t default || tmux new-session -s default
fi

# After entering these, you need to log out and log back in. On OSX, these make your keys get entered much faster!
defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 2 # normal minimum is 2 (30 ms)

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
alias 'clear'='clear && tmux clear-history'
alias 'la'='ls -al'
alias 'cd'='pushd > /dev/null'
alias '..'='cd ..'
alias '~'='cd ~'

# git aliases
alias ga='git add'
alias gaa='git add --all'
alias gs='git status'
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
  cd ~/workplace/pos && git pull
  cd ~/workplace/pos-backend && git pull
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

# Prompt
# -----------------------------------------------------------------------------
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

# Vim Binds Prompt
DEFAULT_PROMPT='(%*) %n@%m %{%}%F{#FFFFFF}%B%c%B%F{#CDD6F3}%{%}$(parse_git_branch)
 %F{red}➜%f '
PROMPT=$DEFAULT_PROMPT

local cursor_shape_beam='\e[6 q'
local cursor_shape_block='\e[2 q'

# Change cursor shape for different vi modes.
function zle-keymap-select {
    if [[ $KEYMAP == vicmd ]]; then
        echo -ne $cursor_shape_block
    else
        echo -ne $cursor_shape_beam
    fi
}

function zle-line-finish {
    echo -ne $cursor_shape_beam
}

# Initialize cursor shape
echo -ne $cursor_shape_beam

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

# Enable surround-style operations
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -a cs change-surround
bindkey -a ds delete-surround
bindkey -a ys add-surround
bindkey -M visual S add-surround

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

export PATH="$PATH:/Users/jakobberg/workplace/flutter/bin"
export PATH="$PATH:$(go env GOPATH)/bin"
export PATH="$PATH:/Users/jakobberg/workplace/github/scripts"

x=$(echo $PATH | tr ":" "\n" | sort | uniq | tr "\n" ":")
export PATH="${x::-1}"
# Ruby needs to go at the start so that it beats the system default ruby
export PATH="/usr/local/opt/ruby/bin:$PATH"
unset x
