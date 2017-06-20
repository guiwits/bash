#!/bin/sh

declare -a nor_events=(
 "20031222_sansimeon"
 "20040918_adobehills"
 "20040928_parkfield"
 "20071031_alumrock"
 "20100110_offshoreferndale"
 "20121021_safnearkingcity"
 "20130524_canyondam"
 "20140123_offshoreferndale2"
 "20140206_sansimeon2"
 "20140310_offshoreeureka"
 "20140824_southnapa"
)

declare -a pnw_events=(
 "20010228_nisqually"
 "20040712_offshore_oregon1"
 "20050615_gorda_plate"
 "20061008_cowlitz_chimneys"
 "20080714_maupin"
 "20080731_puget_sound"
 "20100728_offshore_oregon2"
 "20110214_mt_st_helens"
 "20110909_vancouver_island"
 "20130627_leavenworth"
 "20130804_off_vancouver_island1"
 "20140424_off_vancouver_island2"
)

declare -a soc_events=(
 "19991016_hectormine"
 "20020903_yorbalinda"
 "20030222_bigbear"
 "20040214_wheelerridge"
 "20040615_offshore1"
 "20050106_fontanaswarm"
 "20050416_wheelerridge2"
 "20050612_anza"
 "20050831_obsidianbutte"
 "20050902_obsidianbutte2"
 "20080729_chinohills"
 "20100404_El-MayorCucapah"
 "20100707_CollinsValley"
 "20130311_anza2"
 "20130529_offshoreislavista"
 "20140329_lahabra"
 "20140705_bigbear2"
)

function exec_shakemap() {
  local event_dir="${1}"
  local shakemap_bin="/app/shakemap/bin/shake -scenario -event "

  ## this calls the shakemap script 'shake'. the command needs a directory 
  ## in the data directory. an example command is:
  ## /app/shakemap/bin/shake -scenario -event onsite_20140329_lahabra_9_run_1
  cd "/app/shakemap/data"
  if [[ -d ${event_dir} ]]
  then
    ${shakemap_bin} ${event_dir}
    echo "[INFO]: Shakemap was ran for event ${event_dir}."
  else
    echo "[INFO]: Directory ${event_dir} does not exist. Unable to run shakemap."
  fi
  
  # Need to make sure we go back to the directory we were in prior to calling this
  # function otherwise everything blows up ...
  cd -
}

function create_shakemaps() {
  local data_dir=${1}
  local tag=${2}
  local event=${3}

  case "${nor_events[@]}" in *${event}*) 
    region="nor_events"
    ;; esac
  case "${pnw_events[@]}" in *${event}*) 
    region="pnw_events"
    ;; esac
  case "${soc_events[@]}" in *${event}*) 
    region="soc_events"
    ;; esac
  
  for alg in dm elarms onsite
  do
    cd ${data_dir}/${region}/${event}/${alg}
    files=$( ls *_run_1* )
    for i in $files ; do
      cd ${data_dir}/${region}/${event}/${alg} # enter proper directory after exec_shakemap
      event_dir=${i%.*}
      sm_input_dir=/app/shakemap/data/${event_dir}/input

      ## create the directory for each event.xml file
      mkdir -p ${sm_input_dir}

      if [[ "${?}" -eq 0 ]]
      then
        echo "${sm_input_dir} was created successfully."
        echo; echo
      else
        echo "ERROR: ${sm_input_dir} wasn't successfully created. Please investigate."
        echo; echo
      fi
      cp ${i} ${sm_input_dir}/event.xml

      # Call the exec_shakemap function to actually create the shakemap files for 
      # a specific event and algorithm. 
      exec_shakemap ${event_dir}
    done
  done
}
#
# Main
# Inputs: tag number and event to run (ie South Napa)
#
function main() {
  local tag="${1}"    # tag of the run
  local event="${2}"  # event to create a directories and shakemaps for
  local data_dir="/app/shakemap/data/${tag}/shakemaps"

  create_shakemaps ${data_dir} ${tag} ${event}
}

#
# Entry into program
#
main "$@"
