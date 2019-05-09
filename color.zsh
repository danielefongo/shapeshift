function colorize() {
  local text="$1"
  local color="$2"
  local bold=${3}

  if [[ $bold == true ]]; then
    text="%B${text}%b"
  fi

  echo "%{$fg[${color}]%}${text}%{$reset_color%}"
}

function colorizeArrow() {
  local text="$1"
  local okColor="$2"
  local koColor="$3"
  local bold=${4}

  if [[ $bold == true ]]; then
    text="%B${text}%b"
  fi
  echo "%(?.%{$fg[${okColor}]%}.%{$fg[${koColor}]%})${text}%{$reset_color%}"

}
