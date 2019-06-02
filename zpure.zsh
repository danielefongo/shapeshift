setopt prompt_subst
autoload -U colors && colors
typeset -gA renderElements

mypath=${0:a:h}

#common files
source "$mypath/properties"
source "$mypath/color.zsh"

#functions
source "$mypath/async.zsh"
source "$mypath/git.zsh"
source "$mypath/dir.zsh"

function PROMPTCMD() {
    local elements=("${PROMPT_LEFT_ELEMENTS[@]}")
    local leftSpace=""
    local rightSpace=" "

    if [[ $1 == "right" ]]; then
        elements=("${PROMPT_RIGHT_ELEMENTS[@]}")
        leftSpace=" "
        rightSpace=""
    fi

    local FULL=""
    for method in $elements; do
        local methodOutput=${renderElements["$method"]}
        if [[ $methodOutput ]]; then
          FULL="$FULL$leftSpace$methodOutput$rightSpace"
        fi
    done
    echo "${FULL}"
}

function updatePrompt() {
    PROMPT="$(PROMPTCMD left)"
    RPROMPT="$(PROMPTCMD right)"
    zle && zle reset-prompt && zle -R
}

function asyncCallback() {
    calledMethod=$1
    output=${3//$'\015'}
    renderElements["$calledMethod"]=$output
    updatePrompt
}

function precmd() {
    print
    for method in $PROMPT_LEFT_ELEMENTS; do
        if [[ $method =~ "^async" ]]; then
            renderElements["$method"]=""
            asyncJob $method asyncCallback
        else
            renderElements["$method"]=$(eval "$method")
        fi
    done
    for method in $PROMPT_RIGHT_ELEMENTS; do
        if [[ $method =~ "^async" ]]; then
            renderElements["$method"]=""
            asyncJob $method asyncCallback
        else
            renderElements["$method"]=$(eval "$method")
        fi
    done
    updatePrompt
}

zeroCommand () {
    if [ -z "$BUFFER" ]; then
        if git rev-parse --git-dir > /dev/null 2>&1 ; then
            if [[ $ZPURE_GIT_DIR_COMMAND ]]; then
                BUFFER="$ZPURE_GIT_DIR_COMMAND"
            fi
        else
            if [[ $ZPURE_NON_GIT_DIR_COMMAND ]]; then
                BUFFER="$ZPURE_NON_GIT_DIR_COMMAND"
            fi
        fi
    fi
    zle accept-line
}

zle -N zeroCommand
bindkey '^M' zeroCommand
