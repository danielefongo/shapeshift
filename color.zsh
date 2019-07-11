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

  print -n "%F{$color}${text}%f"
}

function colorize_from_status() {
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

  if [[ $__shapeshift_last_command_status -eq 0 ]]; then
    print -n "%F{$okColor}${okText}%f"
  else
    print -n "%F{$koColor}${koText}%f"
  fi
}
