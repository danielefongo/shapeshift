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


function shape-reshape() {
  find "$configDir" -mindepth 2 -maxdepth 2 -type d | sed -E 's/.*\.shapeshift\///' | while read repo; do
  (
    cd "$configDir/$repo"
    git fetch &>/dev/null

    UPSTREAM=${1:-'@{u}'}
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @ "$UPSTREAM")

    if [ $LOCAL != $REMOTE -a $LOCAL = $BASE ]; then
      git pull &>/dev/null
      echo "$repo updated."
    fi
  )
  done

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

    if [[ ! -f "$configDir/$repo/$themeName" ]]; then
      echo "Not a valid theme"
      rm -rf "$configDir/$repo"
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
