zmodload zsh/datetime

typeset -g timerTimeStamp

last_command_elapsed_seconds() {
  timer_get
}

timer_get() {
  integer elapsedSeconds
  (( elapsedSeconds = EPOCHREALTIME - ${timerTimeStamp:-$EPOCHREALTIME} ))
  if [[ $elapsedSeconds -gt 0 ]]; then
    colorize "${elapsedSeconds}s" $SHAPESHIFT_LAST_COMMAND_ELAPSED_SECONDS_COLOR $SHAPESHIFT_LAST_COMMAND_ELAPSED_SECONDS_BOLD
  fi
}

timer_end() {
  unset timerTimeStamp
}

timer_start() {
  timerTimeStamp=$EPOCHREALTIME
}
