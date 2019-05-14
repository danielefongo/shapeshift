source "properties"
source "color.zsh"

function async_git_branch() {
    branch=$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
    if [[ $branch ]]; then
        git_where="${branch/(refs\/heads|tags)\//}"
        colorize "${git_where}" $ZPURE_GIT_BRANCH_COLOR $ZPURE_GIT_BRANCH_BOLD
    fi
}

function async_git_diffs() {
    if [[ -z "$(async_git_branch)" ]]; then
        return
    fi

    if [[ $(git ls-files --other --exclude-standard :/ 2> /dev/null) ]] then
        local untracked=$(colorize "$ZPURE_GIT_DIFF_SYMBOL" $ZPURE_GIT_UNTRACKED_COLOR $ZPURE_GIT_UNTRACKED_BOLD)
        ZPURE_GIT_DIFFS="$untracked"
    fi

    if ! git diff --quiet 2> /dev/null; then
        local modified=$(colorize "$ZPURE_GIT_DIFF_SYMBOL" $ZPURE_GIT_MODIFIED_COLOR $ZPURE_GIT_MODIFIED_BOLD)
        ZPURE_GIT_DIFFS="$ZPURE_GIT_DIFFS$modified"
    fi

    if ! git diff --cached --quiet 2> /dev/null; then
        local staged=$(colorize "$ZPURE_GIT_DIFF_SYMBOL" $ZPURE_GIT_STAGED_COLOR $ZPURE_GIT_STAGED_BOLD)
        ZPURE_GIT_DIFFS="$ZPURE_GIT_DIFFS$staged"
    fi

    echo "$ZPURE_GIT_DIFFS"
}

function async_git_position() {
    if [[ -z "$(async_git_branch)" ]]; then
        return
    fi

    local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$NUM_AHEAD" -gt 0 ]; then
        local ahead=$(colorize "$ZPURE_GIT_AHEAD" $ZPURE_GIT_AHEAD_COLOR $ZPURE_GIT_AHEAD_BOLD)
        ZPURE_GIT_POSITION="${ahead//NUM/$NUM_AHEAD}"
    fi

    local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$NUM_BEHIND" -gt 0 ]; then
        local behind=$(colorize "$ZPURE_GIT_BEHIND" $ZPURE_GIT_BEHIND_COLOR $ZPURE_GIT_BEHIND_BOLD)
        if [[ $ZPURE_GIT_POSITION ]]; then
            $ZPURE_GIT_POSITION="$ZPURE_GIT_POSITION "
        fi
        ZPURE_GIT_POSITION="$ZPURE_GIT_POSITION${behind//NUM/$NUM_BEHIND}"
    fi

    if ! git symbolic-ref HEAD >/dev/null 2>&1; then
        local detached=$(colorize "$ZPURE_GIT_DETATCHED" $ZPURE_GIT_DETATCHED_COLOR $ZPURE_GIT_DETATCHED_BOLD)
        ZPURE_GIT_POSITION="${detached}"
    fi

    echo "$ZPURE_GIT_POSITION"
}

function async_git_merging() {
    if [[ -z "$(async_git_branch)" ]]; then
        return
    fi

    local ZPURE_GIT_MERGE_DIR="$(git rev-parse --git-dir 2> /dev/null)/MERGE_HEAD"
    if [ -f $ZPURE_GIT_MERGE_DIR ]; then
        local merging=$(colorize "$ZPURE_GIT_MERGING" $ZPURE_GIT_MERGING_COLOR $ZPURE_GIT_MERGING_BOLD)
        echo "$merging"
    fi
}
