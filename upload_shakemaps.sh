#!/bin/bash

#
# struct the list the real events that we will create shakemaps for.
# we need these so we can organize directories and look for specific
# events ... I think.
#
declare -A nor_events=(
 ["20031222_sansimeon"]="strictbound : -123.600500 34.033832 -118.600500 37.367166  # 10.2 km (6.4 mi) NE of San Simeon, CA -- id: 21323712"
 ["20040918_adobehills"]="strictbound : -120.678500 36.676166 -116.678500 39.342833  # 35.8 km (22.2 mi) SSW of Qualeys Camp, NV -- id: 21396205"
 ["20040928_parkfield"]="strictbound : -121.366000 35.151533 -119.366000 36.484866  # 10.7 km (6.6 mi) SSE of Parkfield, CA -- id: 30228270"
 ["20071031_alumrock"]="strictbound : -123.024300 36.600166 -120.524300 38.266833  # 8.8 km (5.5 mi) NNE of Alum Rock, CA -- id: 40204628"
 ["20100110_offshoreferndale"]="strictbound : -125.692500 39.318666 -121.692500 41.985333  # 37.1 km (23.1 mi) WNW of Ferndale, CA -- id: 71338066"
 ["20121021_safnearkingcity"]="strictbound : -122.106000 35.476366 -119.606000 37.143034  # 20.2 km (12.6 mi) SW of New Idria, CA -- id: 71863625 "
 ["20130524_canyondam"]="strictbound : -122.309500 39.358466 -119.809500 41.025134  # 2.8 km (1.7 mi) NNE of Canyondam, CA -- id: 71996906"
 ["20140123_offshoreferndale2"]="strictbound : -126.191200 39.577666 -123.691200 41.244334  # 90.0 km (55.9 mi) W of Petrolia, CA -- id: 72145230"
 ["20140206_sansimeon2"]="strictbound : -122.521000 34.692666 -120.021000 36.359334  # 15.0 km (9.3 mi) SSW of San Simeon, CA -- id: 72157621"
 ["20140310_offshoreeureka"]="strictbound : -126.133800 38.828699 -120.133800 42.828701  # 78.5 km (48.8 mi) WNW of Ferndale, CA -- id: 72182046"
 ["20140824_southnapa"]="strictbound : -123.562300 37.381866 -121.062300 39.048534  # 6.4 km (3.9 mi) NW of American Canyon, CA -- id: 72282711"
)

declare -A pnw_events=(
 ["20010228_nisqually"]="strictbound : -125.603000 45.069000 -119.603000 49.155000  # Nisqually, Washington -- id: 20010228185432"
 ["20040712_offshore_oregon1"]="strictbound : -125.488800 43.618800 -123.488800 45.048800  # 48.3 km (30.0 mi) SW of Newport, OR -- id: 10609208"
 ["20050615_gorda_plate"]="strictbound : -127.477000 38.973000 -121.477000 43.485000  # Coast of Northern California -- id: 20050615025053"
 ["20061008_cowlitz_chimneys"]="strictbound : -122.600200 46.165800 -120.600200 47.533800  # 49.2 km (30.6 mi) SE of Enumclaw, WA"
 ["20080714_maupin"]="strictbound : -121.950000 44.422700 -119.950000 45.834700  # 11.4 km (7.1 mi) ESE of Maupin, OR"
 ["20080731_puget_sound"]="strictbound : -123.498200 47.651450 -121.998200 48.651950  # 42.6 km (26.4 mi) SW of Mount Vernon, WA"
 ["20100728_offshore_oregon2"]="strictbound : -127.315000 42.673000 -124.315000 44.839000  # 136.0 km (84.5 mi) WNW of Coos Bay, OR"
 ["20110214_mt_st_helens"]="strictbound : -123.213700 45.590700 -121.213700 46.972700  # 31.1 km (19.3 mi) S of Morton, WA"
 ["20110909_vancouver_island"]="strictbound : -129.393000 47.912500 -124.393000 51.157500  # 83 km WNW of Tofino, Canada -- id: 20110909194134"
 ["20130627_leavenworth"]="strictbound : -121.689200 47.153200 -119.689200 48.495200  # 39.3 km (24.4 mi) WNW of Entiat, WA"
 ["20130804_off_vancouver_island1"]="strictbound : -129.415100 48.393000 -125.415100 50.981000  # VANCOUVER ISLAND, CANADA REGION"
 ["20140424_off_vancouver_island2"]="strictbound : -130.731600 47.694800 -124.731600 51.582800  # VANCOUVER ISLAND, CANADA REGION -- id: b000px6r"
)

