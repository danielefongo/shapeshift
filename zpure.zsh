setopt prompt_subst
autoload -U colors && colors

mypath=${0:a:h}

#common files
source "$mypath/properties"
source "$mypath/color.zsh"

#functions
source "$mypath/async.zsh"
source "$mypath/git.zsh"
source "$mypath/dir.zsh"

function PROMPTCMD() {
    local FULL=""
    local async=$1

    local elements=("${PROMPT_LEFT_ELEMENTS[@]}")
    local leftSpace=""
    local rightSpace=" "

    if [[ $2 == "right" ]]; then
        elements=("${PROMPT_RIGHT_ELEMENTS[@]}")
        leftSpace=" "
        rightSpace=""
    fi

    for method in $elements; do
        local methodOutput=""
        if [[ ! $method =~ "^async" ]]; then
          methodOutput=$(eval "$method")
        elif [[ -f "/tmp/${method}" && $async == true ]]; then
          methodOutput=$(cat < "/tmp/${method}")
        fi
        if [[ $methodOutput ]]; then
          FULL="$FULL$leftSpace$methodOutput$rightSpace"
        fi
    done
    echo "${FULL}"
}

function updatePrompt() {
    local async=$1
    RPROMPT="$(PROMPTCMD $async right)"
    PROMPT="$(PROMPTCMD $async left)"
    zle && zle reset-prompt
}

function TRAPUSR1() {
    updatePrompt true
}

function asyncRun() {
    method="${1}"
    eval "$method" > "/tmp/$method"
}

function precmd() {
    updatePrompt false
    for method in $PROMPT_LEFT_ELEMENTS; do
        if [[ $method =~ "^async" ]]; then
            asyncJob asyncRun "" ${method}
        fi
    done
    for method in $PROMPT_RIGHT_ELEMENTS; do
        if [[ $method =~ "^async" ]]; then
            asyncJob asyncRun "" ${method}
        fi
    done
}
