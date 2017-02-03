#!/bin/bash

#
# Updates the MongoDB on the remote host with the newly uploaded
# JSON file using mongoimport
# ex: mongoimport --db DBNAME --collection COLLECTIONNAME --type file.json
#
function mongo_insert_remote() {
  local web_server="${1}"
  local json_file="${2}"
  local time="${3}"
  dir="/path/to/files/web-results/${time}"
  echo "Executing mongoimport --db DB --collection COLLECTION --type json --file ${dir}/${json_file}"
  ssh user@${web_server} mongoimport --db DB --collection COLLECTION --type json --file ${dir}/${json_file}
  if [[ "${?}" -eq 0 ]]
  then
    echo "MongoDB import was successful. Please verify that all looks fine on the website"
  else
    echo "MongoDB import failed. Please check into the reason."
    exit 1
  fi
}

#
# Removes any instance of a password in configuration files that will be copied
# up to the web server.
#  
function replace_passwords() {
  declare -a pwords
  local conf_dir="${1}"
  local algo="${2}"
  local str_replace="*** Omitted due to password in line"

  cp -r "${conf_dir}" /tmp/${algo}
  for f in $(ls /tmp/${algo})
  do
    pw=$(cat /tmp/${algo}/${f} | grep -v '^#' | grep -i password)
    for word in $pw
    do
      pwords+=($word)
    done

    if [[ ! -z "${pw}" ]]
    then
      for idx in "${!pwords[@]}"
      do
        if [[ ! $((${idx} % 2)) == 0 ]]
        then
	        ptmp=${pwords[idx]}
          if [[ ! "${ptmp}" == "unused" ]]
          then
            sed -i -e "s/$ptmp/$str_replace/" /tmp/${algo}/${f}
	        fi
        fi
      done
    fi
  done
}

