setopt prompt_subst
autoload -U colors && colors

source "async.zsh"
source "git.zsh"

# Current directory, truncated to 3 path elements (or 4 when one of them is "~")
# The number of elements to keep can be specified as ${1}
function PR_DIR() {
    local sub=${1}
    if [[ "${sub}" == "" ]]; then
        sub=3
    fi
    local len="$(expr ${sub} + 1)"
    local full="$(print -P "%d")"
    local relfull="$(print -P "%~")"
    local shorter="$(print -P "%${len}~")"
    local current="$(print -P "%${len}(~:.../:)%${sub}~")"
    local last="$(print -P "%1~")"

    PROMPT_DIRTRIM=1
    # Longer path for '~/...'
    if [[ "${shorter}" == \~/* ]]; then
        current=${shorter}
    fi

    local truncated="$(echo "${current%/*}/")"

    # Handle special case of directory '/' or '~something'
    if [[ "${truncated}" == "/" || "${relfull[1,-2]}" != */* ]]; then
        truncated=""
    fi

    # Handle special case of last being '/...' one directory down
    if [[ "${full[2,-1]}" != "" && "${full[2,-1]}" != */* ]]; then
        truncated="/"
        last=${last[2,-1]} # take substring
    fi

    echo "%{$fg[blue]%}${truncated}%B${last}%b%{$reset_color%}"
}

# The arrow symbol that is used in the prompt
PR_ARROW_CHAR="❯"

# The arrow in red (for root) or violet (for regular user)
function PR_ARROW() {
  echo "%{$fg[green]%}%(?..%{$fg[red]%})%B${PR_ARROW_CHAR}%b%{$reset_color%}"
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
    echo "$(PR_DIR) $(PR_ARROW) "
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
