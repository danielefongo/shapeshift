function asyncJob {
  local fun="$1"
  local callback="$2"
  shift
  shift
  local arguments="$@"
  local job="/tmp/async_$(( $RANDOM % 10000 + 1 ))"

  function async() {
    $fun $arguments > $job
    local exitStatus=$?
    if [[ "$callback" ]]; then
      $callback $exitStatus "$(cat $job)"
    fi
    rm $job
    kill -s USR1 $$
  }

  async &!
}
