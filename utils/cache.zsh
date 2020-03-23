typeset -gA __cache_funs
typeset -gA __cache_results

cached_fun=""

function cache() {
    fun=$1
    shift

    __is_defined $fun || return 1
    uncache $fun

    result=$(eval $fun $@)
    __cache_funs["$fun"]=$(declare -f $fun)
    __cache_results["$fun"]=${(q)result}

    eval "$fun() { echo ${(q)result} }"
    echo ${(q)result}
}

function uncache() {
    fun=$1

    eval ${__cache_funs["$fun"]}
    __cache_funs["$fun"]=""
    __cache_results["$fun"]=""
}

function __is_defined() {
    declare -f $1 > /dev/null || return 1
}