#!/bin/bash

function search_cron_check()
{
	local md5_etc=$(md5sum /etc/crontab |awk '{print $1}')
	local md5_cron=$(jq -r '.para_stat.md5_cron' ${common_json})
	if [ "${md5_etc}"x != "${md5_cron}"x ]
	then
		sudo cp ${run_path}/lib/cq_file/cron/crontab /etc/
	fi
}

function search_log()
{
	local log_info=${unit_dir}/${i}/$1
	if [ -s "${log_info}" ]
	then
		tail ${log_info} |tee -a $2
	fi
}

function search_lidar_count()
{
	if [ -s "$1" ]
	then
		local lx_succ=0
		local lx_fail=0
		local lx_time=0
		while read line
		do
			local lx_succ_per=$(echo "${line}" |awk -F ',' '{print $4}' |awk -F '=' '{print $2}')
			local lx_fail_per=$(echo "${line}" |awk -F ',' '{print $5}' |awk -F '=' '{print $2}')
			let lx_succ=${lx_succ}+${lx_succ_per}
			let lx_fail=${lx_fail}+${lx_fail_per}
		done < $1
		let lx_time=${lx_succ}+${lx_fail}
		printf "$(date "+%F %T"),$2,iperf,${lx_time},${lx_succ},${lx_fail}\n" 
	fi
}

function search_camera_per_count()
{
	local frame_t=0 frame_l=0 frame_c=0
	while read line
	do
		local frame_t_per=$(echo "${line}" |awk -F ',' '{print $4}')
		local frame_l_per=$(echo "${line}" |awk -F ',' '{print $5}')
		local frame_c_per=$(echo "${line}" |awk -F ',' '{print $6}')
		let frame_t=frame_t+frame_t_per
		let frame_l=frame_l+frame_l_per
		let frame_c=frame_c+frame_c_per
	done < $1
	printf "$(date "+%F %T"),camera,$2,${frame_t},${frame_l},${frame_c}\n"
}

function search_camera_count()
{
	if [ -s "$1" ]
	then
		local cam_dir=${dir_log_info}/cam_per
		local cam_list=("video0" "video1" "video2" "video3" "video4" "video5")
		local cam_len=$(echo "${#cam_list[@]}")
		[ ! -d "${cam_dir}" ] && mkdir -p ${cam_dir}
		sed -i 's/[ ]/,/g' $1
		for ((i=0;i<${cam_len};i++))
		do
			grep ${cam_list[$i]} $1 > /dev/null
			if [ "$?" -eq 0 ]
			then
				local per_log=${cam_dir}/${cam_list[$i]}.log
				grep ${cam_list[$i]} $1 > ${per_log}
				search_camera_per_count ${per_log} "${cam_list[$i]}"
			fi
		done
	fi
}

function search_dir_per()
{
	for i in $(ls ${unit_dir})
	do
		printf "check ${unit_dir}/$i ...\n"
		$1
	done
}

function search_dir_count()
{
	local dir_count=$(ls ${unit_dir} |wc -w)
	if [ "${dir_count}" -gt 0 ]
	then
		printf " conunt \E[1;44m ${dir_count} \E[0m logs\n"
		echo "${seq_line_0// /-}"
		if [ "${line}" == "check_camera" ]
		then
			search_dir_per "search_log camera_result.log ${log_cam}"
		elif [ "${line}" == "check_cpu" ]
		then
			search_dir_per "search_log cpu_master_statistic.log ${log_cpu_m}"
			search_dir_per "search_log cpu_slave_statistic.log ${log_cpu_s}"
		elif [ "${line}" == "check_lidar1" ]
		then
			search_dir_per "search_log iperf_result.log ${log_lid1}"
		elif [ "${line}" == "check_lidar2" ]
		then
			search_dir_per "search_log iperf_result.log ${log_lid2}"
		elif [ "${line}" == "check_gps" ]
		then
			search_dir_per "search_log gps_result.log ${log_gps}"
		elif [ "${line}" == "check_gpu" ]
		then
			search_dir_per "search_log gpu_master_statistic.log ${log_gpu_m}"
			search_dir_per "search_log gpu_slave_statistic.log ${log_gpu_s}"
		elif [ "${line}" == "check_imu" ]
		then
			search_dir_per "search_log imu_result.log ${log_imu}"
		fi
	else
		printf " conunt \E[1;41m ${dir_count} \E[0m logs\n"
	fi
	echo "${seq_line_0// /-}"
}

