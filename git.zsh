source "properties"
source "color.zsh"

function git_branch() {
    branch=$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
    if [[ $branch ]]; then
        git_where="${branch/(refs\/heads|tags)\//}"
        colorize "${git_where}" $GIT_BRANCH_COLOR $GIT_BRANCH_BOLD
    fi
}

function git_diffs() {
    if [[ -z "$(git_branch)" ]]; then
        return
    fi

    if [[ $(git ls-files --other --exclude-standard :/ 2> /dev/null) ]] then
        local untracked=$(colorize "$GIT_DIFF_SYMBOL" $GIT_UNTRACKED_COLOR $GIT_UNTRACKED_BOLD)
        GIT_DIFFS="$untracked"
    fi

    if ! git diff --quiet 2> /dev/null; then
        local modified=$(colorize "$GIT_DIFF_SYMBOL" $GIT_MODIFIED_COLOR $GIT_MODIFIED_BOLD)
        GIT_DIFFS="$GIT_DIFFS$modified"
    fi

    if ! git diff --cached --quiet 2> /dev/null; then
        local staged=$(colorize "$GIT_DIFF_SYMBOL" $GIT_STAGED_COLOR $GIT_STAGED_BOLD)
        GIT_DIFFS="$GIT_DIFFS$staged"
    fi

    echo "$GIT_DIFFS"
}

function git_position() {
    if [[ -z "$(git_branch)" ]]; then
        return
    fi

    local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$NUM_AHEAD" -gt 0 ]; then
        local ahead=$(colorize "$GIT_AHEAD" $GIT_AHEAD_COLOR $GIT_AHEAD_BOLD)
        GIT_POSITION="${ahead//NUM/$NUM_AHEAD}"
    fi

    local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$NUM_BEHIND" -gt 0 ]; then
        local behind=$(colorize "$GIT_BEHIND" $GIT_BEHIND_COLOR $GIT_BEHIND_BOLD)
        GIT_POSITION="$GIT_POSITION ${behind//NUM/$NUM_BEHIND}"
    fi

    if ! git symbolic-ref HEAD >/dev/null 2>&1; then
        local detached=$(colorize "$GIT_DETATCHED" $GIT_DETATCHED_COLOR $GIT_DETATCHED_BOLD)
        GIT_POSITION="${detached}"
    fi

    echo "$GIT_POSITION"
}

function git_merging() {
    if [[ -z "$(git_branch)" ]]; then
        return
    fi

    local GIT_MERGE_DIR="$(git rev-parse --git-dir 2> /dev/null)/MERGE_HEAD"
    if [ -f $GIT_MERGE_DIR ]; then
        local merging=$(colorize "$GIT_MERGING" $GIT_MERGING_COLOR $GIT_MERGING_BOLD)
        echo "$merging"
    fi
}
