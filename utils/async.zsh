zmodload zsh/zpty
zmodload zsh/system
typeset -gA __async_jobs

function async_job {
  lock_exists async || return 1

  local fun="$1"

  kill -s TERM $__async_jobs["$fun"] 2>/dev/null
  __async "$@" &!
  __async_jobs["$fun"]="$!"
}

function __async_handler() {
  local buffer=""
  while zpty -r asynced line; do
    buffer+="$line"
  done
  eval "${buffer//$'\015'}" 2>/dev/null
  lock_unlock async
}

function __async_signal_and_exit() {
  lock_active async && return
  kill -s WINCH $$
}

function __async() {
  set -e
  trap "__async_signal_and_exit; return 1" TERM

  local fun="$1"
  local callback="$2"
  shift
  shift
  local arguments="$@"

  function cb() {
    jobResult=$(cat <&p)

    lock_lock async

    zpty -w asynced "$callback \"$fun\" \"\" \"$jobResult\""
    kill -s WINCH $$
  }

  coproc $fun $arguments
  wait $!

  cb
}

zpty -d asynced 2>/dev/null
zpty -b asynced cat

function async_init() {
  lock_create async
  trap '__async_handler' WINCH
}