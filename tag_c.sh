#!/bin/bash

#
# Main function
#
function main() {
  file="${1}"
  while IFS= read -r line; do
    version="$line"
  done < "$file"

  if [[ "${version}" == *"."* ]]
  then
    major="${version%.*}"
    minor="${version##*.}"
    minor=$((minor+1))
    new_version="${major}.${minor}"
    echo "The old version is ${version} and the new version is ${new_version}"
    echo "${new_version}" > ${file}
  elif [[ "${version}" =~ ^v[0-9]{4}(0[0-9]|1[0-2])([0-2][0-9]|3[0-1])$ ]]
  then
    new_version="v$(date +'%Y%m%d')"
    echo "The old version is ${version} and the new version is ${new_version}"
    echo "${new_version}" > ${file}
  else
   echo "No version patter was found to update. Exiting ..."
   exit 1 
  fi

  echo
  echo "Version incremented as requested. Exiting cleanly."
  echo
}

#
# Main entry point
#
main "${@}"

