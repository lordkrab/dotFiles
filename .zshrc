function fzfcode() { code $(fzf --query '!^build/ ') }

function scopedfzf() {
	find . -maxdepth $1 2>&1 | grep -v 'Operation not permitted' | fzf
}

## After entering these, you need to log out and log back in. On OSX, these make your keys get entered much faster!
defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 2 # normal minimum is 2 (30 ms)

alias 'la'='ls -al'
alias 'cd'='pushd > /dev/null'
alias '..'='cd ..'
alias '~'='cd ~'
function mkcd() {
	mkdir $1 && cd $1
}

function udirs() { 
  dirs -l | tr " " "\n" | sort | uniq | awk '{ print NR, $0 }'
}
function dvcd() {
	cd $(udirs | head -n"$1" | tail -n1 | xargs | cut -d" " -f2)
}

alias dv="dirs -v"

function serve() {
  echo "serving $(pwd) on http://$(hostname):8000"
  python3 -m http.server
}

function goToPackageRoot() {
	originalPwd=`pwd`

        for i in {1..20}; do
                if [[ `git status 2>&1` == *"not a git repository"* ]]; then
                        cd -
			return
                fi
                cd ..
        done
	
	echo "seems you're not in a workspace."
	cd $originalPwd
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
export EDITOR=vi
export VISUAL=vi
set -o vi mode
alias grep='grep --color=auto'

# For searching only type script files
function tgrep() { grep --include ".*\.ts" --exclude ".*\.d\.ts" $@ }

# Make 
export NODE_OPTIONS="--max-old-space-size=8192"

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

setopt PROMPT_SUBST
PROMPT='
(%*) %n@%m $(current_venv)%B%~%b$(parse_git_branch)
 %F{red}➜%f '

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

