zmodload zsh/zpty
typeset -gA asyncJobs

function asyncBuffer() {
  while read line; do
    echo $line
  done
}

function asyncHandler() {
  while zpty -r asynced line; do
    for callback fun exitstatus out in ${line}; do
      eval "$callback $fun $exitstatus $out" 2>/dev/null
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
      kill -s WINCH $$
    fi
  }

  async &!
  asyncJobs["$fun"]="$!"
}

function deleteAsyncJobs() {
  for job in $asyncJobs; do
    kill $job 2>/dev/null
  done
}

zpty -d asynced 2>/dev/null
zpty -b asynced asyncBuffer

trap 'asyncHandler' WINCH
