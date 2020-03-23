#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

oneTimeSetUp() {
  source utils/cache.zsh
}

setUp() {
  function echoes() { echo $1 }
  function echoes2() { echo $1 }
}

tearDown() {
  unset -f echoes
  unset -f echoes2
}

# Tests

test_cache_returns_result_when_caching() {
  result=$(cache echoes 1)

  assertEquals 1 ${result}
}

test_cache_maintains_function_result() {
  cache echoes 1 &>/dev/null

  result=$(echoes)

  assertEquals 1 ${result}
}

test_cache_does_not_work_with_not_existing_functions() {
  cache not_existing_function

  assertEquals 1 $?
}

test_cache_twice_overrides_cache() {
  cache echoes 1 &>/dev/null
  cache echoes 2 &>/dev/null

  result=$(echoes)

  assertEquals 2 ${result}
}

test_cache_twice_does_not_override_cached_function() {
  cache echoes 1 &>/dev/null
  cache echoes 2 &>/dev/null
  uncache echoes

  result=$(echoes 5)

  assertEquals 5 ${result}
}

test_cache_multiple_functions() {
  cache echoes 1 &>/dev/null
  cache echoes2 2 &>/dev/null

  assertEquals 1 $(echoes)
  assertEquals 2 $(echoes2)
}

test_uncache_function_restores_functionality() {
  cache echoes 1 &>/dev/null
  uncache echoes

  assertEquals 2 $(echoes 2)
}

test_uncache_multiple_functions() {
  cache echoes 1 &>/dev/null
  cache echoes2 2 &>/dev/null
  uncache echoes
  uncache echoes2

  assertEquals 3 $(echoes 3)
  assertEquals 4 $(echoes2 4)
}

# Run

source "shunit2/shunit2"