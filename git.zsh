function async_git_branch() {
    branch=$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
    if [[ $branch ]]; then
        git_where="${branch/(refs\/heads|tags)\//}"
        colorize "${git_where}" $SHAPESHIFT_GIT_BRANCH_COLOR $SHAPESHIFT_GIT_BRANCH_BOLD
    fi
}

function async_git_diffs() {
    if [[ -z "$(async_git_branch)" ]]; then
        return
    fi

    if [[ $(git ls-files --other --exclude-standard :/ 2> /dev/null) ]] then
        local untracked=$(colorize "$SHAPESHIFT_GIT_DIFF_SYMBOL" $SHAPESHIFT_GIT_UNTRACKED_COLOR $SHAPESHIFT_GIT_UNTRACKED_BOLD)
        SHAPESHIFT_GIT_DIFFS="$untracked"
    fi

    if ! git diff --quiet 2> /dev/null; then
        local modified=$(colorize "$SHAPESHIFT_GIT_DIFF_SYMBOL" $SHAPESHIFT_GIT_MODIFIED_COLOR $SHAPESHIFT_GIT_MODIFIED_BOLD)
        SHAPESHIFT_GIT_DIFFS="$SHAPESHIFT_GIT_DIFFS$modified"
    fi

    if ! git diff --cached --quiet 2> /dev/null; then
        local staged=$(colorize "$SHAPESHIFT_GIT_DIFF_SYMBOL" $SHAPESHIFT_GIT_STAGED_COLOR $SHAPESHIFT_GIT_STAGED_BOLD)
        SHAPESHIFT_GIT_DIFFS="$SHAPESHIFT_GIT_DIFFS$staged"
    fi

    echo "$SHAPESHIFT_GIT_DIFFS"
}

function async_git_position() {
    if [[ -z "$(async_git_branch)" ]]; then
        return
    fi

    local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$NUM_AHEAD" -gt 0 ]; then
        local ahead=$(colorize "$SHAPESHIFT_GIT_AHEAD" $SHAPESHIFT_GIT_AHEAD_COLOR $SHAPESHIFT_GIT_AHEAD_BOLD)
        SHAPESHIFT_GIT_POSITION="${ahead//NUM/$NUM_AHEAD}"
    fi

    local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$NUM_BEHIND" -gt 0 ]; then
        local behind=$(colorize "$SHAPESHIFT_GIT_BEHIND" $SHAPESHIFT_GIT_BEHIND_COLOR $SHAPESHIFT_GIT_BEHIND_BOLD)
        if [[ $SHAPESHIFT_GIT_POSITION ]]; then
            SHAPESHIFT_GIT_POSITION="$SHAPESHIFT_GIT_POSITION "
        fi
        SHAPESHIFT_GIT_POSITION="$SHAPESHIFT_GIT_POSITION${behind//NUM/$NUM_BEHIND}"
    fi

    if ! git symbolic-ref HEAD >/dev/null 2>&1; then
        local detached=$(colorize "$SHAPESHIFT_GIT_DETATCHED" $SHAPESHIFT_GIT_DETATCHED_COLOR $SHAPESHIFT_GIT_DETATCHED_BOLD)
        SHAPESHIFT_GIT_POSITION="${detached}"
    fi

    echo "$SHAPESHIFT_GIT_POSITION"
}

function async_git_merging() {
    if [[ -z "$(async_git_branch)" ]]; then
        return
    fi

    local SHAPESHIFT_GIT_MERGE_DIR="$(git rev-parse --git-dir 2> /dev/null)/MERGE_HEAD"
    if [ -f $SHAPESHIFT_GIT_MERGE_DIR ]; then
        local merging=$(colorize "$SHAPESHIFT_GIT_MERGING" $SHAPESHIFT_GIT_MERGING_COLOR $SHAPESHIFT_GIT_MERGING_BOLD)
        echo "$merging"
    fi
}
