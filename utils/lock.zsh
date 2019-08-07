zmodload zsh/zpty
typeset -gA __locks

function lock_create() {
    local lock="__lock__$1"
    __locks["$1"]="$lock"
    
    zpty -d $lock 2>/dev/null
    zpty $lock cat
    
    lock_unlock $1
}

function lock_exists() {
    [[ $__locks["$1"] ]] || return 1
}

function lock_lock() {
    local lock=$__locks["$1"]

    zpty -r $lock __lock_tmp_var
}

function lock_unlock() {
    local lock=$__locks["$1"]
    
    zpty -w $lock 'y'
}