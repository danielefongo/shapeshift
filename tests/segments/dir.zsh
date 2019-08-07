#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

setUp() {
    source utils/color.zsh
    source segments/dir.zsh
}

tearDown() {
    unset SHAPESHIFT_LAST_FOLDER_DIR_COLOR
    unset SHAPESHIFT_LAST_FOLDER_DIR_BOLD
    unset SHAPESHIFT_TRUNCATED_DIR_COLOR
    unset SHAPESHIFT_TRUNCATED_DIR_BOLD
    unset SHAPESHIFT_DIR_LENGTH
}

# Tests

test_prompt_dir_with_colors_and_bold() {
    SHAPESHIFT_LAST_FOLDER_DIR_COLOR=yellow
    SHAPESHIFT_LAST_FOLDER_DIR_BOLD=true
    SHAPESHIFT_TRUNCATED_DIR_COLOR=red
    SHAPESHIFT_TRUNCATED_DIR_BOLD=true
    SHAPESHIFT_DIR_LENGTH=1
    actual=$(prompt_dir)

    assertEquals "%F{red}%B.../%b%f%F{yellow}%Bshapeshift%b%f" "$actual"
}

test_prompt_dir_full_length() {
    mkdir -p "foo/foo/foo/foo/foooo"
    cd "foo/foo/foo/foo/foooo"

    SHAPESHIFT_DIR_LENGTH=100
    
    actual=$(prompt_dir)

    full=$(print -P "%~")
    last=$(print -P "%1~")
    base=${full//${last}/}

    assertEquals "%F{}$base%f%F{}$last%f" "$actual"

    cd -
    rm -rf "foo"
}

test_prompt_dir_length_1() {
    SHAPESHIFT_DIR_LENGTH=1
    actual=$(prompt_dir)

    assertEquals "%F{}.../%f%F{}shapeshift%f" "$actual"
}

test_prompt_dir_length_0() {
    SHAPESHIFT_DIR_LENGTH=0
    actual=$(prompt_dir)

    assertNull "$actual"
}

test_prompt_dir_home_dir() {
    cd $HOME

    SHAPESHIFT_DIR_LENGTH=1

    actual=$(prompt_dir)

    assertEquals "%F{}~%f" "$actual"

    cd -
}

test_prompt_dir_root_dir() {
    SHAPESHIFT_DIR_LENGTH=1

    cd /
    a=$(prompt_dir)
    cd -

    assertEquals "%F{}/%f" "$a"
}

# Run

source "shunit2/shunit2"