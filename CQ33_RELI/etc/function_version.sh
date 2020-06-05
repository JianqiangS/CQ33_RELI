#!/bin/bash

function para_set_gpu()
{
	local gpu_m_switch=$(jq -r '.para_gpu.switch_m' ${para_json}) 
	if [ "${gpu_m_switch}" -eq 1 ]
	then
	{
		local gpu_m_num="1"
	}
	else
	{
		local gpu_m_num="0"
	}
	fi

	local gpu_s_switch=$(jq -r '.para_gpu.switch_s' ${para_json}) 
	if [ "${gpu_s_switch}" -eq 1 ]
	then
	{
		local gpu_s_num="1"
	}
	else
	{
		local gpu_s_num="0"
	}
	fi
	printf "master,gpu,${gpu_m_switch},${gpu_m_num}00%%\n"
	printf "slave,gpu,${gpu_s_switch},${gpu_s_num}00%%\n"
}

function para_set_cpu()
{
	local cpu_m_switch=$(jq -r '.para_cpu.switch_m' ${para_json}) 
	local cpu_s_switch=$(jq -r '.para_cpu.switch_s' ${para_json}) 
	local cpu_m_num=$(jq -r '.para_cpu.core_m_num' ${para_json}) 
	local cpu_s_num=$(jq -r '.para_cpu.core_s_num' ${para_json}) 
	printf "master,cpu,${cpu_m_switch},${cpu_m_num}00%%\n"
	printf "slave,cpu,${cpu_s_switch},${cpu_s_num}00%%\n"
}

function para_set_uos()
{
	local uos_m_name=$(jq -r '.uos_name' ${para_json})
	if [ -d "/home/worker/${uos_m_name}" ]
	then
	{
		local path_m_status=1
	}
	else
	{
		local path_m_status=0
	}
	fi	
	printf "master,uos,${uos_m_name},${path_m_status}\n"

	local path_s_value=$(ssh slave "ls /home/worker/${uos_set_name}")
	if [ -n "${path_s_value}" ]
	then
	{
		local path_s_status=1
	}
	else
	{
		local path_s_status=0
	}
	fi
	printf "slave,uos,${uos_m_name},${path_s_status}\n"
}

function para_set_lidar()
{
	local lidar1_ip=$(jq -r '.para_lidar.l1_ip' ${para_json})	
	ping -c2 ${lidar1_ip} > /dev/null
	if [ "$?" -eq 0 ]
	then
	{
		local lidar1_ip_status=1
	}
	else
	{
		local lidar1_ip_status=0
	}
	fi
	printf "master,lidar1,${lidar1_ip},${lidar1_ip_status}\n"

	local lidar2_ip=$(jq -r '.para_lidar.l2_ip' ${para_json})	
	ping -c2 ${lidar2_ip} > /dev/null
	if [ "$?" -eq 0 ]
	then
	{
		local lidar2_ip_status=1
	}
	else
	{
		local lidar2_ip_status=0
	}
	fi
	printf "master,lidar2,${lidar2_ip},${lidar2_ip_status}\n"
}

function para_set()
{
	local run_path=/home/worker/CQ33_RELI
	local para_json=${run_path}/config.json
	printf "port,mode,set_value,status\n"
	para_set_cpu
	para_set_gpu
	para_set_uos
	para_set_lidar
}

function para_version_board()
{
	local version_board=$(list_version.sh |grep Board |awk -F ':' '{print $2}' |sed 's/^[\t]*//g')
	printf "Board Type : ${version_board}\n"
}

function para_version_soft()
{
	local version_soft=$(jq -r '.version' /etc/uisee_release)
	printf "System Version : ${version_soft}\n"
}

