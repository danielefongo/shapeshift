SHAPESHIFT_VERSION=1

__shapeshift_path=${0:a:h}
__shapeshift_async_prefix="async_"

#common files
source "$__shapeshift_path/utils/ls.zsh"
source "$__shapeshift_path/utils/color.zsh"
source "$__shapeshift_path/utils/lock.zsh"
source "$__shapeshift_path/utils/async.zsh"
source "$__shapeshift_path/utils/exec.zsh"
source "$__shapeshift_path/utils/changes.zsh"

#segment functions
source "$__shapeshift_path/segments/time.zsh"
source "$__shapeshift_path/segments/git.zsh"
source "$__shapeshift_path/segments/dir.zsh"

#theme
source "$__shapeshift_path/utils/theme.zsh"

function __shapeshift_init() {
    function precmd() {
        __shapeshift_last_command_status=$?

        __shapeshift_ls_update

        __shapeshift_print_newline_if_enabled

        __shapeshift_exec_elements $SHAPESHIFT_PROMPT_LEFT_ELEMENTS
        __shapeshift_exec_elements $SHAPESHIFT_PROMPT_RIGHT_ELEMENTS

        __shapeshift_update_prompt

        timer_end
    }

    function preexec() {
        timer_start
    }

    async_init
    __shapeshift_load
}

function __shapeshift_update_prompt() {
    PROMPT="$(__shapeshift_render_left)"
    RPROMPT="$(__shapeshift_render_right)"

    zle && zle reset-prompt && zle -R
}

function __shapeshift_render_left() {
    local full=""
    for method in $SHAPESHIFT_PROMPT_LEFT_ELEMENTS; do
        local methodOutput=$(result_for ${method//async_})

        if [[ $methodOutput ]]; then
          full="$full$methodOutput "
        fi
    done

    echo "${full}"
}

function __shapeshift_render_right() {
    local full=""
    for method in $SHAPESHIFT_PROMPT_RIGHT_ELEMENTS; do
        local methodOutput=$(result_for ${method//async_})

        if [[ $methodOutput ]]; then
          full="$full$methodOutput "
        fi
    done

    echo "${full}"
}

function __shapeshift_print_newline_if_enabled() {
    if [[ $SHAPESHIFT_NEWLINE_AFTER_COMMAND == true ]]; then
        print
    fi
}

function __shapeshift_exec_elements() {
    for method in $@; do
        if [[ $method =~ ^async_ ]]; then
            exec_async ${method//async_/} __shapeshift_update_prompt
        else
            exec_sync $method
        fi
    done
}

function __shapeshift_ls_update() {
    if [[ $SHAPESHIFT_LS_COLORS_ENABLED == true ]]; then
        color_ls_set
    else
        color_ls_unset
    fi
}

__shapeshift_change_log
__shapeshift_init