#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

oneTimeSetUp() {
    __shapeshift_path="$(pwd)"
}

setUp() {
    source utils/theme.zsh

    mkdir -p foo
    __shapeshift_config_dir="./foo"
    __shapeshift_theme_name="theme"
    __shapeshift_default_file="./foo/default"
}

tearDown() {
    rm -rf foo
}

# Tests

test_shift_to_default_when_no_repo_is_provided() {
    __shapeshift_load() {;}
    setTheme randomTheme

    shape-shift

    assertTrue "[ ! -f $__shapeshift_default_file ]"
}

test_shift_does_not_load_when_not_existing_repo_is_provided() {
    __shapeshift_load() {fail;}
    __shapeshift_unique_theme() {return 1;}

    shape-shift invalid 1>/dev/null
}

test_shift_loads_existing_repo() {
    local loadCalled
    __shapeshift_load() {loadCalled=true;}
    __shapeshift_set() {;}
    __shapeshift_import() {fail;}

    createExistingTheme

    shape-shift existingTheme 1>/dev/null
    assertTrue "$loadCalled"
}

test_shift_imports_valid_repo() {
    local importCalled
    local setCalled
    __shapeshift_load() {;}
    __shapeshift_import() {importCalled=true;}
    __shapeshift_set() {setCalled=true;}

    shape-shift newTheme 1>/dev/null

    assertTrue "$importCalled"
    assertTrue "$setCalled"
}

test_destroy_removes_valid_repo() {
    __shapeshift_load() {fail;}
    createExistingTheme

    shape-destroy "existingTheme" 1>/dev/null

    assertTrue "[ ! -d $__shapeshift_config_dir/user/existingTheme ]"
}

test_destroy_removes_actually_set_repo() {
    local loadCalled;
    __shapeshift_load() {loadCalled=true;}
    createExistingTheme
    setTheme "user/existingTheme"

    shape-destroy "user/existingTheme" 1>/dev/null

    assertTrue "[ ! -f $__shapeshift_default_file ]"
    assertTrue "$loadCalled"
}

test_destroy_does_nothing_if_repo_is_not_provided() {
    __shapeshift_load() {fail;}

    shape-destroy 1>/dev/null
}

test_destroy_does_nothing_if_repo_is_not_valid() {
    __shapeshift_load() {fail;}
    __shapeshift_unique_theme() {return 1;}

    shape-destroy 1>/dev/null
}

test_reshape_updates_theme() {
    local git() {
        case $1 in
            rev-parse ) echo "$2" ;;
            merge-base ) echo "@" ;;
            * ) ;;
        esac
    }
    __shapeshift_load() {;}

    createExistingTheme

    local actual=$(shape-reshape)

    assertEquals "user/existingTheme updated." "$actual"
}

test_set_utility_handles_invalid_theme() {
    createWrongTheme

    local actual=$(__shapeshift_set "user/wrongTheme")

    assertEquals "Not a valid theme" "$actual"
}

test_load_utility_loads_theme_properly() {
    reset_results() {;}

    createExistingTheme
    echo "user/existingTheme" > "$__shapeshift_default_file"

    __shapeshift_load

    assertTrue "$SOURCED"
}

test_set_utility_updates_default_file() {
    createExistingTheme

    __shapeshift_set "user/existingTheme"

    assertTrue "[ -f $__shapeshift_default_file ]"
}

test_import_utility_imports_valid_repo() {
    local git() { return 0; }

    createExistingTheme

    local actual=$(__shapeshift_import user/existingTheme)

    assertEquals "Theme user/existingTheme imported" "$actual"
}

test_import_utility_handles_not_existing_repo() {
    local git() { return 1; }

    local actual=$(__shapeshift_import any)

    assertEquals "Not a valid repo" "$actual"
}

test_import_utility_handles_invalid_repo() {
    local git() { return 0; }

    createWrongTheme

    local actual=$(__shapeshift_import any)

    assertEquals "Not a valid theme" "$actual"
}

test_themes_utility_gives_themes_list() {
    createExistingTheme

    local actual=$(__shapeshift_themes)

    assertEquals "user/existingTheme" "$actual"
}

test_unique_utility_gives_unique_theme() {
    createExistingTheme

    local repo=""
    __shapeshift_unique_theme existingTheme

    assertEquals "user/existingTheme" "$repo"
}

test_unique_utility_does_not_set_repo_if_it_not_exist() {
    local repo=""
    __shapeshift_unique_theme existingTheme

    assertNull "$repo"
}

test_unique_utility_gives_list_of_duplicated_names() {
    createExistingTheme
    createAnotherExistingTheme

    local actual=$(__shapeshift_unique_theme existingTheme)

    assertContains "$actual" "duplicated, use one of the following"
    assertContains "$actual" "user2/existingTheme"
    assertContains "$actual" "user/existingTheme"
}

# Utilities

assertContains() {
    local output=$(echo "$1" | grep "$2" | wc -l)
    assertTrue "[ $output -ge 1 ]"
}

setTheme() {
    echo $1 > $__shapeshift_default_file
}

createExistingTheme() {
    mkdir -p "$__shapeshift_config_dir/user/existingTheme"
    echo "SOURCED=true" > "$__shapeshift_config_dir/user/existingTheme/$__shapeshift_theme_name"
}

createAnotherExistingTheme() {
    mkdir -p "$__shapeshift_config_dir/user2/existingTheme"
    touch "$__shapeshift_config_dir/user2/existingTheme/$__shapeshift_theme_name"
}

createWrongTheme() {
    mkdir -p "$__shapeshift_config_dir/user/wrongTheme"
    touch "$__shapeshift_config_dir/user/wrongTheme/wrongName"
}

# Run

source "shunit2/shunit2"