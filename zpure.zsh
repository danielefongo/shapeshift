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
    for method in $PROMPT_RIGHT_ELEMENTS; do
        methodOutput=$(eval "$method")
        if [[ $methodOutput ]]; then
          FULL="$FULL $methodOutput"
        fi
    done
    echo "${FULL}"
}

PROMPT='$(PCMD)'
RPROMPT=''

function TRAPUSR1() {
    RPROMPT=$(cat < /tmp/pure)
    zle && zle reset-prompt
}

function asyncRun() {
    echo "$(RCMD)"
}

function asyncCallback() {
    echo "$2" > /tmp/pure
}

function precmd() {
    asyncJob asyncRun asyncCallback
}
