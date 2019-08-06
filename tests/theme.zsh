#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

oneTimeSetUp() {
    __shapeshift_path="$(pwd)"
}

setUp() {
    source theme.zsh
    
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
    __shapeshift_load() {;}
    shape-shift

    assertTrue "[ ! -f $__shapeshift_default_file ]"
}

test_shift_does_not_load_when_not_existing_repo_is_provided() {
    __shapeshift_load() {fail;}
    __shapeshift_unique_theme() {return 1;}
    shape-shift invalid &>/dev/null
}

test_shift_loads_existing_repo() {
    __shapeshift_load() {;}
    __shapeshift_set() {;}
    __shapeshift_import() {fail;}
    
    createExistingTheme

    shape-shift existingTheme &>/dev/null
}

test_shift_imports_valid_repo() {
    local importCalled
    local setCalled
    __shapeshift_load() {;}
    __shapeshift_import() {importCalled=true;}
    __shapeshift_set() {setCalled=true;}
    
    shape-shift newTheme &>/dev/null

    assertTrue "$importCalled"
    assertTrue "$setCalled"
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

    assertEquals "" "$repo"
}

test_unique_utility_gives_list_of_duplicated_names() {
    createExistingTheme
    createAnotherExistingTheme

    local actual=$(__shapeshift_unique_theme existingTheme)
    local expected="duplicated, use one of the following:
- user2/existingTheme
- user/existingTheme"

    assertEquals "$expected" "$actual"
}

# Utilities

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