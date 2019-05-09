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
    if [[ $(git ls-files --other --exclude-standard :/ 2> /dev/null) ]] then
      echo "Y"
    fi
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

    local GIT_MERGE_DIR="$(git_merge_dir)"
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
