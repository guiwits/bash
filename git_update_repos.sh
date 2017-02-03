#!/bin/bash

#
# Usage function: show script usage upon failure of arguments given
#
function usage() {
cat << EOF
Format: $(basename "$0") -a  -f [filename]
OPTIONS:
  -a    Automated running of the script to clone all repos from a list.
  -f    filename. Read in a supplied filename with a repo to clone

EXAMPLE(s):
  ./git_update_repos.sh -f API-C.json
  ./git_update_repos.sh -a
EOF
}

#
# Given a specific file, update the git repo based on the contents of that file.
# File should be in JSON format.
#
function update_git_repo_filename() {
  fp=${1}
  dir=${1##*/}
  dir=${dir%.*}
  lines=`cat $fp`
  for line in $lines; do
    repo_list=$line
  done

  # clean up the [] and any spaces from the repo list
  repo_list=`echo "${repo_list}" | tr -d '[]'`
  repo_list=`echo "${repo_list}" | tr -d ' '`

  # Loop through the list and populate the order array
  declare -a repos
  OIFS=$IFS
  IFS=","
  for x in ${repo_list}
  do
    repos+=(`echo "$x" | sed 's/"//g'`)
  done
  IFS=$OIFS

  # cd to directory and either git pull or git clone
  cd src/${dir}
  for i in "${repos[@]}"
  do
    giturl="ssh://git@stash.example.com:7999/${dir}/${i}.git"
    if [ -d "${i}" ]; then
      cd ${i}
      echo "###  Updating git repository (${dir} :: ${i})  ###"
      git fetch --all -v
      git clean -ffxd
      git checkout -f master
      git pull -p
      cd ..
    else
      echo "###  Cloning ${giturl}  ###"
      git clone ${giturl}
    fi
  done
}

#
# Update git repository based off the automated flag. It will read a file
# of certain repos, use the REST web server to get each repository, then
# clone the master and all branches.
#
function update_git_repo_automated() {
  fp=${1}
  dir=${1##*/}
  dir=${dir%.*}

  user="user"
  token="tokenstring"
  url="https://stash.example.com/rest/api/1.0/projects"

  lines=`cat $fp`
  for line in $lines; do
    repo_list=$line
  done

  # clean up the [] and any spaces from the repo list
  repo_list=`echo "${repo_list}" | tr -d '[]'`
  repo_list=`echo "${repo_list}" | tr -d ' '`

  # Loop through the list and populate the order array
  declare -a repos
  OIFS=$IFS
  IFS=","
  for x in ${repo_list}
  do
    repos+=(`echo "$x" | sed 's/"//g'`)
  done
  IFS=$OIFS

  # cd to directory and either git pull or git clone
  cd src/${dir}
  for i in "${repos[@]}"
  do
    giturl="ssh://git@stash.example.com:7999/${dir}/${i}.git"
    if [ -d "${i}" ]; then
      cd ${i}
      echo "###  Updating git repository (${dir} :: ${i})  ###"
      git fetch --all -v
      git clean -ffxd
      git checkout -f master
      git pull -p
      cd ..
    else
      echo "###  Cloning ${giturl}  ###"
      git clone ${giturl}
    fi
  done
}

#
# Main
#
function main() {
  local automated_run=0
  local filename=""

  while getopts ":f:a" OPTION "${@}" ;
  do 
    case $OPTION in
      a)
        automated_run=1
        ;;
      f)
        filename="${OPTARG}" 
        ;;
      *)
        usage 
        exit 1
        ;;
    esac
  done
       
  if [[ "${automated_run}" -ne 0 ]]
  then
    echo "Running in auto mode"
    update_git_repo_automated "ALWAYS_CLONE.json"
  fi

  if [[ ! -z "${filename}" ]]
  then
    echo "${filename}"
  fi

  update_git_repo $1
}

main "$@"

