last_command_elapsed_time() {
  local millisecondsElapsed=$(timer_get last_command)

  local hours=$(( millisecondsElapsed / 1000 / 60 / 60 % 24 ))
  local minutes=$(( millisecondsElapsed / 1000 / 60 % 60 ))
  local seconds=$(( millisecondsElapsed / 1000 % 60 ))
  local milliseconds=$(( millisecondsElapsed % 1000 ))

  local approxTime
  (( milliseconds > 0 )) && approxTime="${milliseconds}ms"
  (( seconds > 0 )) && approxTime="${seconds}s"
  (( minutes > 0 )) && approxTime="${minutes}m"
  (( hours > 0 )) && approxTime="${hours}h"

  colorize "$approxTime" "$SHAPESHIFT_LAST_COMMAND_ELAPSED_TIME_COLOR" "$SHAPESHIFT_LAST_COMMAND_ELAPSED_TIME_BOLD"
}