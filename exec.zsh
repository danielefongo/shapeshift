typeset -gA __jobs_outputs
typeset -gA __jobs_callbacks

function exec_async() {
    local method=$1
    local callback=$2

    if [[ $SHAPESHIFT_RESET_ASYNC_OUTPUTS_BEFORE_UPDATING == true ]]; then
        __jobs_outputs["$method"]=""
    fi

    __jobs_callbacks["$method"]="$callback"
    async_job ${method//$__shapeshift_async_prefix/} __execAsync_callback
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
    __jobs_callbacks=()
}

function __execAsync_callback() {
    local calledMethod=${1}
    local output=${3}
    local callback=$__jobs_callbacks["$calledMethod"]
    __jobs_outputs["$calledMethod"]=$output
    __shapeshift_update_prompt
}