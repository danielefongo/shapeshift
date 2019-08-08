#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

oneTimeSetUp() {
    __shapeshift_path="$(pwd)"
    source tests/mock.zsh
}

setUp() {
    source utils/theme.zsh

    mkdir foo
    cd foo
    __shapeshift_config_dir="."
    __shapeshift_theme_name="theme"
    __shapeshift_default_file="default"
}

tearDown() {
    cd ..
    rm -rf foo
}

# Tests

test_shift_to_default_when_no_repo_is_provided() {
    mock __shapeshift_delete_default
    mock __shapeshift_load

    shape-shift

    verify_mock_calls __shapeshift_delete_default 1
}

test_shift_does_not_load_when_something_breaks_during_setting_up() {
    mock __shapeshift_unique_theme return 1
    mock __shapeshift_load

    shape-shift invalid

    verify_mock_calls __shapeshift_load 0
}

test_shift_loads_existing_repo() {
    mock __shapeshift_unique_theme
    mock __shapeshift_import
    mock __shapeshift_set
    mock __shapeshift_load

    shape-shift invalid

    verify_mock_calls __shapeshift_load 1
}

test_reshape_updates_theme() {
    mock __shapeshift_themes echo "theme"
    mock __shapeshift_update assertEquals "theme" "\$1"
    mock __shapeshift_load

    shape-reshape
}

# Utility Functions Tests

test_load_utility_loads_theme_properly() {
    mock reset_results

    createExistingTheme
    echo "user/existingTheme" > "$__shapeshift_default_file"

    __shapeshift_load

    assertTrue "$SOURCED"
    verify_mock_calls reset_results 1
}

test_set_utility_handles_invalid_theme() {
    createWrongTheme

    local actual=$(__shapeshift_set "user/wrongTheme")

    assertEquals "Not a valid theme" "$actual"
}

test_set_utility_updates_default_file() {
    createExistingTheme

    __shapeshift_set "user/existingTheme"

    assertTrue "[ -f $__shapeshift_default_file ]"
}

test_import_utility_imports_valid_repo() {
    mock git createExistingTheme

    local actual=$(__shapeshift_import user/existingTheme)

    assertEquals "Theme user/existingTheme imported" "$actual"
}

test_import_utility_does_not_import_already_present_repo() {
    createExistingTheme

    local actual=$(__shapeshift_import user/existingTheme)

    assertNull "$actual"
}

test_import_utility_handles_not_existing_repo() {
    mock git return 1

    local actual=$(__shapeshift_import any)

    assertEquals "Not a valid repo" "$actual"
}

test_import_utility_handles_invalid_repo() {
    mock git createWrongTheme

    local actual=$(__shapeshift_import any)

    assertEquals "Not a valid theme" "$actual"
}

test_themes_utility_gives_themes_list() {
    createExistingTheme
    createAnotherExistingTheme

    local actual=$(__shapeshift_themes)

    assertContains "$actual" "user/existingTheme"
    assertContains "$actual" "user2/existingTheme"
}

test_unique_theme_utility_gives_unique_theme() {
    mock __shapeshift_themes echo user/existingTheme

    local repo=""
    __shapeshift_unique_theme existingTheme

    assertEquals "user/existingTheme" "$repo"
}

test_unique_theme_utility_does_not_set_repo_if_it_not_exist() {
    mock __shapeshift_themes
    local repo=""

    __shapeshift_unique_theme aTheme

    assertNull "$repo"
}

test_unique_theme_utility_gives_list_of_duplicated_names() {
    mock __shapeshift_themes "
        echo user/existingTheme
        echo user2/existingTheme
    "

    local actual=$(__shapeshift_unique_theme existingTheme)

    assertContains "$actual" "duplicated, use one of the following"
    assertContains "$actual" "user/existingTheme"
    assertContains "$actual" "user2/existingTheme"
}

test_update_utility_updates_theme() {
    mock git "case \$1 in
                rev-parse ) echo "\$2" ;;
                merge-base ) echo "@" ;;
                * ) ;;
            esac"

    createExistingTheme

    local actual=$(__shapeshift_update user/existingTheme)

    assertEquals "user/existingTheme updated." "$actual"
}

test_suggestions_utility_gives_full_repo_names_if_theme_names_are_not_unique() {
    mock __shapeshift_themes "
        echo user/theme
        echo user2/theme
    "

    local actual=$(__shapeshift_theme_suggestions)

    assertEquals "user/theme user2/theme" "$actual"
}

test_suggestions_utility_gives_partial_repo_names_if_theme_names_are_unique() {
    mock __shapeshift_themes "
        echo user/theme
        echo user2/differentTheme
    "

    local actual=$(__shapeshift_theme_suggestions)

    assertEquals "theme differentTheme" "$actual"
}
# Utilities

assertContains() {
    local output=$(echo "$1" | grep "$2" | wc -l)
    assertTrue "[ $output -ge 1 ]"
}

createExistingTheme() {
    mkdir -p "user/existingTheme"
    echo "SOURCED=true" > "user/existingTheme/$__shapeshift_theme_name"
}

createAnotherExistingTheme() {
    mkdir -p "user2/existingTheme"
    touch "user2/existingTheme/$__shapeshift_theme_name"
}

createWrongTheme() {
    mkdir -p "user/wrongTheme"
    touch "user/wrongTheme/wrongName"
}

# Run

source "shunit2/shunit2"