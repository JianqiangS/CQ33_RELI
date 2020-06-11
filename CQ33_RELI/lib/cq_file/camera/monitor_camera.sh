#!/bin/bash

function monitor_cam_num()
{
	cam_num=$(get_camera_status.sh |grep YES |wc -l)
	if [ "${cam_num}" -lt 1 ]
	then
	{
		printf "Please check if the camera is connected ...\n"
		exit 1
	}
	fi
}

function monitor_cam_excute()
{
        local run_time=$(jq -r '.run_time' ${config_json})
        pgrep check_camera |xargs sudo kill -9
	(
		cd ${run_dir}
		> ${log_summary}
		./startup.sh ${run_time}
	)
}

function monitor_cam_result()
{
	local cam_excute=${log_dir}/camera_excute.log
	local cam_statis=${log_dir}/camera_result.log
	local cycle_time=$(jq -r '.cycle_times' ${config_json})
	local delay_time=$(jq -r '.delay_time' ${config_json})
	local i
	for ((i=1;i<${cycle_time};i++))
	do
	{
                {
                        sleep ${delay_time}
                        tail -${cam_num} ${log_summary} |sort -n
                } >> ${cam_excute}

                {
                        tail -${cam_num} ${cam_excute}
                } | tee ${cam_statis}
		monitor_cam_empty
	}
	done
}

function monitor_cam_empty()
{
	local warn_threold=$(df -h|grep mmcblk |awk '{print $5}'|awk -F '%' '{print $1}')
	if [ "${warn_threold}" -gt 90 ]
	then
	{
		(
			cd ${run_dir}
			sudo rm -r video*
		)
	}
	fi
}

function monitor_cam()
{
	local run_dir=/home/worker/camera
	local config_json=${run_dir}/config.json
	local log_date=$(date "+%Y-%m-%d-%H-%M-%S")
	local log_dir=${run_dir}/log/check_camera/${log_date}
	local log_summary=${run_dir}/check_camera.summary
	[ ! -d "${log_dir}" ] && mkdir -p ${log_dir}
	monitor_cam_num
	monitor_cam_empty
	monitor_cam_excute &
	monitor_cam_result
}

monitor_cam
