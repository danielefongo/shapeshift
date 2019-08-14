#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

typeset -gA created_lock
typeset -gA locked_lock
typeset -gA unlocked_lock

oneTimeSetUp() {
    source utils/async.zsh
    source mockz/mockz.zsh
}

setUp() {
    mock myJob do 'echo job'
    mock myCallback
    mock lock_create
    mock lock_lock
    mock lock_unlock
    mock lock_exists
}

tearDown() {
    sleep 0.5
    rockall
}

# Tests

test_saves_job_pid() {
    async_job myJob myCallback
    local myPid=$__async_jobs["myJob"]

    assertNotNull "$myPid"
}

test_kills_previous_job_when_running_the_same_job_again() {
    sleepyJob() {sleep 1}

    async_job sleepyJob myCallback
    local oldPid=$__async_jobs["sleepyJob"]
    async_job sleepyJob myCallback
    local newPid=$__async_jobs["sleepyJob"]

    assertFalse "kill -0 $oldPid"
    assertNotEquals "$oldPid" "$newPid"
}

test_fails_to_do_async_job_when_not_initialized() {
    mock lock_exists do 'return 1'

    async_job myJob myCallback

    assertEquals "1" "$?"
}

test_calls_all_required_lock_methods() {
    async_init

    __async myJob myCallback
    sleep 0.5

    mock lock_create called 2
    mock lock_lock called 3
    mock lock_unlock called 2
}

test_calls_async_handler_with_right_params() {
    mock zpty expect '-w asynced myCallback "myJob" "0" "job"'
    mock kill
    
    __async myJob myCallback
    
    sleep 0.5
}

test_handler_calls_callback_properly() {
    async_init

    mock mockFunction expect "output"

    zpty -w asynced "mockFunction output"
    __async_handler
}

test_concurrent_jobs() {
    function myJob_1() {echo "line"}
    function myJob_2() {echo "line"}
    function myJob_3() {echo "line"}
    function myJob_4() {echo "line"}
    function myJob_5() {echo "line"}
    function myJob_6() {echo "line"}
    function myJob_7() {echo "line"}
    function myJob_8() {echo "line"}
    function myJob_9() {echo "line"}
    function myJob_10() {echo "line"}
    function myCallback() {echo "something" >> tmpfile}
    
    rm -f tmpfile
    for i in $(seq 1 10); do
        async_job myJob_$i myCallback
    done

    sleep 5

    local actual=$(cat tmpfile | wc -l | bc)

    assertEquals "10" "$actual"
    rm -f tmpfile
}

# Utilities

assertContains() {
    local output=$(echo "$1" | grep "$2" | wc -l)
    assertTrue "[ $output -ge 1 ]"
}

# Run

source "shunit2/shunit2"