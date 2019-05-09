setopt prompt_subst
autoload -U colors && colors

source "async.zsh"
source "git.zsh"
source "dir.zsh"

function prompt_dir_and_arrow() {
    echo "$(prompt_dir) $(prompt_arrow) "
}

function git_prompt_string() {
    local git_where="$(git_branch)"
    if [[ $(git_detached) ]]; then
        local git_detached="${GIT_PROMPT_DETACHED}"
    fi
    [ -n "$git_where" ] && echo " $(git_state)$GIT_PROMPT_PREFIX%{$fg[white]%}%B${git_where}%b$git_detached$GIT_PROMPT_SUFFIX"
}

# Prompt
function PCMD() {
    echo "$(prompt_dir_and_arrow)"
}

function RCMD() {
    echo "$(git_prompt_string)"
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
