#!/bin/bash

# exit script on any fail
set -e

# exit script on any unbound variable
set -u

function update_template_value() {
  local file_name="${1}"
  local file_key="${2}"
  local file_value="${3}"
  local file_output="${4}"

  if [ ! -f "${file_name}" ]; then
    echo "ERROR: Unable to locate ${file_name}. Please supply the proper template to update."
    return $?
  fi

  cp "${file_name}" "${file_output}"
  echo "****** Writing VERSION key '${file_key}' at value '${file_value}'"
  sed -i "s/\%\%${file_key}\%\%/\%\%${file_value}\%\%/gi" ${file_output}
  return $?
}

function main() {
  local EXIT_SUCCESS=0
  local file_name="${1}"
  local file_key="${2}"
  local file_value="${3}"
  local file_output="${4}"
  echo ""
  echo "###########################################################"
  echo "######  UPDATE TEMPLATE VALUE INSIDE TEMPLATE FILE  #######"
  echo "###########################################################"

  # functon calls
  update_template_value ${file_name} ${file_key} ${file_value} ${file_output}
  exit "${EXIT_SUCCESS}"
}

#
# Main entry point
#
main "${@}"
