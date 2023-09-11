#!/bin/sh
declare -a words=("check" "quaint" "flamingo" "piano" "team" "hiccup" "cherry" "literature" "nomination" "diameter" "layer" "mutter" "tongue" "inspire" "amber" "rugby" "rescue" "width" "brush" "braid")
for word in "${words[@]}"
do
   curl "http://localhost:3000/search/catalog?query=$word"
done
