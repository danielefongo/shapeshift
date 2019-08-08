#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

typeset -gA created_lock
typeset -gA locked_lock
typeset -gA unlocked_lock

oneTimeSetUp() {
    source tests/mock.zsh
}

setUp() {
    source utils/async.zsh
    mock myJob echo job
    mock myCallback
    mock lock_create
    mock lock_lock
    mock lock_unlock
    mock lock_exists
}

tearDown() {
    sleep 0.5
}

# Tests

test_saves_job_pid() {
    async_job myJob myCallback
    local myPid=$__async_jobs["myJob"]

    assertNotNull "$myPid"
}

test_kills_previous_job_when_running_the_same_job_again() {
    sleepyJob() {sleep 0.5}

    async_job sleepyJob myCallback
    local oldPid=$__async_jobs["sleepyJob"]
    async_job sleepyJob myCallback
    local newPid=$__async_jobs["sleepyJob"]

    assertFalse "kill -0 $oldPid"
    assertNotEquals "$oldPid" "$newPid"
}

test_fails_to_do_async_job_when_not_initialized() {
    mock lock_exists return 1

    async_job myJob myCallback

    assertEquals "1" "$?"
}

test_calls_all_required_lock_methods() {
    async_init

    __async myJob myCallback
    sleep 0.5

    verify_mock_calls lock_create 2
    verify_mock_calls lock_lock 3
    verify_mock_calls lock_unlock 2
}

test_calls_async_handler_with_right_params() {
    local actual
    mock __async_handler zpty -r asynced actual
    trap '__async_handler' WINCH

    __async myJob myCallback &!
    sleep 0.5

    assertContains "$actual" "myCallback \"myJob\" \"0\" \"job\""
}

test_handler_calls_callback_properly() {
    async_init

    mock mockFunction assertEquals "output" "\$1"

    zpty -w asynced "mockFunction output"
    kill -s WINCH $$
}

# Utilities

assertContains() {
    local output=$(echo "$1" | grep "$2" | wc -l)
    assertTrue "[ $output -ge 1 ]"
}

# Run

source "shunit2/shunit2"