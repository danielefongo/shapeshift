mypath=${0:a:h}

configDir="$HOME/.shapeshift"
themeName="shapeshift.theme"
defaultFile="$configDir/default"

if [[ ! -d "$configDir" ]]; then
  mkdir -p "$configDir"
fi

function shapeshift-load() {
    source "$mypath/properties"

    if [[ -f "$defaultFile" ]]; then
      local chosenRepo=$(cat $defaultFile)
      local themeFile="$configDir/$chosenRepo/$themeName"

      if [[ -f "$themeFile" ]]; then
        source "$themeFile"
      fi
    fi
}

function shape-shift() {
  local repo=$1

  if [[ -z $repo ]]; then
    rm "$defaultFile" 2>/dev/null
  elif [[ -d "$configDir/$repo" ]]; then
    shapeshift-set $repo
  else
    shapeshift-import $repo
  fi

  shapeshift-load
}


function shapeshift-set() {
  local repo=$1

  local themeFile="$configDir/$repo/$themeName"

  if [[ -f "$themeFile" ]]; then
    echo $repo > "$defaultFile"
  else
    echo "Not existing theme"
    return
  fi
}

function shapeshift-import() {
  local repo=$1
  (
    if [[ ! -d $configDir/$repo ]]; then
      git clone "https://github.com/$repo" "$configDir/$repo" &>/dev/null
      if [[ $? -ne 0 ]]; then
        echo "Not a valid repo"
        return
      fi
    fi

    cd "$configDir/$repo"
    git pull &>/dev/null

    if [[ ! -f $themeName ]]; then
      echo "Not a valid theme"
      rm -rf "$configDir/$repo"
      return
    fi

    if [[ $? -ne 0 ]]; then
      echo "$repo is not a valid repo or already "
      return
    fi

    shapeshift-set $repo
  )
}

if declare -f antigen > /dev/null; then
  fpath+="$mypath/_shape-shift"
else
  source "$mypath/_shape-shift"
  autoload -U +X compinit && compinit
  compdef _shape-shift shape-shift
fi
