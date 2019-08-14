#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

oneTimeSetUp() {
    source segments/dir.zsh
    source mockz/mockz.zsh
}

setUp() {
    mock colorize do 'print -n $1'
}

tearDown() {
    unset SHAPESHIFT_DIR_LENGTH
    rockall
}

# Tests

test_concatenates_truncated_dir_and_last_folder() {
    mock __prompt_last_folder do 'echo last'
    mock __prompt_truncated_dir do 'echo /truncated/'

    SHAPESHIFT_DIR_LENGTH=1

    actual=$(prompt_dir)

    assertEquals "/truncated/last" "$actual"
}

test_shows_empty_dir_when_length_is_zero() {
    SHAPESHIFT_DIR_LENGTH=0

    actual=$(prompt_dir)

    assertNull "$actual"
}

test_does_not_show_truncated_dir_when_is_home() {
    mock __prompt_last_folder do 'echo \~'
    mock __prompt_truncated_dir do 'echo /mypath/'
    SHAPESHIFT_DIR_LENGTH=1

    actual=$(prompt_dir)

    assertEquals "~" "$actual"
}

test_does_not_show_truncated_dir_when_is_root() {
    mock __prompt_last_folder do 'echo /'
    mock __prompt_truncated_dir do 'echo /'
    SHAPESHIFT_DIR_LENGTH=1

    actual=$(prompt_dir)

    assertEquals "/" "$actual"
}

test_truncated_dir_utility_using_short_dir() {
    mock __prompt_full_dir do 'echo %~'
    mock __prompt_long_dir do 'echo 3~'
    mock __prompt_short_dir do 'echo .../foo/%1~'
    __prompt_dir_length=1

    actual=$(__prompt_truncated_dir)

    assertEquals ".../foo/" "$actual"
}

test_truncated_dir_utility_using_full_dir() {
    mock __prompt_full_dir do 'echo %~'
    mock __prompt_long_dir do 'echo 2~'
    mock __prompt_short_dir do 'echo \~/foo/%1~'
    __prompt_dir_length=1

    actual=$(__prompt_truncated_dir)

    assertEquals "~/foo/" "$actual"
}

# Run

source "shunit2/shunit2"