function search_cam_log_scp()
{
	local switch_fb=$(jq '.fb_switch' ${search_json})
	if [ "${switch_fb}" -eq 1 ]
	then
		ssh slave <<-eeooff
			(
				cd /home/worker/camera/log
				sudo chown -R worker:worker check_camera
				scp -r check_camera master:${run_path}/log
			)
		eeooff
	fi
}

function search_dir_check()
{
	printf "Log result traversal ...\n"
	while read line
	do
		local unit_dir=${run_path}/log/${line}
		printf "\n${seq_line_1// /*}\n"
		printf "$(date "+%F %T") : check \E[1m${unit_dir}\E[0m"	
		if [ -d "${unit_dir}" ]
		then
			search_dir_count
		fi
		sleep 1
	done < ${run_path}/etc/share/search_list
}

function search_result_count()
{
	{
		printf "\ndate,unit,sub,time,succ,fail\n"
		search_camera_count ${log_cam}
		search_lidar_count ${log_lid1} "lidar1"
		search_lidar_count ${log_lid2} "lidar2"
	} >> ${log_result}
	#csvlook ${log_result}
	cat ${log_result}
}

function search_log_rollback()
{
	local statistic_dir=${run_path}/log/statistic_result
	local rollback_num=$(jq -r '.para_stat.rollback_num' ${common_json})
	local log_dir_num=$(ls ${statistic_dir} |wc -w)
	if [ "${rollback_num}" -lt "${log_dir_num}" ]
	then
		local log_del_num=0
		let log_del_num=${log_dir_num}-${rollback_num}
		for i in $(ls ${statistic_dir} |head -${log_del_num})
		do
			local rm_dir_comm="rm -r ${statistic_dir}/${i}"
			echo "$(date "+%F %T") ${rm_dir_comm}" >> ${statistic_dir}/rollback.txt
			${rm_dir_comm}
		done
	fi
}

function search_result_mail()
{
	ping -c1 8.8.8.8 > /dev/null
	if [ "$?" -eq 0 ]
	then
		local cc_account=$(jq -r '.para_stat.mail_cc_account' ${search_json})
		local mail_account=13734716682@163.com
		local mail_title="${log_date} CQ3.4 Statistic Result"
		local switch_annex=$(jq -r '.para_stat.mail_switch_annex' ${search_json})
		if [ "${switch_annex}" -eq 1 ]
		then
			(
				local log_tar=${log_date}-cq3.4.tar.gz
				cd ${dir_log}
				tar -czvf ${log_tar} ${dir_log}/* > /dev/null
				{
					uuencode ${log_tar} ${log_tar}
				} | mail -s "${mail_title} Annex" -c ${cc_account} ${mail_account}
				rm ${log_tar}
			)
		fi
		
		local switch_content=$(jq -r '.para_stat.mail_switch_content' ${search_json})
		if [ "${switch_content}" -eq 1 ]
		then
			(
				cd ${dir_log}
				mail -s "${mail_title} Content" -c ${cc_account} ${mail_account} < cq_result.log
			)
		fi
	fi
}

function search_result_xls()
{
	(
		cd ${dir_log}
		local log_info_list=$(ls log_info/result_*)
		local log_cam_list=$(ls log_info/cam_per/*)
		{
			ssconvert --merge-to="cq_result.xls" cq_result.log ${log_info_list} ${log_cam_list}
		} &> /dev/null
	)	
}

function search_result_output()
{
	search_result_count
	search_result_xls
}

function search_main()
{
	local seq_line_0=$(printf "%95s" "-")
	local seq_line_1=$(printf "%95s" "*")
	local run_path=/home/worker/CQ33_RELI
	local search_json=${run_path}/config.json
	local common_json=${run_path}/etc/share/commons
	local log_date=$(date "+%Y-%m-%d-%H-%M-%S")
	local dir_log=${run_path}/log/statistic_result/${log_date}
	local dir_log_info=${dir_log}/log_info
	local log_cam=${dir_log_info}/result_camera
	local log_cpu_m=${dir_log_info}/result_cpum
	local log_cpu_s=${dir_log_info}/result_cpus
	local log_gps=${dir_log_info}/result_gps
	local log_gpu_m=${dir_log_info}/result_gpum
	local log_gpu_s=${dir_log_info}/result_gpus
	local log_imu=${dir_log_info}/result_imu
	local log_lid1=${dir_log_info}/result_lidar1
	local log_lid2=${dir_log_info}/result_lidar2
	local log_result=${dir_log}/cq_result.log
	[ ! -d "${dir_log}" ] && mkdir -p ${dir_log}
	[ ! -d "${dir_log_info}" ] && mkdir -p ${dir_log_info}
	search_cron_check
	search_cam_log_scp
	search_dir_check
	search_result_output
	search_result_mail
	search_log_rollback
}

search_main
