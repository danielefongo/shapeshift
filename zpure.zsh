setopt prompt_subst
autoload -U colors && colors

source "async.zsh"
source "git.zsh"
source "dir.zsh"

function RIGHTCMD() {
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

function LEFTCMD() {
    local FULL=""
    for method in $PROMPT_LEFT_ELEMENTS; do
        if [[ -f "/tmp/${method}" ]]; then
          methodOutput=$(cat < /tmp/${method})
          if [[ $methodOutput ]]; then
            FULL="$FULL$methodOutput "
          fi
        fi
    done
    echo "${FULL}"
}

PROMPT=''
RPROMPT=''

function TRAPUSR1() {
    RPROMPT="$(RIGHTCMD)"
    PROMPT="$(LEFTCMD)"
    zle && zle reset-prompt
}

function asyncRun() {
    method="${1}"
    eval "$method" > "/tmp/$method"
}

function precmd() {
    for method in $PROMPT_LEFT_ELEMENTS; do
        asyncJob asyncRun "" ${method}
    done
    for method in $PROMPT_RIGHT_ELEMENTS; do
        asyncJob asyncRun "" ${method}
    done
}
