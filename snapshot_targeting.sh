#!/bin/bash

# title          :snapshot_retargeting.sh
# author         :Stephen Guiwits
# date           :20160603
# version        :0.1
# usage          :snapshot_retargeting.sh API-C.json {false/true}              -- Full Project
#                :snapshot_retargeting.sh regulated-domain {false/true} API-C  -- Single Repo
#                :Meant mainly to be used within https://rundeck.example.com
# bash_version   :4.1.2(1)-release 

# set up some aliases for mock block comments
[ -z $BASH ] || shopt -s expand_aliases
alias BEGINCOMMENT="if [ ]; then"
alias ENDCOMMENT="fi"

# git commands
git_fetch="git fetch --all"
git_clean="git clean -ffxd"
git_reset="git reset --hard @{u}"
git_master="git checkout -f master"
git_pull="git pull -p --all"

# Maven Plugin Commands (versions and release)
mvn_flags="-DallowSnapshots=true -Dincludes=com.exmple.*:*,com.example.*:*"
mvn_versions_update_parent="mvn versions:update-parent ${mvn_flags}"
mvn_versions_update_properties="mvn versions:update-properties ${mvn_flags}"
mvn_versions_use_latest_versions="mvn versions:use-latest-versions ${mvn_flags}"

# find pom.xml files in each directory and then
# git add / git commit them.
function find_poms_and_commit() {
  user=${RD_JOB_USERNAME}
  email="${RD_JOB_USERNAME}@example.com"
  cmd=`git rev-parse --show-toplevel`
  repo=`basename ${cmd}`
  comment="Updating pom.xml files for all pom's in ${repo}"
  for pom in `find . ! -path "*/target/*" -type f -name pom.xml`
  do
    echo "[DEBUG] adding pom ${pom} to git"
    git add $pom
  done
  echo "performing git commit with comment ${comment}"
  git commit -m "${comment}"
  git config --global user.name "${user}"
  git config --global user.email "${email}"
  git push 
  # Now set back the git config information to rundeck
  git config --global user.name "Rundeck User"
  git config --global user.email "rundeck@example.com"
}

# Upon failure of a maven command, it is usually best
# to delete the repository and re-clone. Might be overkill
# but better to be safe than to be sorry.
function delete_and_reclone() {
  cmd=`git rev-parse --show-toplevel`
  repo=`basename ${cmd}`
  reponame=`git remote show origin | grep Fetch | awk '{print $3}'`
  cd ..
  rm -rf ${repo}
  git clone "${reponame}"
  cd ${repo}
  ls -l
}

# use maven to create a snapshot of either a full project (ie TCOR) or a single
# repository under the project (ie funds-manager)
function snapshot() {
  order="${1}"
  dry_run=${2}

  # Loop through the order list and peform the proper git/maven commands to properly 
  # snapshot the projects.
  for i in "${order[@]}"
  do
    dir=$(echo "${i}" | cut -f2 -d" " )
    dir=${dir##*/}
    cd "${dir}"

    # mvn versions:use-next-snapshots
    echo "***** UPDATING repo at ${1} ..." 
    # git fetch --ffxd
    eval ${git_fetch}  >/dev/null 2>&1
    # git clean -f
    eval ${git_clean}  >/dev/null 2>&1
    # git checkout -f master
    # NOTE: This must be done _before_ git reset --hard @{u} to 
    # make sure you are on the correct branch (master).
    eval ${git_master} >/dev/null 2>&1
    # git reset --hard @{u}
    eval ${git_reset}  >/dev/null 2>&1
    # git pull -p --all
    eval ${git_pull}   >/dev/null 2>&1
    # mvn versions:update-parent
    echo "***** SNAPSHOTTING *****"
    echo ${mvn_versions_update_parent} && eval ${mvn_versions_update_parent} 
    if [ $? -ne 0 ]; then
     echo "ERROR: mvn versions:update-parent failed. Exiting"
     delete_and_reclone
    fi
    # mvn versions:update-properties -Dincludes=com.exmple.*:*,com.example.*:*
    echo ${mvn_versions_update_properties} && eval ${mvn_versions_update_properties} 
    if [ $? -ne 0 ]; then
      echo "ERROR: mvn versions:update-properties failed. Exiting"
      delete_and_reclone
    fi
    # mvn versions:use-latest-versions 
    echo ${mvn_versions_use_latest_versions} && eval ${mvn_versions_use_latest_versions}
    if [ $? -ne 0 ]; then
      echo "ERROR: mvn versions:use-latest-versions failed. Exiting"
      delete_and_reclone
    else
      echo "[DEBUG] Snapshot Retargeting SUCCEEDED!"
      git diff
      if [[ ${dry_run} != true ]]
      then
        echo "[DEBUG] Finding all pom.xml files and adding them to git. ..."
        find_poms_and_commit
      else
        echo "[DEBUG] NO COMMITS! ..."
        echo "***** DRY RUN *****"
      fi
    fi
    cd ..
  done
}

# Main Function
function main() {
  local filename=${1};
  local dry_run=${2};
  local repo_name=${3};

  # Array declaration to hold project/repo names
  declare -a order

  # If a file name is given (ie API-C.repo) then
  if [[ ${filename: -5} == ".json" ]]
  then
    # get the directory of the repo based off prefix of the filename
    dir=${filename%.*}
    
    # read the data from the file
    while read -r line; do
      repo_list+=("$line")
    done < "${filename}"

    # change to the repo directory
    if [[ ! -z "${dir}" ]]
    then
      dir=${dir##*/}
      cd /usr/local/example/src/${dir}
    fi

    # clean up the '[]' inside the string
    repo_list=`echo "${repo_list}" | tr -d '[]'`
  
    # loop through the list and pupulate the order array
    OIFS=$IFS
    IFS=","
    for x in ${repo_list}
    do
      order+=(`echo "$x" | sed 's/"//g'`)
    done
    IFS=$OIFS
  else
    # only checking on one repository so just switch to the project then
    # check the repo that was passed in as an argument
    if [[ ! -z "${repo_name}" ]]
    then
      if [[ -d "/usr/local/example/src/${repo_name}" ]]
      then
        cd /usr/local/example/src/${repo_name}
      else
         echo "Directory ${repo_name} doesn't exists"
      fi
    else
      echo "No value given for repository name. Can't locate directory."
      echo "Please add the argument repo_name as the 5th argument (ie API-LB)"
      exit 1
    fi
    order=(${filename}) 
  fi

  # call the snapshot function now that all the variables and paths are set up. 
  snapshot ${order} ${dry_run};
}

# Main Entry Point
main "${@}"
