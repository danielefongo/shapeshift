function asyncJob {
  local fun="$1"
  local callback="$2"
  local job="/tmp/async_$(( $RANDOM % 10000 + 1 ))"

  function async() {
    $fun > $job
    local exitStatus=$?
    $callback $exitStatus "$(cat $job)"
    rm $job
    kill -s USR1 $$
  }

  async &!
}
