zmodload zsh/zpty
typeset -gA __locks
typeset -gA __locks_state
__lock_active=0
__lock_inactive=1

function lock_create() {
    local lock="__lock__$1"
    __locks["$1"]="$lock"

    zpty -d $lock 2>/dev/null
    zpty $lock cat

    lock_unlock $1
}

function lock_exists() {
    [[ $__locks["$1"] ]]
}

function lock_lock() {
    local lock=$__locks["$1"]

    zpty -r $lock __lock_tmp_var
    __locks_state["$1"]=$__lock_active
}

function lock_unlock() {
    local lock=$__locks["$1"]

    zpty -w $lock 'y'
    __locks_state["$1"]=$__lock_inactive
}

function lock_active() {
    return $__locks_state["$1"]
}