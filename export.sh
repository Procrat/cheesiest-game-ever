#!/bin/bash

set -euo pipefail


declare -A TARGETS EXTENSIONS

TARGETS['linux']='Linux X11'
TARGETS['macos']='Mac OSX'
TARGETS['windows-desktop']='Windows Desktop'
TARGETS['windows-tablet']='Windows Universal'

EXTENSIONS['linux']=''
EXTENSIONS['macos']='.zip'
EXTENSIONS['windows-desktop']='.exe'
EXTENSIONS['windows-tablet']='.appx'


out_dir=$(realpath "$1")
cd "$(dirname "${BASH_SOURCE[0]}")"

# HTML5 export
rm "${out_dir:?}/"{data.pck,game*}
godot -export "HTML5" "${out_dir:?}/game.html"

# Native exports
for target in "${!TARGETS[@]}"; do
    target_dir="${out_dir:?}/builds/${target}"
    rm -rf "$target_dir"
    mkdir -p "$target_dir"
    godot -export "${TARGETS[$target]}" "${target_dir}/cheesiest-game-ever${EXTENSIONS[$target]}"
done
