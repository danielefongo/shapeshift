zmodload zsh/zpty
zmodload zsh/system
typeset -gA __async_jobs

function async_job {
  lock_exists async || return 1

  local fun="$1"

  kill -9 $__async_jobs["$fun"] 2>/dev/null
  __async "$@" &!
  __async_jobs["$fun"]="$!"
}

function __async_handler() {
  local buffer=""
  while zpty -r asynced line; do
    buffer+="$line"
  done
  eval "${buffer//$'\015'}" 2>/dev/null
  lock_unlock handler
  lock_unlock async
}

function __async() {
  local fun="$1"
  local callback="$2"
  shift
  shift
  local arguments="$@"

  local job=$($fun $arguments)
  local exitStatus=$?

  lock_lock async

  zpty -w asynced "$callback \"$fun\" \"$exitStatus\" \"$job\""
  kill -s WINCH $$

  lock_lock handler
}

zpty -d asynced 2>/dev/null
zpty -b asynced cat

function async_init() {
  lock_create async
  lock_create handler
  lock_lock handler
  trap '__async_handler' WINCH
}