declare -A soc_events=(
 ["19991016_hectormine"]="strictbound : -119.450000 32.045000 -113.450000 36.989000  # Hector Mine, California -- id: 19991016094648"
 ["20020903_yorbalinda"]="strictbound : -119.033300 33.078966 -116.533300 34.745633  # 3.8 km (2.4 mi) NE of Yorba Linda, CA -- id: 9818433"
 ["20030222_bigbear"]="strictbound : -118.094800 33.478666 -115.594800 35.145333  # 5.7 km (3.5 mi) N of Big Bear City, CA -- id: 13935988"
 ["20040214_wheelerridge"]="strictbound : -120.395000 34.206466 -117.895000 35.873133  # 21.5 km (13.4 mi) N of Pine Mountain Club, CA -- id: 9983429"
 ["20040615_offshore1"]="strictbound : -119.164200 31.509466 -116.664200 33.176133  # 66.7 km (41.4 mi) SE of San Clemente Is. (SE tip), CA -- id: 14065544"
 ["20050106_fontanaswarm"]="strictbound : -118.689 33.2917 -116.189 34.9583 #1.3 mi N of Fontana, CA -- id: 14116972"
 ["20050416_wheelerridge2"]="strictbound : -120.441000 34.188966 -117.941000 35.855633  # 19.5 km (12.1 mi) ESE of Maricopa, CA -- id: 14138080"
 ["20050612_anza"]="strictbound : -117.816700 32.699166 -115.316700 34.365833  # 10.2 km (6.4 mi) ESE of Anza, CA -- id: 14151344 "
 ["20050831_obsidianbutte"]="strictbound : -116.885200 32.332966 -114.385200 33.999633  # 12.1 km (7.5 mi) WNW of Calipatria, CA -- id: 14178184"
 ["20050902_obsidianbutte2"]="strictbound : -116.896300 32.319966 -114.396300 33.986633  # 12.7 km (7.9 mi) WNW of Calipatria, CA -- id: 14179736"
 ["20080729_chinohills"]="strictbound : -119.016300 33.115166 -116.516300 34.781833  # 5.1 km (3.2 mi) S of Chino Hills, CA -- id: 14383980"
 ["20100404_El-MayorCucapah"]="strictbound : -117.600000 31.000000 -113.005556 34.066667  # 12.3 km (7.6 mi) SW of Delta, B.C., MX -- id: 14607652"
 ["20100707_CollinsValley"]="strictbound : -117.724700 32.583966 -115.224700 34.250633  # 20.2 km (12.6 mi) NNW of Borrego Springs, CA -- id: 10736069"
 ["20130311_anza2"]="strictbound : -117.708200 32.667466 -115.208200 34.334133  # 20.9 km (13.0 mi) ESE of Anza, CA -- id: 15296281"
 ["20130529_offshoreislavista"]="strictbound : -121.176000 33.579166 -118.676000 35.245833 # 6.7 km (4.1 mi) W of Isla Vista, CA -- id: 15350729"
 ["20140329_lahabra"]="strictbound : -119.167200 33.099166 -116.667200 34.765833  # 2.4 km (1.5 mi) NW of Brea, CA -- id: 15481673 "
 ["20140705_bigbear2"]="strictbound : -118.277800 33.446666 -115.777800 35.113333  # 10.8 km (6.7 mi) NE of Running Springs, CA -- id: 15520985"
)

# some paths that every function seems to need or may need.
shakemap_server="ci-eew4.gps.caltech.edu" # server where the website lives
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
    echo "Modifying scrictbound setting of grind.conf file. Using ${soc_events[${s_evt}]} as the bounds"
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
  cmd="sed -i '/^strictbound.*/c  ${event_strict_bound}' ${grind_conf_location}" 
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

  # Start calling ftions to upload the data
  make_remote_directory ${tag}
  upload_files ${tag}
  organize_shakemap_files "${tag}"
  run_shakemap_bin "${tag}" 
}

#
# Entry into program
#
main "$@"
