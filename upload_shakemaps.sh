#!/bin/bash

#
# struct the list the real events that we will create shakemaps for.
# we need these so we can organize directories and look for specific
# events ... I think.
#
declare -A nor_events=(
 ["20031222_sansimeon"]=""
 ["20040918_adobehills"]=""
 ["20040928_parkfield"]=""
 ["20071031_alumrock"]=""
 ["20100110_offshoreferndale"]=""
 ["20121021_safnearkingcity"]=""
 ["20130524_canyondam"]=""
 ["20140123_offshoreferndale2"]=""
 ["20140206_sansimeon2"]=""
 ["20140310_offshoreeureka"]=""
 ["20140824_southnapa"]="-123.562300 37.381866 -121.062300 39.048534 # South Napa 2014"
)

declare -A pnw_events=(
 ["20010228_nisqually"]=""
 ["20040712_offshore_oregon1"]=""
 ["20050615_gorda_plate"]=""
 ["20061008_cowlitz_chimneys"]=""
 ["20080714_maupin"]=""
 ["20080731_puget_sound"]=""
 ["20100728_offshore_oregon2"]=""
 ["20110214_mt_st_helens"]=""
 ["20110909_vancouver_island"]=""
 ["20130627_leavenworth"]=""
 ["20130804_off_vancouver_island1"]=""
 ["20140424_off_vancouver_island2"]=""
)

declare -A soc_events=(
 ["19991016_hectormine"]=""
 ["20020903_yorbalinda"]=""
 ["20030222_bigbear"]=""
 ["20040214_wheelerridge"]=""
 ["20040615_offshore1"]=""
 ["20050106_fontanaswarm"]=""
 ["20050416_wheelerridge2"]=""
 ["20050612_anza"]=""
 ["20050831_obsidianbutte"]=""
 ["20050902_obsidianbutte2"]=""
 ["20080729_chinohills"]=""
 ["20100404_El-MayorCucapah"]=""
 ["20100707_CollinsValley"]=""
 ["20130311_anza2"]=""
 ["20130529_offshoreislavista"]=""
 ["20140329_lahabra"]="-119.167200 33.099166 -116.667200 34.765833 # La Habra 2014"
 ["20140705_bigbear2"]="-118.265700 33.441866 -115.765700 35.108533 # Big Bear 2014"
)

# some paths that every function seems to need or may need.
shakemap_server="example.com" # server where the website lives
tlsd="/app/shakemap/data"                 # top level shakemap directory

#
# this function actually runs the shakemap software on the directory containing
# the event with the .xml file located in it. we have to create a new directory
# for each xml file.
#
# now that the grind.conf is configured for the events specific strictbound coordinates
# we can run the shakemap scripts. an example looks like:
# /app/shakemap/bin/shake -scenario -event south_napa_2014
# /app/shakemap/bin/shake -scenario -event /app/shakemap/data/<tag><region><event><number>
#
function run_shakemap_bin() {
  remote_script="/app/shakemap/bin/create_shakemaps.sh"
  tag="${1}"

  for n_evt in "${!nor_events[@]}"
  do
    echo "Modifying scrict bound of grind.conf file. Using ${nor_events[${n_evt}]} as the bounds"
    if [[ "${nor_events[${n_evt}]}" != "" ]]
    then
      echo "[INFO]: strictbound for ${n_evt} is ${nor_events[${n_evt}]}"
      set_grind_strict_bounds "${nor_events[${n_evt}]}"
      # call a script that lives on the remote server. this part would be very cumbersome to do it over
      # remote ssh commands.
      echo "[INFO]: Calling ${remote_script} on ${shakemap_server} for Nor Cal Events"
      ssh eewresults@${shakemap_server} ${remote_script} ${tag} ${n_evt} 
    else
      echo "[WARN]: strictbound for ${n_evt} is emtpy. passing ..."
    fi
  done

  for p_evt in "${!pnw_events[@]}"
  do
    echo "Modifying scrict bound of grind.conf file. Using ${pnw_events[${p_evt}]} as the bounds"
    if [[ "${nor_events[${n_evt}]}" != "" ]]
    then
      echo "[INFO]: strictbound for ${p_evt} is ${pnw_events[${p_evt}]}"
      set_grind_strict_bounds "${pnw_events[${p_evt}]}"
      # call a script that lives on the remote server. this part would be very cumbersome to do it over
      # remote ssh commands.
      echo "[INFO]: Calling ${remote_script} on ${shakemap_server} for PNW Events"
      ssh eewresults@${shakemap_server} ${remote_script} ${tag} ${p_evt} 
    else
      echo "[WARN]: strictbound for ${p_evt} is emtpy. passing ..."
    fi
  done

  for s_evt in "${!soc_events[@]}"
  do
    echo "Modifying scrict bound of grind.conf file. Using ${soc_events[${s_evt}]} as the bounds"
    if [[ "${soc_events[${s_evt}]}" != "" ]]
    then
      echo "[INFO]: strictbound for ${s_evt} is ${soc_events[${s_evt}]}"
      set_grind_strict_bounds "${soc_events[${s_evt}]}"
      # call a script that lives on the remote server. this part would be very cumbersome to do it over
      # remote ssh commands.
      echo "[INFO]: Calling ${remote_script} on ${shakemap_server} for So Cal Events"
      ssh eewresults@${shakemap_server} ${remote_script} ${tag} ${s_evt} 
    else
      echo "[WARN]: strictbound for ${s_evt} is emtpy. passing ..."
    fi
  done 
}

