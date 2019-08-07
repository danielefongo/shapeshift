integer __prompt_dir_length

function prompt_dir() {
    __prompt_dir_length=$SHAPESHIFT_DIR_LENGTH

    [ $__prompt_dir_length -ge 1 ] || return

    local last="$(__prompt_last_folder)"
    local truncated=$(__prompt_truncated_dir $shortDirLength)

    if [[ "$truncated" != "/" && "$last" != "~" ]]; then
        colorize "$truncated" "$SHAPESHIFT_TRUNCATED_DIR_COLOR" "$SHAPESHIFT_TRUNCATED_DIR_BOLD"
    fi

    colorize "$last" "$SHAPESHIFT_LAST_FOLDER_DIR_COLOR" "$SHAPESHIFT_LAST_FOLDER_DIR_BOLD"
}

function prompt_arrow() {
    colorize_from_status "${SHAPESHIFT_ARROW_OK_CHAR}" "${SHAPESHIFT_ARROW_OK_COLOR}" "${SHAPESHIFT_ARROW_OK_CHAR_BOLD}" "${SHAPESHIFT_ARROW_KO_CHAR}" "${SHAPESHIFT_ARROW_KO_COLOR}" "${SHAPESHIFT_ARROW_KO_CHAR_BOLD}"
}

function __prompt_last_folder() {
    print -P "%1~"
}

function __prompt_truncated_dir() {
    local fullDir="$(__prompt_full_dir)"
    local longDir="$(__prompt_long_dir)"
    local shortDir="$(__prompt_short_dir)"
    local current="$(print -P "%($longDir|$shortDir|$fullDir)")"
    echo "${current%/*}/"
}

function __prompt_full_dir() {
    print -P "%~"
}

function __prompt_long_dir() {
    print -P "$((__prompt_dir_length + 1))~"
}

function __prompt_short_dir() {
    print -P ".../%$__prompt_dir_length~"
}