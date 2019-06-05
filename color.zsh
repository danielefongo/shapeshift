setopt promptsubst
setopt promptpercent
autoload -U colors && colors

function colorize() {
  local text="$1"
  local color="$2"
  local bold=${3}

  if [[ $text == "" ]]; then
    return
  fi

  if [[ $bold == true ]]; then
    text="%B${text}%b"
  fi

  echo "%F{$color}${text}%f"
}

function colorizeFromStatus() {
  local okText="$1"
  local okColor="$2"
  local okBold=${3}

  local koText="$4"
  local koColor="$5"
  local koBold=${6}


  if [[ $okBold == true ]]; then
    okText="%B${okText}%b"
  fi

  if [[ $koBold == true ]]; then
    koText="%B${koText}%b"
  fi

  echo "%(?.%F{$okColor}${okText}.%F{$koColor}${koText})%f"
}
