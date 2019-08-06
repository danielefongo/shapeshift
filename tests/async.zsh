#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

typeset -gA created_lock
typeset -gA locked_lock
typeset -gA unlocked_lock

setUp() {
    source utils/async.zsh
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
    assertNotEquals "$newPid" "$oldPid"
}

test_fails_to_do_async_job_when_not_initialized() {
    lock_exists() {return 1}

    async_job myJob myCallback

    assertEquals "1" "$?"
}

test_calls_all_required_lock_methods() {
    async_init

    __async myJob myCallback
    sleep 0.5

    assertTrue "[ $created_lock[\"async\"] ]"
    assertTrue "[ $created_lock[\"handler\"] ]"
    assertTrue "[ $locked_lock[\"async\"] ]"
    assertTrue "[ $locked_lock[\"handler\"] ]"
    assertTrue "[ $unlocked_lock[\"async\"] ]"
    assertTrue "[ $unlocked_lock[\"handler\"] ]"
}

test_calls_async_handler_with_right_params() {
    local actual
    spyHandler() {
        zpty -r asynced actual
    }
    trap 'spyHandler' WINCH

    __async myJob myCallback &!
    sleep 0.5

    assertContains "$actual" "myCallback \"myJob\" \"0\" \"job\""
}

test_handler_calls_callback_properly() {
    local actual
    local expected="output"
    mockFunction() {
        actual=$1
    }
    trap '__async_handler' WINCH

    zpty -w asynced "mockFunction $expected"
    kill -s WINCH $$

    sleep 0.5

    assertEquals "$expected" "$actual"
}

# Utilities

assertContains() {
    local output=$(echo "$1" | grep "$2" | wc -l | bc)
    assertTrue "[ $output -ge 1 ]"
}

myJob() {
    echo "job"
}

myCallback() {
}

lock_create() {
    created_lock["$1"]=true
}

lock_lock() {
    locked_lock["$1"]=true
}

lock_unlock() {
    unlocked_lock["$1"]=true
}

lock_exists() {
    return 0
}

lock_destroy() {;}

# Run

source "shunit2/shunit2"