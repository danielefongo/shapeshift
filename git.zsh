DIFF_SYMBOL="-"
GIT_PROMPT_AHEAD="%{$fg[cyan]%}%B+NUM%b%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[cyan]%}%B-NUM%b%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg[cyan]%}%Bx%b%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg[red]%}%B$DIFF_SYMBOL%b%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg[blue]%}%B$DIFF_SYMBOL%b%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg[green]%}%B$DIFF_SYMBOL%b%{$reset_color%}"
GIT_PROMPT_DETACHED="%{$fg[neon]%}%B!%b%{$reset_color%}"

function git_branch() {
    branch=$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
    if [[ $branch ]]; then
        git_where="${branch/(refs\/heads|tags)\//}"
        echo "%{$fg[white]%}%B${git_where}%b"
    fi
}

function git_diffs() {
    if [[ $(git ls-files --other --exclude-standard :/ 2> /dev/null) ]] then
        GIT_DIFFS=$GIT_PROMPT_UNTRACKED
    fi

    if ! git diff --quiet 2> /dev/null; then
        GIT_DIFFS=$GIT_DIFFS$GIT_PROMPT_MODIFIED
    fi

    if ! git diff --cached --quiet 2> /dev/null; then
        GIT_DIFFS=$GIT_DIFFS$GIT_PROMPT_STAGED
    fi

    if [[ $GIT_DIFFS ]]; then
        echo "$GIT_DIFFS "
    fi
}

function git_position() {
    local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$NUM_AHEAD" -gt 0 ]; then
        GIT_POSITION=$GIT_POSITION${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
    fi

    local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$NUM_BEHIND" -gt 0 ]; then
        GIT_POSITION="$GIT_POSITION ${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}"
    fi

    if ! git symbolic-ref HEAD >/dev/null 2>&1; then
        local GIT_POSITION="${GIT_PROMPT_DETACHED}"
    fi

    if [[ $GIT_POSITION ]]; then
        echo "$GIT_POSITION "
    fi
}

function git_merging() {
    local GIT_MERGE_DIR="$(git rev-parse --git-dir 2> /dev/null)/MERGE_HEAD"
    if [ -f $GIT_MERGE_DIR ]; then
      echo "$GIT_PROMPT_MERGING "
    fi
}

function git_full() {
    local branch="$(git_branch)"
    if [[ $branch ]]; then
        echo "$(git_position)$(git_merging)$(git_diffs)$(git_branch)"
    fi
}
