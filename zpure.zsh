setopt prompt_subst
autoload -U colors && colors

source "async.zsh"
source "git.zsh"
source "dir.zsh"

function RIGHTCMD() {
    local FULL=""
    local async=$1
    for method in $PROMPT_RIGHT_ELEMENTS; do
        local methodOutput=""
        if [[ ! $method =~ "^async" ]]; then
          methodOutput=$(eval "$method")
        elif [[ -f "/tmp/${method}" && $async == true ]]; then
          methodOutput=$(cat < "/tmp/${method}")
        fi
        if [[ $methodOutput ]]; then
          FULL="$FULL $methodOutput"
        fi
    done
    echo "${FULL}"
}

function LEFTCMD() {
    local FULL=""
    local async=$1
    for method in $PROMPT_LEFT_ELEMENTS; do
        local methodOutput=""
        if [[ ! $method =~ "^async" ]]; then
          methodOutput=$(eval "$method")
        elif [[ -f "/tmp/${method}" && $async == true ]]; then
          methodOutput=$(cat < "/tmp/${method}")
        fi
        if [[ $methodOutput ]]; then
          FULL="$FULL$methodOutput "
        fi
    done
    echo "${FULL}"
}

function updatePrompt() {
    local async=$1
    RPROMPT="$(RIGHTCMD $async)"
    PROMPT="$(LEFTCMD $async)"
    zle && zle reset-prompt
}

function TRAPUSR1() {
    updatePrompt true
}

function asyncRun() {
    method="${1}"
    eval "$method" > "/tmp/$method"
}

function precmd() {
    updatePrompt false
    for method in $PROMPT_LEFT_ELEMENTS; do
        if [[ $method =~ "^async" ]]; then
            asyncJob asyncRun "" ${method}
        fi
    done
    for method in $PROMPT_RIGHT_ELEMENTS; do
        if [[ $method =~ "^async" ]]; then
            asyncJob asyncRun "" ${method}
        fi
    done
}
