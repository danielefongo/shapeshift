typeset -gA renderElements

mypath=${0:a:h}

#common files
source "$mypath/theme.zsh"
source "$mypath/color.zsh"

#functions
source "$mypath/async.zsh"
source "$mypath/time.zsh"
source "$mypath/git.zsh"
source "$mypath/dir.zsh"

function PROMPTCMD() {
    local elements=("${SHAPESHIFT_PROMPT_LEFT_ELEMENTS[@]}")
    local leftSpace=""
    local rightSpace=" "

    if [[ $1 == "right" ]]; then
        elements=("${SHAPESHIFT_PROMPT_RIGHT_ELEMENTS[@]}")
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
    calledMethod=${1}
    output=${3}
    renderElements["$calledMethod"]=$output
    updatePrompt
}

function precmd() {
    lastCommandStatus=$?
    print
    for method in $SHAPESHIFT_PROMPT_LEFT_ELEMENTS; do
        if [[ $method =~ "^async" ]]; then
            renderElements["$method"]=""
            asyncJob $method asyncCallback
        else
            renderElements["$method"]=$(eval "$method")
        fi
    done
    for method in $SHAPESHIFT_PROMPT_RIGHT_ELEMENTS; do
        if [[ $method =~ "^async" ]]; then
            renderElements["$method"]=""
            asyncJob $method asyncCallback
        else
            renderElements["$method"]=$(eval "$method")
        fi
    done
    updatePrompt
    timer_end
}

function preexec() {
    timer_start
}

shapeshift-load
