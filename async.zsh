zmodload zsh/zpty
zmodload zsh/system
typeset -gA asyncJobs

lockfile="/tmp/async_${RANDOM}${RANDOM}${RANDOM}"
touch $lockfile

function asyncHandler() {
  local buffer=""
  while zpty -r asynced line; do
    buffer+="$line"
  done
  eval "${buffer//$'\015'}"
  zpty -w locking "unlock"
}

function asyncJob {
  local fun="$1"
  local callback="$2"
  shift
  shift
  local arguments="$@"

  function async() {
    job=$($fun $arguments)
    local exitStatus=$?
    if [[ "$callback" ]]; then
    {
      local asyncLock
      zsystem flock -f asyncLock $lockfile

      zpty -w asynced "$callback \"$fun\" \"$exitStatus\" \"$job\""
      kill -s WINCH $$
      zpty -r locking var

      zsystem flock -u $asyncLock
    }
    fi
  }

  kill -9 $asyncJobs["$fun"] 2>/dev/null
  async &!
  asyncJobs["$fun"]="$!"
}

zpty -d asynced 2>/dev/null
zpty -b asynced cat
zpty -d locking 2>/dev/null
zpty locking cat

trap 'asyncHandler' WINCH
function zshexit() {
  rm $lockfile 2>/dev/null
}
