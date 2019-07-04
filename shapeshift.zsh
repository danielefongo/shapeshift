typeset -gA __shapeshift_render_elements

__shapeshift_path=${0:a:h}
__shapeshift_async_prefix="async_"

#common files
source "$__shapeshift_path/theme.zsh"
source "$__shapeshift_path/color.zsh"

#functions
source "$__shapeshift_path/async.zsh"
source "$__shapeshift_path/time.zsh"
source "$__shapeshift_path/git.zsh"
source "$__shapeshift_path/dir.zsh"

function __shapeshift_render() {
    local elements=("${SHAPESHIFT_PROMPT_LEFT_ELEMENTS[@]}")
    local leftSpace=""
    local rightSpace=" "

    if [[ $1 == "right" ]]; then
        elements=("${SHAPESHIFT_PROMPT_RIGHT_ELEMENTS[@]}")
        leftSpace=" "
        rightSpace=""
    fi

    local full=""
    for method in $elements; do
        local methodOutput=${__shapeshift_render_elements["$method"]}
        if [[ $methodOutput ]]; then
          full="$full$leftSpace$methodOutput$rightSpace"
        fi
    done
    echo "${full}"
}

function __shapeshift_update_prompt() {
    PROMPT="$(__shapeshift_render left)"
    RPROMPT="$(__shapeshift_render right)"

    zle && zle reset-prompt && zle -R
}

function __shapeshift_async_callback() {
    local calledMethod=${1}
    local output=${3}
    __shapeshift_render_elements["$__shapeshift_async_prefix$calledMethod"]=$output
    __shapeshift_update_prompt
}

function precmd() {
    __shapeshift_last_command_status=$?
    print
    for method in $SHAPESHIFT_PROMPT_LEFT_ELEMENTS; do
        if [[ $method =~ "^$__shapeshift_async_prefix" ]]; then
            __shapeshift_render_elements["$method"]=""
            asyncJob ${method//$__shapeshift_async_prefix/} __shapeshift_async_callback
        else
            __shapeshift_render_elements["$method"]=$(eval "$method")
        fi
    done
    for method in $SHAPESHIFT_PROMPT_RIGHT_ELEMENTS; do
        if [[ $method =~ "^$__shapeshift_async_prefix" ]]; then
            __shapeshift_render_elements["$method"]=""
            asyncJob ${method//$__shapeshift_async_prefix/} __shapeshift_async_callback
        else
            __shapeshift_render_elements["$method"]=$(eval "$method")
        fi
    done
    __shapeshift_update_prompt
    timer_end
}

function preexec() {
    timer_start
}

__shapeshift_load
