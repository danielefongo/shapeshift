PROMPT_ARROW_CHAR="❯"

function prompt_dir() {
    local current="$(print -P "%4(~:.../:)%3~")"
    local last="$(print -P "%1~")"

    local truncated="$(echo "${current%/*}/")"

    if [[ "${truncated}" == "/" || "${current}" == "~" ]]; then
        truncated=""
    fi

    echo "%{$fg[blue]%}${truncated}%B${last}%b%{$reset_color%}"
}

function prompt_arrow() {
    echo "%{$fg[green]%}%(?..%{$fg[red]%})%B${PROMPT_ARROW_CHAR}%b%{$reset_color%}"
}
