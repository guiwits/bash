#!/bin/bash

# title          :tag_project.sh
# description    :Checks to see if a repository needs to be tagged or not. 
#                 Can check a full project or single repository.
# author         :Stephen Guiwits
# date           :20160519
# version        :0.1
# usage          :/usr/local/example/tag_project.sh /usr/local/example/API-C.json \
#                 false 2 true API-C
#                : Meant mainly to be used within https://rundeck.example.com
# bash_version   :4.1.2(1)-release

#
# Maven Plugin Commands (versions and release)
#
###############################################################################################
# versions plugin: http://www.mojohaus.org/versions-maven-plugin/index.html                   #
#                                                                                             #
# versions:update-parent                                                                      #
# Updates the parent section of a project so that it references the newest available version. #
# For example, if you use a corporate root POM, this goal can be helpful if you need to       #
# ensure you are using the latest version of the corporate root POM.                          #
#                                                                                             #
# versions:update-properties                                                                  #
# Updates properties defined in a project so that they correspond to the latest available     #
# version of specific dependencies.                                                           #
#                                                                                             #
# versions:use-latest-versions                                                                #
# Searches the pom for all versions which have been a newer version and replaces them with    #
# the latest version.                                                                         #
#                                                                                             #
# versions:use-next-snapshots                                                                 #
# Searches the pom for all non-SNAPSHOT versions which have been a newer -SNAPSHOT version    #
# and replaces them with the next -SNAPSHOT version.versions:use-next-snapshots searches the  #
# pom for all non-SNAPSHOT versions which have been a newer -SNAPSHOT version and replaces    #
# them with the next -SNAPSHOT version.                                                       #
###############################################################################################
mvn_versions_update_parent="mvn versions:update-parent"
mvn_versions_update_properties="mvn versions:update-properties -Dincludes=com.example.*:*,com.example.*:*"
mvn_versions_use_latest_versions="mvn versions:use-latest-versions -Dincludes=com.example.*:*,com.example.*:*"
mvn_versions_use_next_snapshot="mvn versions:use-next-snapshots -DallowSnapshots=true -Dincludes=com.example.*:*,com.example.*:*"
###############################################################################################
# release plugin: https://maven.apache.org/maven-release/maven-release-plugin/                #
#                                                                                             #
# release:clean                                                                               #
# Clean up after a release preparation. This is done automatically after a successful         #
# release:perform, so is best served for cleaning up a failed or abandoned release,           #
# or a dry run.                                                                               #
#                                                                                             #
# release:prepare                                                                             #
# Prepare for a release in SCM. Steps through several phases to ensure the POM is ready to be #
# released and then prepares SCM to eventually contain a tagged version of the release and a  #
# record in the local copy of the parameters used.                                            #
# This can be followed by a call to release:perform                                           #
#                                                                                             #
# release:perform                                                                             #
# Perform a release from SCM, either from a specified tag, or the tag representing the        #
# previous release in the working copy created by release:prepare.                            #
#                                                                                             #
# Can add -X -e  for more verbosity. ie mvn -B -X -e release:prepare                          #
###############################################################################################
mvn_release_clean="mvn release:clean"
mvn_release_prepare="mvn -B release:prepare"
mvn_release_perform="mvn -B release:perform"

