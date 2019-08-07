#!/usr/bin/env zsh

# Setup

setopt shwordsplit
SHUNIT_PARENT=$0

oneTimeSetUp() {  
  source utils/exec.zsh
}

# Tests

test_exec_sync_method() {
  segment() { echo "expectedOutput"; }
  exec_sync segment

  local actual=$__jobs_outputs["segment"]
  assertEquals "expectedOutput" "$actual"
}

test_exec_async_method() {
  segment() { echo "expectedOutput"; }
  exec_async segment

  sleep 0.1

  local actual=$__jobs_outputs["segment"]
  assertEquals "expectedOutput" "$actual"
}

test_resets_output_if_flag_is_active() {
  local SHAPESHIFT_RESET_ASYNC_OUTPUTS_BEFORE_UPDATING=true
  __jobs_outputs["segment"]="oldText"

  __exec_reset_output segment

  local actual=$__jobs_outputs["segment"]
  assertNull "$actual"
}

test_gives_output_for_called_method() {
  __jobs_outputs["segment"]="expectedOutput"

  local actual=$(result_for segment)
  assertEquals "expectedOutput" "$actual"
}

test_reset_results_clears_all_outputs() {
  __jobs_outputs["segment1"]="output1"
  __jobs_outputs["segment2"]="output2"

  reset_results

  local numberOfOutputs=${#__jobs_outputs}
  assertEquals "$numberOfOutputs" "0"
}

# Utilities

async_job() {
  fun="$1"
  callback="$2"
  $callback "$fun" "0" "$($fun)"
}

__shapeshift_update_prompt() {}

# Run

source "shunit2/shunit2"