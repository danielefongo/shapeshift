zmodload zsh/datetime

typeset -gA __timers

timer_get() {
  if [ -z $__timers["$1"] ]; then
    echo 0
    return
  fi
  integer milliseconds
  local actualTime=$__timers["$1"]
  (( milliseconds = (EPOCHREALTIME - $actualTime)*1000 ))
  echo $milliseconds
}

timer_start() {
  __timers["$1"]=$EPOCHREALTIME
}

timer_stop() {
  __timers["$1"]=""
}

timer_get_and_stop() {
  timer_get $1
  timer_stop $1
}
