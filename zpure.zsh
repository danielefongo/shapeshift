setopt prompt_subst
autoload -U colors && colors

source "async.zsh"
source "git.zsh"
source "dir.zsh"

function prompt_dir_and_arrow() {
    echo "$(prompt_dir) $(prompt_arrow) "
}

# Prompt
function PCMD() {
    echo "$(prompt_dir_and_arrow)"
}

function RCMD() {
    echo "$(git_full)"
}

PROMPT='$(PCMD)' # single quotes to prevent immediate execution
RPROMPT='' # set asynchronously and dynamically

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