#
# Git Commands
#
###############################################################################################
# git clean -f                                                                                #
# Reset the staging area and the working directory to match the most recent commit.           #
#                                                                                             #
# git fetch --all                                                                             #
# Downloads objects and refs from another repository; --all means to fetch all remotes.       #
#                                                                                             #
# git reset --hard                                                                            #
# In addition to unstaging changes, the --hard flag tells Git to overwrite all changes        #
# in the working directory, too.                                                              #
# Put another way: this obliterates all uncommitted changes.                                  #
#                                                                                             #
# git pull --all                                                                              #
# Fetch from and integrate with another repository or a local branch; --all fetches all       #
# remotes.                                                                                    #
#                                                                                             #
# git status                                                                                  #
# Displays paths that have differences between the index file and the current HEAD commit,    #
# paths that have differences between the working tree and the index file, and paths in the   #
# working tree that are not tracked by Git.                                                   #
#                                                                                             #
# git diff                                                                                    #
# Show changes between the working tree and the index or a tree, changes between the index    #
# and a tree, changes between two trees, changes between two blob objects, or changes between #
# two files on disk.                                                                          #
###############################################################################################
git_fetch="git fetch --all"
git_clean="git clean -ffxd"
git_reset="git reset --hard @{u}"
git_master="git checkout -f master"
git_pull="git pull -p --all"
git_status="git status"
git_diff="git diff"

#
# number_of_commits_since_last_tag
# Returns the number of commits since
# the last tag
#
# git describe --abbrev=0 --tags
# git log <lasttag>..HEAD --oneline
#
function tag_or_not() {
  num_commits="${1}"
  recent_tag=$(git describe --abbrev=0 --tags 2>&1)
  if [[ "${recent_tag}" == "fatal: No names found, cannot describe anything." ]]
  then
    commits_since_tag=0
    echo "${commits_since_tag}"
  else
    commits_since_tag=$(git log "${recent_tag}"..HEAD --oneline | wc -l)
    echo "${commits_since_tag}"
  fi
}

#
# Find pom.xml files in each directory and then
# git add / git commit them.
#
function find_poms_and_commit() {
  cmd=$(git rev-parse --show-toplevel)
  repo=$(basename "${cmd}")
  comment="Updating pom.xml files for all pom's in ${repo}"
  for pom in $(find . ! -path "*/target/*" -type f -name pom.xml)
  do
    echo "[DEBUG] adding pom ${pom} to git"
    git add $pom
  done
  echo "performing git commit with comment ${comment}"
  git commit -m "${comment}"
  git push
}

#
# Upon failure of a maven command, it is usually best
# to delete the repository and re-clone. Might be overkill
# but better to be safe than to be sorry.
#
function delete_and_reclone() {
  cmd=`git rev-parse --show-toplevel`
  repo=`basename ${cmd}`
  reponame=`git remote show origin | grep Fetch | awk '{print $3}'`
  cd ..
  rm -rf ${repo}
  git clone "${reponame}"
  echo "[DEBUG]*******************************************************[DEBUG]"
  echo "[DEBUG] Due to a Maven failure, the repo at ...               [DEBUG]"
  echo "[DEBUG] *************** ${repo} ***************               [DEBUG]" 
  echo "[DEBUG] was deleted and re-cloned. Please fix any errors that [DEBUG]" 
  echo "[DEBUG] caused the failure and re-run tagging. Thank You.     [DEBUG]"
  echo "[DEBUG]*******************************************************[DEBUG]"
  cd ${repo}
  ls -l
  exit 1
}

