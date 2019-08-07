#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

setUp() {
    source segments/time.zsh
}

# Tests

test_milliseconds() {
    timer_get() {echo "1"}

    actual=$(last_command_elapsed_time)

    assertEquals "1ms" "$actual"
}

test_seconds() {
    timer_get() {echo "1000"}

    actual=$(last_command_elapsed_time)

    assertEquals "1s" "$actual"
}

test_minutes() {
    timer_get() {echo "60000"}

    actual=$(last_command_elapsed_time)

    assertEquals "1m" "$actual"
}

test_hours() {
    timer_get() {echo "3600000"}

    actual=$(last_command_elapsed_time)

    assertEquals "1h" "$actual"
}

# Utilities

colorize() {echo "$1"}

# Run

source "shunit2/shunit2"