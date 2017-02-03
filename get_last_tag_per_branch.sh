#!/bin/bash

function get_last_tag() {
  local project="${1}"
  local repo="${2}"
  local branch="${3}"
  local depth="${4:-80}"
  cd /usr/local/data/src/${project}/${repo}
  git checkout ${branch}

  for tag_hash in $( git rev-list --max-count=${depth} HEAD ) 
  do
    tag_version=$( git tag --contains ${tag_hash} )
    if [[ ! "" == "${tag_version}" ]]
    then 
      echo "Tag (git tag --contains <hash>): ${tag_version}"
      break 
    fi 
  done

  if [[ -z ${tag_version} ]]
  then
    echo "No tag found. Using --abbrev 0"
    tag_version=$( git describe --abbrev=0 --tags --always )
    echo "Tag (git describe --abbrev=0 --tags --always): ${tag_version}"
  fi 
}

function main() {
  local project="${1}"
  local repo="${2}"
  local branch="${3}"
  local depth="${4}"
  get_last_tag ${project} ${repo} ${branch} ${depth}
}

main "${@}"
