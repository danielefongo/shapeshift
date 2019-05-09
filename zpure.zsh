source "async.zsh"

# Allow for variable/function substitution in prompt
setopt prompt_subst

# Load color variables to make it easier to color things
autoload -U colors && colors

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
PR_ARROW_CHAR=">"

# The arrow in red (for root) or violet (for regular user)
function PR_ARROW() {
  echo "%{$fg[green]%}%(?..%{$fg[red]%})%B${PR_ARROW_CHAR}%b%{$reset_color%}"
}

DIFF_SYMBOL="-"
GIT_PROMPT_PREFIX=" "
GIT_PROMPT_SUFFIX=""
GIT_PROMPT_AHEAD="%{$fg[cyan]%}%B+NUM%b%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[cyan]%}%B-NUM%b%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg[cyan]%}%Bx%b%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg[red]%}%B$DIFF_SYMBOL%b%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg[blue]%}%B$DIFF_SYMBOL%b%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg[green]%}%B$DIFF_SYMBOL%b%{$reset_color%}"
GIT_PROMPT_DETACHED="%{$fg[neon]%}%B!%b%{$reset_color%}"

function git_branch() {
    branch=$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
    echo ${branch/(refs\/heads|tags)\//}
}

function git_detached() {
    if ! git symbolic-ref HEAD >/dev/null 2>&1; then
        echo "Y"
    fi
}

function git_behind() {
    echo $(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')
}

function git_ahead() {
    echo $(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')
}

function git_untracked() {
    echo $(git ls-files --other --exclude-standard :/ 2> /dev/null)
}

function git_merge_dir() {
    echo "$(git rev-parse --git-dir 2> /dev/null)/MERGE_HEAD"
}

function git_modified() {
    if ! git diff --quiet 2> /dev/null; then
        echo "Y"
    fi
}

function git_staged() {
    if ! git diff --cached --quiet 2> /dev/null; then
        echo "Y"
    fi
}

function git_state() {
    local GIT_STATE=""

    local NUM_AHEAD="$(git_ahead)"
    if [ "$NUM_AHEAD" -gt 0 ]; then
        GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
    fi

    local NUM_BEHIND="$(git_behind)"
    if [ "$NUM_BEHIND" -gt 0 ]; then
        GIT_STATE="$GIT_STATE ${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}"
    fi

    local GIT_MERGE_DIR="$(git rev-parse --git-dir 2> /dev/null)"
    if [ -f $GIT_MERGE_DIR ]; then
      GIT_STATE="$GIT_STATE $GIT_PROMPT_MERGING"
    fi

    if [[ -n "$(git_untracked)" ]]; then
      GIT_DIFF=$GIT_PROMPT_UNTRACKED
    fi

    if [[ "$(git_modified)" ]]; then
      GIT_DIFF=$GIT_DIFF$GIT_PROMPT_MODIFIED
    fi

    if [[ "$(git_staged)" ]]; then
      GIT_DIFF=$GIT_DIFF$GIT_PROMPT_STAGED
    fi

    if [[ -n $GIT_STATE && -n $GIT_DIFF ]]; then
      GIT_STATE="$GIT_STATE "
    fi
    GIT_STATE="$GIT_STATE$GIT_DIFF"

    if [[ -n $GIT_STATE ]]; then
      echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
    fi
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