#
# Main function that runs through the repo list and determines if
# a tag is required for a certain repository or not.
#
function tag_repository() {
  # get order from passed parameter. The order is the project order to tag
  order="${1}"
  snapshot="${2}" # whether or not to snaphot
  commit_count="${3}"
  dry_run="${4}"  
  tag_name_format="${5}"
    
  git_user=${RD_JOB_USERNAME}
  git_user_email="${RD_JOB_USERNAME}@example.com"
  git config --global user.name "${git_user}"
  git config --global user.email "${git_user_email}"

  #
  # Loop through the order list and peform the proper git/maven commands to properly tag
  # the projects.
  #
  for i in "${order[@]}"
  do
    dir=$(echo "${i}" | cut -f2 -d" " )
    dir=${dir##*/}
   
    cd "${dir}"

    # git fetch --all
    if [ "${dry_run}" == "true" ]; then
      eval ${git_fetch} > /dev/null 2>&1
    else
      echo ${git_fetch} && eval ${git_fetch} >/dev/null 2>&1
    fi

    # git clean -ffxd
    if [ "${dry_run}" == "true" ]; then
      eval ${git_clean} >/dev/null 2>&1
    else
      echo ${git_clean} && eval ${git_clean}
    fi

    # git checkout -f master
    # NOTE: This must be done _before_ git reset --hard @{u} to 
    # make sure you are on the correct branch (master).
    if [ "${dry_run}" == "true" ]; then
      eval ${git_master} >/dev/null 2>&1
    else
      eval ${git_master} >/dev/null 2>&1
    fi

    # git reset --hard @{u}
    eval ${git_reset} >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo "ERROR: git reset --hard HEAD failed. Exiting"
      exit 1
    fi

    # git status
    if [ "${dry_run}" ==  "true" ]; then
      eval ${git_status} >/dev/null 2>&1
    else
      echo ${git_status} && eval ${git_status}
    fi

    # git pull -p --all
    if [ "${dry_run}" == "true" ]; then
      eval ${git_pull} >/dev/null 2>&1
      if [ $? -ne 0 ]; then
        echo "ERROR: git pull -p --all failed. Exiting"
        exit 1
      fi
    else
      echo ${git_pull} && eval ${git_pull}
      if [ $? -ne 0 ]; then
        echo "ERROR: git pull -p --all failed. Exiting"
        exit 1
      fi
    fi

    # mvn release:clean
    if [ "${dry_run}" == "true" ]; then
      eval ${mvn_release_clean} >/dev/null 2>&1
      if [ $? -ne 0 ]; then
        echo "ERROR: mvn release:clean failed. Exiting"
        delete_and_reclone
      fi
    fi

    # mvn versions:update-parent
    echo ${mvn_versions_update_parent} && eval ${mvn_versions_update_parent}
    if [ $? -ne 0 ]; then
      echo "ERROR: mvn versions:update-parent failed. Exiting"
      delete_and_reclone
    fi

    # mvn versions:update-properties -Dincludes=com.example.*:*,com.example.*:*
    echo ${mvn_versions_update_properties} && eval ${mvn_versions_update_properties}
    if [ $? -ne 0 ]; then
      echo "ERROR: mvn versions:update-properties failed. Exiting"
      delete_and_reclone
    fi

    # mvn versions:use-latest-versions -Dincludes=com.example.*:*,com.example.*:*
    echo ${mvn_versions_use_latest_versions} && eval ${mvn_versions_use_latest_versions}
    if [ $? -ne 0 ]; then
      echo "ERROR: mvn versions:use-latest-versions failed. Exiting"
      delete_and_reclone
    fi

    # Check source for change (should be limited to POMs)
    pom_change="$( git diff --name-status --exit-code | wc -l )" ;
    # Check if number of commits surpass threshold to force tag
    num_commits="$(tag_or_not ${commit_count})" ;
    # If number of commits since last tag is less than threshold and POM is unchanged
    # then a tag is NOT needed else if number of commits since last tag is greater 
    # than threshold OR the POM was changed then a tag is needed
    if [ "${num_commits}" -lt "2" ] && [ "${pom_change}" == "0" ]; then
      echo "**** PROJECT -- ${dir}"
      echo "****  STATUS: NO TAG  ****"
      echo "****  NOTE: In FULLTAG mode tag will occur if upstream deps are tagged."
      if [ "${dry_run}" == "true" ]; then
        echo "****     DRY  RUN     ****"
      fi
      echo
      cd ..
      continue
#    elif [ "${num_commits}" -gt "2" ] || [ "${pom_change}" != "0" ]; then 
    else 
      echo "**** VALIDATING BUILD -- ${dir}"
      # Validate POM changes, pre-commit. If error after run, echo out build release failed because new dependencies broke it.
      echo "mvn -U clean install -DskipTests"
      mvn -U clean install -DskipTests >/dev/null 2>&1
      if [ $? -ne 0 ]; then
        echo "ERROR: Maven build failed either due to new dependencies that have been "
        echo "       introduced or compile failures in the codebase. Fix and retry."
        delete_and_reclone
        exit 1
      else
        mvn -U clean
      fi
      echo "**** PROJECT -- ${dir}"
      echo "**** STATUS: WILL TAG ****"
      if [ "${dry_run}" == "true" ]; then
        echo "****     DRY  RUN     ****"
        echo
        cd ..
        continue
      else
        echo
      fi
    fi

    # mvn release:prepare
    if [ "${tag_name_format}" == "" ]; then
      echo ${mvn_release_prepare} && eval ${mvn_release_prepare}
    else
      mvn -B -DtagNameFormat=${tag_name_format} release:prepare
    fi
    if [ $? -ne 0 ]; then
      echo "ERROR: mvn release:prepare failed. Exiting"
      echo "ERROR: Release failed during preparation stage where the tags and commits are pushed up to version control"
      delete_and_reclone
    fi
    echo

    # mvn release:peform
    echo
    echo ${mvn_release_perform} && eval ${mvn_release_perform}
    if [ $? -ne 0 ]; then
      echo "ERROR: mvn release:perform failed. Exiting"
      echo "ERROR: Maven Release failed during push to the artifact repository"
      delete_and_reclone
    fi
    echo

    # mvn versions:use-next-snapshots
    if [[ ${snapshot} == true ]]
    then
      echo ${mvn_versions_use_next_snapshot} && eval ${mvn_versions_use_next_snapshot}
      if [ $? -ne 0 ]; then
        echo "ERROR: mvn versions:use-next-snapshots failed. Exiting"
        delete_and_reclone
      else
        echo "[DEBUG] mvn versions:use-next-snapshots succeeded."
        echo "[DEBUG] Finding all pom.xml files and adding them to git"
        find_poms_and_commit
      fi
    fi
    # return to parent dir after successful tag. ...
    cd ..
  done
  # Reset git config --global
  git config --global user.name "Rundeck User"
  git config --global user.email "rundeck@example.com"
}

#
# Main
#
function main() {
  local fp=$1; 
  local snapshot_retargeting=$2;   # $RD_OPTION_SNAPSHOT_RETARGETING
  local commit_number=$3;          # number of commits since tag to switch off of
  local dry_run=$4;                # Run full sweet or just report on tagging or not
  local repo_name=$5;              # Name of the top level project. Only needed when a single
                                   # module is called.
  local tag_name_format=$6;        # OPTIONAL: Pass new tag format to maven release with 
                                   #           -DtagNameFormat=${whatever}
  #
  # Array declaration and populate.
  #
  declare -a order

  #
  # If a file name is given (ie API-C.repo) then 
  if [[ ${fp: -5} == ".json" ]]
  then
    #
    # Get the dirctory of the repo based off prefix of the filename
    #
    dir=${fp%.*}

    #
    # Read the data from the file pointed to by $fp
    #
    while read -r line; do
      repo_list+=("$line")
    done < "${fp}"

    #
    # change to the repo directory
    #
    if [[ ! -z "${dir}" ]]
    then
      dir=${dir##*/}
      cd /usr/local/example/src/${dir}
    fi
     
    #
    # Clean up the '[]' inside the string
    #
    repo_list=`echo "${repo_list}" | tr -d '[]'`

    #
    # Loop through the list and populate the order array
    #
    OIFS=$IFS
    IFS=","
    for x in ${repo_list}
    do
      order+=(`echo "$x" | sed 's/"//g'`)
    done
  else
     #
     # Only checking on one repository so just switch to the project then
     # check the repo that was passed in as an argument
     #
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
     order=(${fp})
  fi
  IFS=$OIFS

  # Function calls
  tag_repository ${order} ${snapshot_retargeting} ${commit_number} ${dry_run} ${tag_name_format}
}

main "$@"

exit 0 ;

