#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

setUp() {
    __timers=()
    source utils/time.zsh
}

# Tests

test_not_existing_timer() {
    assertNull "$__timers"
}

test_creates_timer() {
    timer_start myTimer

    sleep 0.1
    assertNotNull "$__timers[\"myTimer\"]"
}

test_timer_is_equal_to_0_when_not_started() {
    local actual=$(timer_get)
    assertTrue "[ $actual -eq 0 ]"
}

test_timer_always_increases_his_value() {
    timer_start myTimer

    local initial_time=$(timer_get myTimer)
    sleep 0.1
    local final_time=$(timer_get myTimer)

    integer milliseconds
    (( milliseconds = final_time - initial_time ))
    assertTrue "[ $milliseconds -gt 0 ]"
}

test_timer_is_equal_to_0_when_stopped() {
    timer_start myTimer

    sleep 0.1
    timer_stop myTimer
    
    local actual=$(timer_get myTimer)
    assertTrue "[ $actual -eq 0 ]"
}

# Utilities

# Run

source "shunit2/shunit2"