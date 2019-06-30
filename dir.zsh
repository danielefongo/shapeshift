function prompt_dir() {
    integer shortDirLength
    ((shortDirLength = ZPURE_DIR_LENGTH ))

    if [[ $shortDirLength -lt 1 ]]; then
        return
    fi

    local current="$(print -P "%($((shortDirLength + 1))~|.../%${shortDirLength}~|%~)")"
    local last="$(print -P "%1~")"

    local truncated="$(echo "${current%/*}/")"

    if [[ "${truncated}" == "/" || "${last}" == "~" ]]; then
        truncated=""
    else
        truncated=$(colorize "$truncated" $ZPURE_TRUNCATED_DIR_COLOR $ZPURE_TRUNCATED_DIR_BOLD)
    fi

    last=$(colorize "$last" $ZPURE_LAST_FOLDER_DIR_COLOR $ZPURE_LAST_FOLDER_DIR_BOLD)
    echo "$truncated$last"
}

function prompt_arrow() {
    colorizeFromStatus ${ZPURE_ARROW_OK_CHAR} ${ZPURE_ARROW_OK_COLOR} ${ZPURE_ARROW_OK_CHAR_BOLD} ${ZPURE_ARROW_KO_CHAR} ${ZPURE_ARROW_KO_COLOR} ${ZPURE_ARROW_KO_CHAR_BOLD}
}
