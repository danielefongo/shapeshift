#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

oneTimeSetUp() {
    source shapeshift.zsh
    source mockz/mockz.zsh
}

tearDown() {
    rockall
}

# Tests

test_renders_left_elements() {
    mock result_for do 'echo $1'
    local SHAPESHIFT_PROMPT_LEFT_ELEMENTS=(first second async_third)

    actual=$(__shapeshift_render_left)

    assertEquals "first second third " "$actual"
}

test_renders_right_elements() {
    mock result_for do 'echo $1'
    local SHAPESHIFT_PROMPT_RIGHT_ELEMENTS=(first second async_third)

    actual=$(__shapeshift_render_right)

    assertEquals " first second third" "$actual"
}

test_execs_elements() {
    mock exec_sync expect "first"
    mock exec_async expect "second"

    local elements=(first async_second)

    __shapeshift_exec_elements $elements
}

test_sets_color_ls_when_flag_is_enabled() {
    mock color_ls_set

    local SHAPESHIFT_LS_COLORS_ENABLED=true
    __shapeshift_ls_update

    mock color_ls_set called 1
}

test_unsets_color_ls_when_flag_is_disabled() {
    mock color_ls_unset

    local SHAPESHIFT_LS_COLORS_ENABLED=false
    __shapeshift_ls_update

    mock color_ls_unset called 1
}

# Run

source "shunit2/shunit2"