#
# in the shakemap configuration files, there is a file named grind.conf. we need to
# set the  'strictbound :' property to match that of the event we are creating a shakemap
# for. for example, we need to set it to -119.167200 33.099166 -116.667200 34.765833
# for the La Habra 2014 event.
#
function set_grind_strict_bounds() {
  event_strict_bound="${1}"
  grind_conf_location="/app/shakemap/config/grind.conf"

  # example of command line entry: 
  # echo "sed -i '/^strictbound.*/c strictbound : -123.562300 37.381866 -121.062300 39.048534 # South Napa 2014' /app/shakemap/config/grind.conf" 
  # | ssh eewresults@ci-eew4.gps.caltech.edu bash

  echo "Changing the strictbound entry in ${grind_conf_location} to '${event_strict_bound}'"
  cmd="sed -i '/^strictbound.*/c strictbound : ${event_strict_bound}' ${grind_conf_location}" 
  echo ${cmd} | ssh eewresults@${shakemap_server} bash
  if [[ "${?}" -eq 0 ]]
  then
    echo "${grind_conf_location} was edited successfully."
    echo; echo
  else
    echo "ERROR: ${grind_conf_location} wasn't successfully edited. Please investigate."
    exit 1
  fi
}

#
# Runs the shakemaps in the directory specified by $1. This should
# be all the shakemaps from the tag directory. 
#
function organize_shakemap_files() {
  tag="${1}"
  for i in nor_events soc_events pnw_events
  do 
    echo "------------------- "{$i}" ---------------------------|" 
    echo "creating dirctory for region events -> ${i}"
    dir="${tlsd}/${tag}/shakemaps/${i}"
    ssh eewresults@${shakemap_server} mkdir ${dir}
  done

  for n_evt in "${!nor_events[@]}"
  do
    echo "NorCal Event: ${n_evt}"
    event_dir="${tlsd}/${tag}/shakemaps/nor_events/${n_evt}"
    ssh eewresults@${shakemap_server} ls ${event_dir} 2>&1 >> /dev/null
    if [[ "${?}" -ne 0 ]]
    then
      echo "Directory '${event_dir}' is being created."
      ssh eewresults@${shakemap_server} mkdir ${event_dir}
      for alg in dm elarms onsite 
      do
        echo "Creating algorithms directories -> dm, onsite, elerms, and finder and"
        echo "moving algorithm event.xml files into their respective algorithm directory"
        ssh eewresults@${shakemap_server} mkdir ${event_dir}/${alg}
        ssh eewresults@${shakemap_server} mv ${tlsd}/${tag}/shakemaps/${alg}_${n_evt}*.xml ${event_dir}/${alg}
      done
    fi
  done
  echo "|------------------------------------------"

  for p_evt in "${!pnw_events[@]}"
  do
    echo "PNW Event: ${p_evt}"
    event_dir="${tlsd}/${tag}/shakemaps/pnw_events/${p_evt}"
    ssh eewresults@${shakemap_server} ls ${event_dir} 2>&1 >> /dev/null
    if [[ "${?}" -ne 0 ]]
    then
      echo "Directory '${event_dir}' is being created."
      ssh eewresults@${shakemap_server} mkdir ${event_dir}
      for alg in dm elarms onsite 
      do
        echo "Creating algorithms directories -> dm, onsite, elerms, and finder and"
        echo "moving algorithm event.xml files into their respective algorithm directory"
        ssh eewresults@${shakemap_server} mkdir ${event_dir}/${alg}
        ssh eewresults@${shakemap_server} mv ${tlsd}/${tag}/shakemaps/${alg}_${p_evt}*.xml ${event_dir}/${alg}
      done
    fi
  done
  echo "|------------------------------------------"

  for s_evt in "${!soc_events[@]}"
  do
    echo "SoCal Event: ${s_evt}"
    event_dir="${tlsd}/${tag}/shakemaps/soc_events/${s_evt}"
    ssh eewresults@${shakemap_server} ls ${event_dir} 2>&1 >> /dev/null
    if [[ "${?}" -ne 0 ]]
    then
      echo "Directory '${event_dir}' is being created."
      ssh eewresults@${shakemap_server} mkdir ${event_dir}
      for alg in dm elarms onsite 
      do
        echo "Creating algorithms directories -> dm, onsite, elerms, and finder and"
        echo "moving algorithm event.xml files into their respective algorithm directory"
        ssh eewresults@${shakemap_server} mkdir ${event_dir}/${alg}
        ssh eewresults@${shakemap_server} mv ${tlsd}/${tag}/shakemaps/${alg}_${s_evt}*.xml ${event_dir}/${alg}
      done
    fi
  done
  echo "|------------------------------------------"
  ssh eewresults@${shakemap_server} chmod -R 775 ${dir} # allow writes from seismo group
}

