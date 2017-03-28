#!/bin/bash

declare -a calibrations=("20140809_cal8.nc" "20140811_cal7.nc"  "20140812_cal6.nc" "20140918_cal5.nc" 
                         "20140919_cal4.nc" "20141004_cal2.nc"  "20141004_cal3.nc" "20141010_cal1.nc")

declare -a pnsn_anomalous=("20161005_anomalous9.nc" "20161018_anomalous2.nc"  "20161024_anomalous4.nc" "20161026_anomalous6.nc"  
                           "20161031_anomalous8.nc" "20161013_anomalous1.nc"  "20161019_anomalous3.nc" "20161026_anomalous5.nc"  
                           "20161031_anomalous7.nc" "20170101_anomalous10.nc")

declare -a recenterings=("20140210_rec_01.nc" "20140319_rec_12.nc"  "20140724_rec_03.nc" "20140724_rec_18.nc"  
                         "20140903_rec_14.nc" "20140910_rec_05.nc"  "20141008_rec_16.nc" "20140213_rec_02.nc"
                         "20140623_rec_17.nc" "20140724_rec_13.nc"  "20140728_rec_08.nc" "20140905_rec_04.nc"  
                         "20141006_rec_06.nc" "20141016_rec_10.nc")

declare -a teleseisems=("20000328_tele25_volcanojapan.nc" "20050926_tele31_northperu.nc" "20080705_tele27_seaokhotsk.nc" "20120814_tele28_seaokhotsk.nc"      
                        "20140401_tele16_chile.nc" "20150530_tele3_japan.nc" "20000328_tele29_volcanojapan.nc" "20061115_tele14_kuril.nc"      
                        "20090803_tele4_sonora.nc" "20121214_tele6_baja.nc" "20140629_tele8_newmexico.nc" "20020819_tele26_southfiji2.nc"     
                        "20070113_tele17_kuril.nc" "20090929_tele19_samoa.nc" "20130206_tele20_solomonislands.nc" "20140818_tele10_utah.nc" 
                        "20021117_tele30_kurilislands.nc"  "20070815_tele18_peru.nc" "20100227_tele12_chile.nc" "20130524_tele15_seaokhotsk.nc"
                        "20150522_tele1_caliente.nc" "20030925_tele13_hokkaido.nc" "20071209_tele23_southfiji.nc" "20110311_tele11_japan.nc"
                        "20130623_tele22_sitkinalaska.nc" "20150529_tele2_alaska.nc" "20050613_tele21_tarapecachile.nc" "20080221_tele7_nevada.nc"      
                        "20120412_tele5_baja.nc" "20140305_tele9_avalon.nc" "20150530_tele24_chichijapan.nc")

declare -a events=("19991016_hectormine.nc" "20040928_parkfield.nc" "20080714_maupin.nc" "20121021_safnearkingcity.nc" "20140310_offshoreeureka.nc"
                   "20010228_nisqually.nc" "20050106_fontanaswarm.nc" "20080729_chinohills.nc" "20130311_anza2.nc" "20140329_lahabra.nc"
                   "20020903_yorbalinda.nc" "20050416_wheelerridge2.nc" "20080731_puget_sound.nc" "20130524_canyondam.nc" 
                   "20140424_off_vancouver_island2.nc" "20030222_bigbear.nc" "20050612_anza.nc" "20100110_offshoreferndale.nc" 
                   "20130529_offshoreislavista.nc" "20140705_bigbear2.nc" "20031222_sansimeon.nc" "20050615_gorda_plate.nc"
                   "20100404_El-MayorCucapah.nc" "20130627_leavenworth.nc" "20140824_southnapa.nc" "20040214_wheelerridge.nc"
                   "20050831_obsidianbutte.nc" "20100707_CollinsValley.nc" "20130804_off_vancouver_island1.nc" "20140908_box2.nc" 
                   "20040615_offshore1.nc" "20050902_obsidianbutte2.nc" "20100728_offshore_oregon2.nc" "20130816_box1.nc"
                   "20150701_pge.nc" "20040712_offshore_oregon1.nc" "20061008_cowlitz_chimneys.nc" "20110214_mt_st_helens.nc" 
                   "20140123_offshoreferndale2.nc" "20040918_adobehills_swarm.nc" "20071031_alumrock.nc" "20110909_vancouver_island.nc"
                   "20140206_sansimeon2.nc")


eew_data_dir="/app/eewdata/tankfiles"
mask_dir="/home/desmith/work/replay_station_masks"
cd "${mask_dir}"

for element in ${events[@]}
do
  src_dir="${eew_data_dir}/${element%.*}"
  echo "Copying ${element} to ${src_dir}"
  cp "${element}" "${src_dir}"
  echo "------------------------------------|" 
done

for i in calibrations pnsn_anomalous recenterings teleseisems
do 
  cd "${i}"
  array_name="$i[@]"
  for element in ${!array_name} 
  do 
    src_dir="${eew_data_dir}/${i}/${element%.*}"
    cp "${element}" "${src_dir}"
    echo "Copying ${element} to ${src_dir}"
  done 
  cd ..
  echo "------------------------------------|" 
done
