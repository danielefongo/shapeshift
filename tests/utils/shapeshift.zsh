#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

setUp() {  
  source shapeshift.zsh
}

# Tests

test_renders_left_elements() {
    result_for() {echo $1}
    local SHAPESHIFT_PROMPT_LEFT_ELEMENTS=(first second async_third)

    actual=$(__shapeshift_render_left)

    assertEquals "first second third " "$actual"
}

test_renders_right_elements() {
    result_for() {echo $1}
    local SHAPESHIFT_PROMPT_RIGHT_ELEMENTS=(first second async_third)

    actual=$(__shapeshift_render_right)

    assertEquals " first second third" "$actual"
}

test_execs_elements() {
    local asyncMethodsCalled=""
    local syncMethodsCalled=""
    exec_async() {asyncMethodsCalled+="$1 ";}
    exec_sync() {syncMethodsCalled+="$1 ";}
    
    local elements=(first second async_third)

    __shapeshift_exec_elements $elements

    assertEquals "first second " "$syncMethodsCalled"
    assertEquals "third " "$asyncMethodsCalled"
}

test_sets_color_ls_when_flag_is_enabled() {
    local called=false
    color_ls_set() {called=true;}

    local SHAPESHIFT_LS_COLORS_ENABLED=true
    __shapeshift_ls_update

    assertTrue "$called"
}

test_unsets_color_ls_when_flag_is_disabled() {
    local called=false
    color_ls_unset() {called=true;}

    local SHAPESHIFT_LS_COLORS_ENABLED=false
    __shapeshift_ls_update

    assertTrue "$called"
}

# Run

source "shunit2/shunit2"