#
# Looks for the event.xml files and uploads them to the remote web server.
#
function upload_files() {
  local tag="${1}"
  local files_dir="/app/share/testsuite/logs/taglogs/${tag}/shakemaps"

  # Verify shakemaps directory exist and is not empty before copying them to the remote host
  if [[ -d "${files_dir}" ]]
  then
    if [[ -z "$(ls -A ${files_dir} 2>/dev/null)" ]]
    then
      echo "Those files don't exist. Please investigate"
      exit 1
    else
      echo "Copying shakemap event.xml files to ${shakemap_server}"
      scp -r ${files_dir} eewresults@${shakemap_server}:${tlsd}/${tag}
    fi
  else
    echo "The directory ${files_dir} doesn't exist. Exiting..."
    exit 1
  fi
}

# 
# Creates the required file directory on the remote server and calls the
# upload ftion.
#
function make_remote_directory() {
  local tag="${1}"
 
  if [[ -z "${tag}" ]]
  then
    echo "A tag was not passed into the script. Script will fail without it. Exiting"
    exit 1
  fi

  # create the directory structure based on the time format
  dir="${tlsd}/${tag}"

  # ssh to the web server and create the directory
  ssh eewresults@${shakemap_server} mkdir ${dir}
  ssh eewresults@${shakemap_server} chmod 775 ${dir} # allow writes from seismo group
  if [[ "${?}" -eq 0 ]]
  then
    echo "Directory '${dir}' creation was successful. Uploading files."
    echo; echo
  else
    echo "Directory '${dir}' creation failed. Directory already exists"
    exit 1
  fi
  return 0
}

#
# Main
#
function main() {
  local tag="${1}" # tag of the run

  # Start calling functions to upload the data
  make_remote_directory ${tag}
  upload_files ${tag}
  organize_shakemap_files "${tag}"
  run_shakemap_bin "${tag}" 
}

#
# Entry into program
#
main "$@"
