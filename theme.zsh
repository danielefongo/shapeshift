mypath=${0:a:h}

configDir="$HOME/.zpure"
themeName="zpure.theme"
defaultFile="$configDir/default"

if [[ ! -d "$configDir" ]]; then
  mkdir -p "$configDir"
fi

function zpure-load() {
    source "$mypath/properties"

    if [[ -f "$defaultFile" ]]; then
      local chosenRepo=$(cat $defaultFile)
      local themeFile="$configDir/$chosenRepo/$themeName"

      if [[ -f "$themeFile" ]]; then
        source "$themeFile"
      fi
    fi
}

function zpure-set() {
  local repo=$1

  if [[ -z $repo ]]; then
    rm "$defaultFile" 2>/dev/null
  else
    local themeFile="$configDir/$repo/$themeName"

    if [[ -f "$themeFile" ]]; then
      echo $repo > "$defaultFile"
    else
      echo "Not existing theme"
      return
    fi
  fi
  zpure-load
}

function zpure-import() {
  local repo=$1
  if [[ -z $repo ]]; then
    echo "Pass repo as parameter (eg: danielefongo/fish-zpure)"
    return
  fi
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

    zpure-set $repo
  )
}


if declare -f antigen > /dev/null; then
  fpath+="$mypath/_zpure-set"
else
  source "$mypath/_zpure-set"
  autoload -U +X compinit && compinit
  compdef _zpure-set zpure-set
fi