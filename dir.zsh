function prompt_dir() {
    integer shortDirLength
    ((shortDirLength = SHAPESHIFT_DIR_LENGTH ))

    if [[ $shortDirLength -lt 1 ]]; then
        return
    fi

    local current="$(print -P "%($((shortDirLength + 1))~|.../%${shortDirLength}~|%~)")"
    local last="$(print -P "%1~")"

    local truncated="$(echo "${current%/*}/")"

    if [[ "${truncated}" == "/" || "${last}" == "~" ]]; then
        truncated=""
    else
        truncated=$(colorize "$truncated" $SHAPESHIFT_TRUNCATED_DIR_COLOR $SHAPESHIFT_TRUNCATED_DIR_BOLD)
    fi

    last=$(colorize "$last" $SHAPESHIFT_LAST_FOLDER_DIR_COLOR $SHAPESHIFT_LAST_FOLDER_DIR_BOLD)
    echo "$truncated$last"
}

function prompt_arrow() {
    colorizeFromStatus ${SHAPESHIFT_ARROW_OK_CHAR} ${SHAPESHIFT_ARROW_OK_COLOR} ${SHAPESHIFT_ARROW_OK_CHAR_BOLD} ${SHAPESHIFT_ARROW_KO_CHAR} ${SHAPESHIFT_ARROW_KO_COLOR} ${SHAPESHIFT_ARROW_KO_CHAR_BOLD}
}
