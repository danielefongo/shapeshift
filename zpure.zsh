setopt prompt_subst
autoload -U colors && colors

source "async.zsh"
source "git.zsh"
source "dir.zsh"

function prompt_dir_and_arrow() {
    echo "$(prompt_dir) $(prompt_arrow) "
}

function PCMD() {
    echo "$(prompt_dir_and_arrow)"
}

function RCMD() {
    local FULL=""
    for method in $PROMPT_RIGHT_ELEMENTS; do
        if [[ -f "/tmp/${method}" ]]; then
          methodOutput=$(cat < /tmp/${method})
          if [[ $methodOutput ]]; then
            FULL="$FULL $methodOutput"
          fi
        fi
    done
    echo "${FULL}"
}

PROMPT='$(PCMD)'
RPROMPT=''

function TRAPUSR1() {
    RPROMPT="$(RCMD)"
    zle && zle reset-prompt
}

function asyncRun() {
    method="${1}"
    eval "$method" > "/tmp/$method"
}

function precmd() {
    for method in $PROMPT_RIGHT_ELEMENTS; do
        asyncJob asyncRun "" ${method}
    done
}
