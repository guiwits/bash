#!/bin/bash

#
# cat all the chanfiles together to create a unique set of metadata.
#
function create_file() {

  # cat all files into one file named chanfile_all.dat
  # remove comments with: sed 's/#.*$//g' chanfile_all.dat 
  # remove all blank line: sed '/^\s*$/d'
  
  local file1="${1}"
  local file2="${2}"
  local file3="${3}"
  local file4="${4}"
  
  if [[ -n "${file1}" ]]
  then
    echo " ${file1}"
    $(cat ${file1} >> chanfile_all.dat)
  fi

  if [[ -n "${file2}" ]]
  then
    echo " ${file2}"
    $(cat ${file2} >> chanfile_all.dat)
  fi

  if [[ -n "${file3}" ]]
  then
    echo " ${file3}"
    $(cat ${file3} >> chanfile_all.dat)
  fi

  if [[ -n "${file4}" ]]
  then
    echo " ${file4}"
    $(cat ${file4} >> chanfile_all.dat)
  fi

  # Now that all the files are in one file we need to remove comments
  sed -i 's/#.*$//g' chanfile_all.dat 
  # remove all blank lines 
  sed -i '/^\s*$/d' chanfile_all.dat

}

#
# Main
#
function main() {
  while getopts ":b:c:n:w:" opt; do
    case ${opt} in
      b )
        bkfile=$OPTARG
        ;;
      c )
        cifile=$OPTARG
        ;;
      n )
        ncfile=$OPTARG
        ;;
      w )
        uwfile=$OPTARG
        ;;
      \? )
        echo "Invalid option: $OPTARG" 1>&2
        ;;
      : )
        echo "Invalid option: $OPTARG requires an argument" 1>&2
        ;;
    esac
  done
  shift $((OPTIND -1))

  if [[ -n ${bkfile} && -n ${cifile} && -n ${ncfile} && -n ${uwfile} ]]
  then
    echo "All channel passed in. Sending to create_file()"
    create_file ${bkfile} ${cifile} ${ncfile} ${uwfile} 
  elif [[ -n ${cifile} && -n ${ncfile} && -n ${uwfile} ]]
  then
    echo "BK channel file missing. Passing in the others"
    create_file ${cifile} ${ncfile} ${uwfile} 
  elif [[ -n ${bkfile} && -n ${ncfile} && -n ${uwfile} ]]
  then
    echo "CI channel file missing. Passing in the others"
    create_file ${bkfile} ${ncfile} ${uwfile} 
  elif [[ -n ${bkfile} && -n ${cifile} && -n ${uwfile} ]]
  then
    echo "NC channel file missing. Passing in the others"
    create_file ${bkfile} ${cifile} ${uwfile} 
  elif [[ -n ${bkfile} && -n ${cifile} && -n ${ncfile} ]]
  then
    echo "UW channel file missing. Passing in the others"
    create_file ${bkfile} ${cifile} ${ncfile} 
  fi

}

#
# Main function entry
#
main "${@}"
