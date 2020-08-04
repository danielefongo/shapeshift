#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

oneTimeSetUp() {
    source mockz/mockz.zsh
    source segments/git.zsh

    git clone https://github.com/danielefongo/foo &>/dev/null

    SHAPESHIFT_GIT_DIFF_SYMBOL="o"
    SHAPESHIFT_GIT_UNTRACKED_COLOR="U"
    SHAPESHIFT_GIT_MODIFIED_COLOR="M"
    SHAPESHIFT_GIT_STAGED_COLOR="S"
    SHAPESHIFT_GIT_AHEAD="+ NUM"
    SHAPESHIFT_GIT_BEHIND="- NUM"
    SHAPESHIFT_GIT_DETATCHED="!"
    SHAPESHIFT_GIT_MERGING="x"

    mock colorize do 'echo "$1$2"'
}

setUp() {
    cd foo
}

tearDown() {
    git clean -xqfd &>/dev/null
    git reset . &>/dev/null
    git checkout . &>/dev/null
    git checkout master &>/dev/null
    sleep 1
    cd ..
}

oneTimeTearDown() {
    rm -rf foo
}

# Tests

test_git_diffs() {
    createOrModifyFile file1 text
    addFilesToGit file1
    createOrModifyFile file2 text
    createOrModifyFile file3

    local actual="$(git_diffs)"

    assertEquals "oUoMoS" "$actual"
}

test_git_position_diverged() {
    moveMasterToPreviousCommit
    createOrModifyFile file1 text
    addFilesToGit file1

    commit message

    local actual="$(git_position)"

    assertEquals "+1 -1" "$actual"
}

test_git_position_detatched() {
    moveHeadToPreviousCommit

    local actual="$(git_position)"

    assertEquals "!" "$actual"
}

test_git_position_merging() {
    goOnBranch dev

    git merge master &>/dev/null

    local actual="$(git_merging)"

    assertEquals "x" "$actual"
}

# Utilities

createOrModifyFile() {
    echo "$2" > "$1"
}

addFilesToGit() {
    git add $@ &>/dev/null
}

commit() {
    git commit -m "$1" &>/dev/null
}

moveMasterToPreviousCommit() {
    git reset HEAD~1 --hard &>/dev/null
}

moveHeadToPreviousCommit() {
    git checkout HEAD~1 &>/dev/null
}

goOnBranch() {
    git checkout $1 &>/dev/null
}

# Run

source "shunit2/shunit2"