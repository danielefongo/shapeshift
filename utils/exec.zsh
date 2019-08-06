typeset -gA __jobs_outputs

function exec_async() {
    local method=$1
    local callback=$2

    __exec_reset_output $method

    async_job ${method//$__shapeshift_async_prefix/} __exec_async_callback
}

function exec_sync() {
    local method=$1
    __jobs_outputs["$method"]=$(eval "$method")
}

function result_for() {
    local method=$1
    echo $__jobs_outputs["$method"]
}

function reset_results() {
    __jobs_outputs=()
}

function __exec_async_callback() {
    local calledMethod=${1}
    local output=${3}
    __jobs_outputs["$calledMethod"]=$output
    __shapeshift_update_prompt
}

function __exec_reset_output() {
    local method="$1"
    if [[ $SHAPESHIFT_RESET_ASYNC_OUTPUTS_BEFORE_UPDATING == true ]]; then
        __jobs_outputs["$method"]=""
    fi
}