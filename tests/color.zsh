#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

oneTimeSetUp() {  
  source color.zsh
}

# Tests

test_colorize_text_using_standard_color() {
  local expected="%F{red}hello%f"
  local actual=$(colorize hello red)

  assertEquals "colorized" "$expected" "$actual"
}

test_colorize_text_using_numeric_color() {
  local expected="%F{123}hello%f"
  local actual=$(colorize hello 123)

  assertEquals "colorized" "$expected" "$actual"
}

test_colorize_bolded_text() {
  local expected="%F{red}%Bhello%b%f"
  local actual=$(colorize hello red true)

  assertEquals "colorized" "$expected" "$actual"
}

test_colorize_from_status_ok() {
  local expected="%F{green}%Bok%b%f"
  local actual=$(colorize_from_status ok green true ko red false)

  assertEquals "colorized" "$expected" "$actual"
}

test_colorize_from_status_ko() {
  __shapeshift_last_command_status=1

  local expected="%F{red}ko%f"
  local actual=$(colorize_from_status ok green true ko red false)

  assertEquals "colorized" "$expected" "$actual"
}

# Run

source "shunit2/shunit2"