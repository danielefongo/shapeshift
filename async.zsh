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
      $callback $exitStatus "$job"
    fi
    kill -s USR1 $$
  }

  async &!
}