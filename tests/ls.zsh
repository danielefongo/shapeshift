#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

oneTimeSetUp() {  
  source ls.zsh
}

# Tests

test_set_color_ls() {
  local SHAPESHIFT_LS_COLORS=(wrong black red green yellow blue magenta)
  
  color_ls_set

  assertEquals "$LSCOLORS" "xxaxbxcxdxexfx"
  assertEquals "$LS_COLORS" "di=0:ln=8:so=31:pi=32:ex=33:bd=34:cd=35"
}

test_set_color_ls_bold() {
  local SHAPESHIFT_LS_COLORS=(boldwrong boldblack boldred boldgreen boldyellow boldblue boldmagenta)
  
  color_ls_set

  assertEquals "$LSCOLORS" "xxAxBxCxDxExFx"
  assertEquals "$LS_COLORS" "di=0:ln=8;1:so=31;1:pi=32;1:ex=33;1:bd=34;1:cd=35;1"
}

test_set_color_ls_alias() {
  __color_ls_alias="myLs"
  local SHAPESHIFT_LS_COLORS=(wrong black red green yellow blue magenta)
  
  color_ls_set

  assertEquals "ls=myLs" "$(alias ls)"
}

test_unset_color_ls_alias() {
  local SHAPESHIFT_LS_COLORS=(wrong black red green yellow blue magenta)
  color_ls_set

  color_ls_unset
  assertEquals "ls=ls" "$(alias ls)"
}

# Run

source "shunit2/shunit2"