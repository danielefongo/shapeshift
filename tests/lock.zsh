#!/usr/bin/env zsh

# Setup

locked_file="/tmp/foo"
setopt shwordsplit
SHUNIT_PARENT=$0

oneTimeSetUp() {  
    source utils/lock.zsh
}

oneTimeTearDown() {
    rm -f "$locked_file"
}

test_create_lock() {
    lock_create aBeautifulLock
    
    assertEquals "__lock__aBeautifulLock" "$__locks[\"aBeautifulLock\"]"
}

test_verify_lock_existence() {
    lock_create aBeautifulLock
    
    assertTrue "lock_exists aBeautifulLock"
}

test_lock_properly() {
    lock_create mylock

    writeToLockedFile first &!
    sleep 0.1
    writeToLockedFile second &!

    sleep 0.5
    assertEquals "$(cat $locked_file)" "first"

    sleep 0.5
    assertEquals "$(cat $locked_file)" "second"
}

# Utilities

writeToLockedFile() {
    lock_lock mylock

    echo $1 > $locked_file
    sleep 1

    lock_unlock mylock
}

# Run

source "shunit2/shunit2"