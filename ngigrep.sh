#! /usr/bin/env nix-shell
#! nix-shell -p wget pup xclip -i bash

set -x

#https://stackoverflow.com/questions/59895/how-can-i-get-the-source-directory-of-a-bash-script-from-within-the-script-itsel
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ud=${USEDIR:-out-`date +%s`}
out=$DIR/$ud
mkdir -p "$out"

fetchproj () {
  local htmlname=$1

  #Each of these helps get a column for the table.

  # Get project names and page url
  cat "$out/$htmlname" | pup "dt strong text{}" > "$out/name"
  # parse project home page location
  if [ ! -d cache ]; then
    mkdir -p cache;
    pushd cache
    pup -f "$out/$htmlname" "dt a attr{href}" | while IFS= read -r suburl; do
      wget "https://nlnet.nl$suburl/" -O "$(cut -d / -f 3 <<< $suburl).html"
    done
  popd
  fi

  rm "$out/projurl"
  for f in cache/*.html; do pup -f "$f" 'div[class="abstract"] + ul a attr{href}' >> "$out/projurl"; done
  }

fetchdisc (){
  pushd "$out"
  if [ ! -f NGIZeroDiscovery.html ]; then wget https://nlnet.nl/thema/NGIZeroDiscovery.html; fi
  fetchproj NGIZeroDiscovery.html
  }

fetchpet (){
  pushd "$out"
  if [ ! -f NGIZeroPET.html ]; then wget https://nlnet.nl/thema/NGIZeroPET.html; fi
  fetchproj NGIZeroPET.html
  }

fetchdisc

echo USEDIR=$ud $0
