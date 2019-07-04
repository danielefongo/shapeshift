zmodload zsh/datetime

typeset -g __timer_time_stamp

last_command_elapsed_time() {
  local millisecondsElapsed=$(timer_get)

  local hours=$(( millisecondsElapsed / 1000 / 60 / 60 % 24 ))
  local minutes=$(( millisecondsElapsed / 1000 / 60 % 60 ))
  local seconds=$(( millisecondsElapsed / 1000 % 60 ))
  local milliseconds=$(( millisecondsElapsed % 1000 ))

  local approxTime
  (( milliseconds > 0 )) && approxTime="${milliseconds}ms"
  (( seconds > 0 )) && approxTime="${seconds}s"
  (( minutes > 0 )) && approxTime="${minutes}m"
  (( hours > 0 )) && approxTime="${hours}h"

  colorize "$approxTime" $SHAPESHIFT_LAST_COMMAND_ELAPSED_SECONDS_COLOR $SHAPESHIFT_LAST_COMMAND_ELAPSED_SECONDS_BOLD
}

timer_get() {
  integer milliseconds
  (( milliseconds = (EPOCHREALTIME - ${__timer_time_stamp:-$EPOCHREALTIME})*1000 ))
  echo $milliseconds
}

timer_end() {
  unset __timer_time_stamp
}

timer_start() {
  __timer_time_stamp=$EPOCHREALTIME
}
