#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

setUp() {
    source segments/dir.zsh
}

tearDown() {
    unset SHAPESHIFT_DIR_LENGTH
}

# Tests

test_concatenates_truncated_dir_and_last_folder() {
    __prompt_last_folder() {echo "last";}
    __prompt_truncated_dir() {echo "/truncated/";}
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
    __prompt_last_folder() {echo "~";}
    __prompt_truncated_dir() {echo "/mypath/";}
    SHAPESHIFT_DIR_LENGTH=1

    actual=$(prompt_dir)

    assertEquals "~" "$actual"
}

test_does_not_show_truncated_dir_when_is_root() {
    __prompt_last_folder() {echo "/";}
    __prompt_truncated_dir() {echo "/";}
    SHAPESHIFT_DIR_LENGTH=1

    actual=$(prompt_dir)

    assertEquals "/" "$actual"
}

test_truncated_dir_utility_using_short_dir() {
    __prompt_dir_length=1

    __prompt_full_dir() {echo "%~"}
    __prompt_long_dir() {echo "3~"}
    __prompt_short_dir() {echo ".../foo/%1~"}

    actual=$(__prompt_truncated_dir)

    assertEquals ".../foo/" "$actual"
}

test_truncated_dir_utility_using_full_dir() {
    __prompt_dir_length=1

    __prompt_full_dir() {echo "%~"}
    __prompt_long_dir() {echo "2~"}
    __prompt_short_dir() {echo "~/foo/%1~"}

    actual=$(__prompt_truncated_dir)

    assertEquals "~/foo/" "$actual"
}

# Utilities

colorize() {
    print -n "$1"
}

# Run

source "shunit2/shunit2"