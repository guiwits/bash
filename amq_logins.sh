#!/bin/bash

#
# Main function
#
function main() {
  local amq_log_file="${1}"
  local count=0

  declare -a users
  
  while read line
  do
    if [[ "${line}" == *"connect"* ]]
    then
      count=$((count+1))
      echo "${line}"
    fi
  done < "${amq_log_file}"

  echo "The final line count is ${count}"
}

#
# Main entry
#
main "${@}"
