PROMPT_ARROW_CHAR="❯"
PROMPT_ARROW_CHAR_BOLD=true
PROMPT_ARROW_OK_COLOR="green"
PROMPT_ARROW_KO_COLOR="red"

TRUNCATED_DIR_COLOR="blue"
TRUNCATED_DIR_BOLD=false
LAST_FOLDER_DIR_COLOR="blue"
LAST_FOLDER_DIR_BOLD=true

source "color.zsh"

function prompt_dir() {
    local current="$(print -P "%4(~:.../:)%3~")"
    local last="$(print -P "%1~")"

    local truncated="$(echo "${current%/*}/")"

    if [[ "${truncated}" == "/" || "${current}" == "~" ]]; then
        truncated=""
    else
        truncated=$(colorize $truncated $TRUNCATED_DIR_COLOR $TRUNCATED_DIR_BOLD)
    fi

    last=$(colorize $last $LAST_FOLDER_DIR_COLOR $LAST_FOLDER_DIR_BOLD)
    echo "$truncated$last"
}

function prompt_arrow() {
    colorizeArrow ${PROMPT_ARROW_CHAR} ${PROMPT_ARROW_OK_COLOR} ${PROMPT_ARROW_KO_COLOR} ${PROMPT_ARROW_CHAR_BOLD}
}