#
# Copies the configuration files for each algorithm up to the web server along
# with the json and txt files. (Currently o, e, v)
#
function copy_algo_config_files() {
  local web_server="${1}"
  local tld="${2}"
  local time="${3}"
  local o_conf="/o/run"
  local e_conf="/e/run"
  local v_conf="/v/run"
  local d_conf="/d/run"

  # Can't do anything without the time variable. Exit if not sent.
  if [[ -z "${time}" ]]
  then
    echo "Time was not passed into the script. Script will fail without out. Exiting"
    exit 1
  fi

  # Copy each conf file in alg_conf to the server
  for i in "${o_conf}" "${e_conf}" "${v_conf}" "${d_conf}";
  do
    if [[ ! -d "${i}" ]]
    then
      echo "${i} is not a valid directory."
    else
      algo=$(echo $i | awk -F"/" '{print $3}')
      replace_passwords "${i}" "${algo}"
      echo "Copying configuration files for ${algo} to ${web_server}"
      ssh user@${web_server} mkdir ${tld}/${time}/${algo}
      scp -r /tmp/${algo}/* user@${web_server}:${tld}/${time}/${algo}
      # Remove the temporary algorithm configuration files from /tmp
      rm -rf /tmp/${algo}      
    fi
  done
}

#
# Copies the performance data from the run (logs/taglogs/<tag>) 
# to host.example.com (or web_server) files/web-results/<tag>
#
function copy_performance_files() {
  local web_server="${1}"
  local tag="${2}"
  local remote_dir="/path/to/www"
  local tag_dir="/path/to/logs/taglogs"
  ssh user@${web_server} mkdir -p ${remote_dir}/${tag}
  if [[ -d "${tag_dir}/${tag}" ]]
  then
    scp -r ${tag_dir}/${tag}/*.gz user@${web_server}:${remote_dir}/${tag}
  else
    echo "Wasn't able to scp anything from ${tag_dir}/${tag}. Please check directory"
  fi
}

#
# Copies the algorithm log files from logs/taglogs/<tag>
#
function copy_algo_log_files() {
  local web_server="${1}"
  local tld="${2}"
  local time="${3}"
  local tag="${4}"
  local tag_dir="/path/to/logs/taglogs"
  ssh user@${web_server} mkdir -p ${tld}/${time}/logs/algo_logs
  if [[ -d "${tag_dir}/${tag}" ]]
  then
    scp -r ${tag_dir}/${tag}/*.log user@${web_server}:${tld}/${time}/logs/algo_logs
  else
    echo "Wasn't able to scp anything from ${tag_dir}/${tag}. Please check directory"
  fi
}

#
# Looks for the two types of files (results_<dateTtime>.json and .txt to
# upload to the remote web server.
#
function upload_files() {
  local web_server="${1}"
  local tld="${2}"
  local time="${3}"
  local tag="${4}"
  local files_dir="/path/to/results/${time}"
  local json_file="results_${time}.json"
  local text_file="results_${time}.txt"
  local input_text_file="input_for_results_${time}.txt"

  # Verify files exist is files_dir and scp them to the remote host
  if [[ ! -f "${files_dir}/${json_file}" && ! -f "${files_dir}/${text_file}" && ! -f "${files_dir}/${input_text_file}" ]]
  then
    echo "Those files don't exist. Please investigate"
    exit 1
  else
    echo "Copying file ${json_file} and ${text_file} and ${input_text_file} to ${web_server}"
    scp ${files_dir}/${json_file} ${files_dir}/${text_file} ${files_dir}/${input_text_file} user@${web_server}:${tld}/${time}
  fi

  copy_algo_config_files ${web_server} ${tld} ${time}
  copy_algo_log_files ${web_server} ${tld} ${time} ${tag}
  copy_performance_files ${web_server} ${tag}
  mongo_insert_remote ${web_server} ${json_file} ${time}
}

# 
# Creates the required file directory on the remote server and calls the
# upload function.
#
function make_remote_directory() {
  local web_server="${1}"
  local tld="${2}"
  local time="${3}"
  local tag="${4}"
 
  if [[ -z "${time}" ]]
  then
    echo "Time was not passed into the script. Script will fail without out. Exiting"
    exit 1
  fi

  # create the directory structure based on the time format
  dir="${tld}/${time}"

  # ssh to the web server and create the directory
  ssh user@${web_server} mkdir ${dir}
  ssh user@${web_server} chmod 775 ${dir} # allow writes from seismo group
  if [[ "${?}" -eq 0 ]]
  then
    echo "Directory '${dir}' creation was successful. Uploading files."
    upload_files ${web_server} ${tld} ${time} ${tag}
  else
    echo "Directory '${dir}' creation failed. Directory already exists"
    exit 1
  fi
}

#
# Send the data required by shakemap over to host.example.com.
#
function send_shakemap_data() {
  local shakemap_dir="/shakemap/data"
  local event_name="${1}"
  # ssh to the web server and create the input directories for shakemap
  ssh user@${web_server} mkdir ${shakemap_dir}/${event_name}
  ssh user@${web_server} chmod 775 ${shakemap_dir}/${event_name}  # allow writes from seismo group

  # example event.xml:
  # <earthquake id="hollywood_m6.7_se" lat="34.1570" lon="-118.2950" mag="6.7" year="2012" month="10" day="10" 
  # hour="12" minute="00" second="00" timezone="UTC" depth="13.5" locstring="Hollywood" created="1310577578" 
  # otime="1310577578" type="SS" />
  create_input_xml

  # example command to run shakemap: 
  # ./shake -scenario -event SCENARIOEVENTNAME
}

#
# Main
#
function main() {
  local time="${1}"                          # the time string passed in from analyze.py (ISO 8601)
  local tag="${2}"
  local web_server="host.example.com" # server where the website lives
  local tld="/path/to/files/web-results"  # top level directory

  # Start calling functions to upload the data
  make_remote_directory ${web_server} ${tld} ${time} ${tag}
}

#
# Entry into program
#
main "$@"
