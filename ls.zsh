bsd_pattern="<1>x<2>x<3>x<4>x<5>x<6>x<7>x"
non_bsd_pattern="di=<1>:ln=<2>:so=<3>:pi=<4>:ex=<5>:bd=<6>:cd=<7>"

__color_ls_default_lscolors=$LSCOLORS
__color_ls_default_ls_colors=$LS_COLORS
__color_ls_default_alias=$(alias ls || echo "ls")

function color_ls_set() {
    local -A lscolors
    lscolors=(default x black a red b green c yellow d blue e magenta f cyan g grey h boldblack A  boldred B  boldgreen C  boldyellow D  boldblue E  boldmagenta F  boldcyan G  boldgrey H)

    local -A ls_colors
    ls_colors=(default 0 black 8 red 31 green 32 yellow 33 blue 34 magenta 35 cyan 36 grey 37 boldblack "8;1" boldred "31;1" boldgreen "32;1" boldyellow "33;1" boldblue "34;1" boldmagenta "35;1" boldcyan "36;1" boldgrey "37;1")

    count=1
    LSCOLORS=$bsd_pattern
    for color in $SHAPESHIFT_LS_COLORS; do
        LSCOLORS=${LSCOLORS//<$count>/${lscolors[$color]-x}}
        count=$(( count + 1 ))
    done
    export LSCOLORS

    count=1
    LS_COLORS=$non_bsd_pattern
    for color in $SHAPESHIFT_LS_COLORS; do
        LS_COLORS=${LS_COLORS//<$count>/${ls_colors[$color]-0}}
        count=$(( count + 1 ))
    done
    export LS_COLORS

    alias ls="$__color_ls_alias"
}

function color_ls_unset() {
    export LSCOLORS=$__color_ls_defaultlscolors
    export LS_COLORS=$__color_ls_default_lscolors

    alias ls="$__color_ls_default_alias"
}

__color_ls_alias="ls"
if [[ "$OSTYPE" == netbsd* ]]; then
    gls --color -d . &>/dev/null && __color_ls_alias='gls --color=tty'
elif [[ "$OSTYPE" == openbsd* ]]; then
    gls --color -d . &>/dev/null && __color_ls_alias='gls --color=tty'
    colorls -G -d . &>/dev/null && __color_ls_alias='colorls -G'
elif [[ "$OSTYPE" == (darwin|freebsd)* ]]; then
    ls -G . &>/dev/null && __color_ls_alias='ls -G'
    gls --color -d . &>/dev/null && __color_ls_alias='gls --color=tty'
else
    ls --color -d . &>/dev/null && __color_ls_alias='ls --color=tty' || { ls -G . &>/dev/null && __color_ls_alias='ls -G' }
fi