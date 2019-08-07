function git_branch() {
    [ __is_git_folder ] || return
    branch=$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
    colorize "${branch/(refs\/heads|tags)\//}" "$SHAPESHIFT_GIT_BRANCH_COLOR" "$SHAPESHIFT_GIT_BRANCH_BOLD"
}

function git_diffs() {
    [ $(git_branch) ] || return

    local diffs
    diffs+="$(git_diffs_untracked)"
    diffs+="$(git_diffs_modified)"
    diffs+="$(git_diffs_added)"

    print -n "$diffs"
}

function git_position() {
    [ $(git_branch) ] || return

    local position=""

    __git_position_append $(git_position_ahead)
    __git_position_append $(git_position_behind)
    __git_position_append $(git_position_detached)

    print -n $position
}

function git_diffs_untracked() {
    [ $(git_branch) ] || return

    if [[ $(git ls-files --other --exclude-standard :/ 2> /dev/null) ]] then
        colorize "$SHAPESHIFT_GIT_DIFF_SYMBOL" "$SHAPESHIFT_GIT_UNTRACKED_COLOR" "$SHAPESHIFT_GIT_UNTRACKED_BOLD"
    fi
}

function git_diffs_modified() {
    [ $(git_branch) ] || return

    if ! git diff --quiet 2> /dev/null; then
        colorize "$SHAPESHIFT_GIT_DIFF_SYMBOL" "$SHAPESHIFT_GIT_MODIFIED_COLOR" "$SHAPESHIFT_GIT_MODIFIED_BOLD"
    fi
}

function git_diffs_added() {
    [ $(git_branch) ] || return

    if ! git diff --cached --quiet 2> /dev/null; then
        colorize "$SHAPESHIFT_GIT_DIFF_SYMBOL" "$SHAPESHIFT_GIT_STAGED_COLOR" "$SHAPESHIFT_GIT_STAGED_BOLD"
    fi
}

function git_position_detached() {
    [ $(git_branch) ] || return

    if ! git symbolic-ref HEAD >/dev/null 2>&1; then
        colorize "$SHAPESHIFT_GIT_DETATCHED" "$SHAPESHIFT_GIT_DETATCHED_COLOR" "$SHAPESHIFT_GIT_DETATCHED_BOLD"
    fi
}

function git_position_ahead() {
    [ $(git_branch) ] || return

    local num_ahead="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$num_ahead" -gt 0 ]; then
        local ahead="${SHAPESHIFT_GIT_AHEAD//NUM/$num_ahead}"
        colorize "$ahead" "$SHAPESHIFT_GIT_AHEAD_COLOR" "$SHAPESHIFT_GIT_AHEAD_BOLD"
    fi
}

function git_position_behind() {
    [ $(git_branch) ] || return

    local num_behind="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$num_behind" -gt 0 ]; then
        local behind="${SHAPESHIFT_GIT_BEHIND//NUM/$num_behind}"
        colorize "$behind" "$SHAPESHIFT_GIT_BEHIND_COLOR" "$SHAPESHIFT_GIT_BEHIND_BOLD"
    fi
}

function git_merging() {
    [ $(git_branch) ] || return

    local merge_dir="$(git rev-parse --git-dir 2> /dev/null)/MERGE_HEAD"
    if [ -f $merge_dir ]; then
        colorize "$SHAPESHIFT_GIT_MERGING" "$SHAPESHIFT_GIT_MERGING_COLOR" "$SHAPESHIFT_GIT_MERGING_BOLD"
    fi
}

function __git_position_append() {
    section=$1
    if [ $section ]; then
        [ $position ] && position+=" "
        position+="$section"
    fi
}

function __is_git_folder() {
    git status -s &>/dev/null
    return $?
}