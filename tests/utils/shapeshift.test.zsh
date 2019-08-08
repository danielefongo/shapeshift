#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

oneTimeSetUp() {
    source tests/mock.zsh
}

setUp() {
  source shapeshift.zsh
}

# Tests

test_renders_left_elements() {
    mock result_for echo "\$1"
    local SHAPESHIFT_PROMPT_LEFT_ELEMENTS=(first second async_third)

    actual=$(__shapeshift_render_left)

    assertEquals "first second third " "$actual"
}

test_renders_right_elements() {
    mock result_for echo "\$1"
    local SHAPESHIFT_PROMPT_RIGHT_ELEMENTS=(first second async_third)

    actual=$(__shapeshift_render_right)

    assertEquals " first second third" "$actual"
}

test_execs_elements() {
    mock exec_sync assertEquals "first" "\$1"
    mock exec_async assertEquals "second" "\$1"

    local elements=(first async_second)

    __shapeshift_exec_elements $elements
}

test_sets_color_ls_when_flag_is_enabled() {
    mock color_ls_set

    local SHAPESHIFT_LS_COLORS_ENABLED=true
    __shapeshift_ls_update

    verify_mock_calls color_ls_set 1
}

test_unsets_color_ls_when_flag_is_disabled() {
    mock color_ls_unset

    local SHAPESHIFT_LS_COLORS_ENABLED=false
    __shapeshift_ls_update

    verify_mock_calls color_ls_unset 1
}

# Run

source "shunit2/shunit2"