#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

oneTimeSetUp() {
    source segments/time.zsh
    source mockz/mockz.zsh
}

setUp() {
    mock colorize do 'print -n $1'
}

tearDown() {
    rockall
}

# Tests

test_milliseconds() {
    mock timer_get do 'echo 1'

    actual=$(last_command_elapsed_time)

    assertEquals "1ms" "$actual"
}

test_seconds() {
    mock timer_get do 'echo 1000'

    actual=$(last_command_elapsed_time)

    assertEquals "1s" "$actual"
}

test_minutes() {
    mock timer_get do 'echo 60000'

    actual=$(last_command_elapsed_time)

    assertEquals "1m" "$actual"
}

test_hours() {
    mock timer_get do 'echo 3600000'

    actual=$(last_command_elapsed_time)

    assertEquals "1h" "$actual"
}

# Run

source "shunit2/shunit2"