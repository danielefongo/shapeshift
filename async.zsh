zmodload zsh/zpty
zmodload zsh/system
typeset -gA __async_jobs

__async_lockfile="/tmp/async_${RANDOM}${RANDOM}${RANDOM}"
touch $__async_lockfile

function __async_handler() {
  local buffer=""
  while zpty -r asynced line; do
    buffer+="$line"
  done
  eval "${buffer//$'\015'}" 2>/dev/null
  zpty -w locking "unlock"
}

function asyncJob {
  local fun="$1"
  local callback="$2"
  shift
  shift
  local arguments="$@"

  function __async() {
    local job=$($fun $arguments)
    local exitStatus=$?
    if [[ "$callback" ]]; then
    {
      local asyncLock
      zsystem flock -f asyncLock $__async_lockfile

      zpty -w asynced "$callback \"$fun\" \"$exitStatus\" \"$job\""
      kill -s WINCH $$
      zpty -r locking var

      zsystem flock -u $asyncLock
    }
    fi
  }

  kill -9 $__async_jobs["$fun"] 2>/dev/null
  __async &!
  __async_jobs["$fun"]="$!"
}

zpty -d asynced 2>/dev/null
zpty -b asynced cat
zpty -d locking 2>/dev/null
zpty locking cat

trap '__async_handler' WINCH
function zshexit() {
  rm $__async_lockfile 2>/dev/null
}
