#!/bin/bash

RUN_PATH=/home/worker/CQ33_RELI
source ${RUN_PATH}/etc/function_deb.sh
source ${RUN_PATH}/etc/function_logger.sh
source ${RUN_PATH}/etc/function_public.sh
source ${RUN_PATH}/etc/function_version.sh
source ${RUN_PATH}/bin/fb_switch
source ${RUN_PATH}/bin/monitor_camera
source ${RUN_PATH}/bin/monitor_cpu
source ${RUN_PATH}/bin/monitor_gpu
source ${RUN_PATH}/bin/monitor_lidar

function main_deb_check()
{
	cq_cam_file
	cq_deb_s_stress
	cq_deb_check "csvlook" cq_deb_csvlook
	cq_deb_check "expect" cq_deb_expect
	#cq_deb_check "firefox" cq_deb_firefox
	#cq_deb_check "gnuplot" cq_deb_gnuplot
	cq_deb_check "gnumeric" cq_deb_gnumeric
	cq_deb_check "mail" cq_deb_mailx
	cq_deb_check "stress-ng" cq_deb_stress
	cq_deb_check "uuencode" cq_deb_uuencode
}

function main_list_version()
{
	local version=$(jq -r '.version' ${RUN_PATH}/etc/share/list_version)
	printf "Program Version : V${version}\n"
	exit 1
}

function main_help_info()
{
	cat ${RUN_PATH}/etc/man/help_manual
	exit 1
}

function main_excute_all()
{
	sleep 90
	#monitor_fan &
	#monitor_gps &
	monitor_lidar 1 &
	monitor_lidar 2 &
	monitor_cpu &
	monitor_gpu &
	#monitor_imu &
}

function main_mode_select()
{
	case $1 in
		1)	fb_switch	;;
		2)	monitor_cam	;;
		3)	monitor_fan	;;
		4)	monitor_gps	;;
		5)	monitor_lidar 1	;;
		6)	monitor_lidar 2	;;
		7)	monitor_imu	;;
		8)	monitor_cpu	;;
		9)	monitor_gpu	;;
		all) 	main_excute_all	;;
		*) 	main_help_info	;;
	esac
}

seq_line_0=$(printf "%95s" "-")
seq_line_1=$(printf "%95s" "*")
main_deb_check

if [ "$#" -lt 1 ]
then
{
	main_help_info
}
fi

while getopts ":vhpm:" arg
do
{
	case ${arg} in
		h)	main_help_info		;;
		v)	main_list_version	;;
		p)	para_set |csvlook	;;	
		m)
			var=${OPTARG}
			main_mode_select ${var}	;;
		*)	main_help_info		;;
	esac
}
done
