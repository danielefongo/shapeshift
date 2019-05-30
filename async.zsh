zmodload zsh/zpty

function asyncBuffer() {
  while read line; do
    echo $line
  done
}

function TRAPUSR1() {
  while zpty -r asynced line; do
    for callback fun exitstatus out in ${line}; do
      eval "$callback $fun $exitstatus $out"
    done
  done
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
      zpty -w asynced "$callback \"$fun\" \"$exitStatus\" \"$job\" "
      sleep 0.01
      kill -s USR1 $$
    fi
  }

  async &!
}

zpty -d asynced 2>/dev/null
zpty -b asynced asyncBuffer
