__shapeshift_path=${0:a:h}
__shapeshift_async_prefix="async_"

# common files
source "$__shapeshift_path/utils/ls.zsh"
source "$__shapeshift_path/utils/color.zsh"
source "$__shapeshift_path/utils/lock.zsh"
source "$__shapeshift_path/utils/async.zsh"
source "$__shapeshift_path/utils/exec.zsh"
source "$__shapeshift_path/utils/time.zsh"

# segment functions
source "$__shapeshift_path/segments/time.zsh"
source "$__shapeshift_path/segments/git.zsh"
source "$__shapeshift_path/segments/dir.zsh"

# theme
source "$__shapeshift_path/utils/theme.zsh"

function precmd() {
    if [[ $SHAPESHIFT_PRECMD ]]; then
        eval $SHAPESHIFT_PRECMD
    fi

    __shapeshift_last_command_status=$?

    __shapeshift_set_is_git_repo

    __shapeshift_ls_update

    __shapeshift_print_newline_if_enabled

    __shapeshift_exec_elements $SHAPESHIFT_PROMPT_LEFT_ELEMENTS
    __shapeshift_exec_elements $SHAPESHIFT_PROMPT_RIGHT_ELEMENTS

    timer_stop last_command

    __shapeshift_update_prompt
}

function preexec() {
    timer_start last_command
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
          full="$full $methodOutput"
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
            exec_async ${method//async_/}
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

function __shapeshift_set_is_git_repo() {
    git rev-parse --is-inside-work-tree &>/dev/null
    if [ $? = 0 ]; then
        SHAPESHIFT_IS_GIT_REPO=true
    else
        SHAPESHIFT_IS_GIT_REPO=false
    fi
}

async_init
__shapeshift_load
