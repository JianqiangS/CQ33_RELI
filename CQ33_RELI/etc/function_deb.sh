#!/bin/bash

function cq_deb_check()
{
	which $1 > /dev/null
	[ "$?" -ne 0 ] && $2
}

function cq_cam_file()
{
	local log_summary=/home/worker/camera/check_camera.summary
	local camera_file=$(ssh slave "ls -l ${log_summary}")
	if [ -z "${camera_file}" ]
	then
	{
		scp -r ${RUN_PATH}/lib/cq_file/camera slave:~/
	}
	fi
}

function cq_deb_help()
{
	dir_deb=${RUN_PATH}/lib/cq_deb/$2
	printf "$1 package install ...\n"
}

function cq_deb_csvlook()
{
	cq_deb_help "csvlook" "deb_csvkit"
	sudo dpkg -i ${dir_deb}/python3-dateutil_2.4.2-1_all_0.deb
	sudo dpkg -i ${dir_deb}/python3-jdcal_1.0-1build1_all_1.deb
	sudo dpkg -i ${dir_deb}/python3-openpyxl_2.3.0-1_all_2.deb
	sudo dpkg -i ${dir_deb}/python3-xlrd_0.9.4-1_all_4.deb
	sudo dpkg -i ${dir_deb}/python3-csvkit_0.9.1-2_all_5.deb
	sudo dpkg -i ${dir_deb}/python3-pil_3.1.2-0ubuntu1.1_arm64_6.deb
	sudo dpkg -i ${dir_deb}/python3-py_1.4.31-1_all_7.deb
	sudo dpkg -i ${dir_deb}/python3-xlrd_0.9.4-1_all_4.deb
}

function cq_deb_expect()
{
	cq_deb_help "expect" "deb_expect"
	sudo dpkg -i ${dir_deb}/expect_5.45-7_arm64.deb
	sudo dpkg -i ${dir_deb}/tcl-expect_5.45-7_arm64.deb
}

function cq_deb_firefox()
{
	cq_deb_help "firefox" "deb_firefox"
	sudo dpkg -i ${dir_deb}/firefox_70.0+build2-0ubuntu0.16.04.1_arm64.deb
}

function cq_deb_gnuplot()
{
	cq_deb_help "gnuplot" "deb_gnuplot"
	sudo dpkg -i ${dir_deb}/aglfn_1.7-3_all.deb
	sudo dpkg -i ${dir_deb}/gnuplot-tex_4.6.6-3_all.deb
	sudo dpkg -i ${dir_deb}/gnuplot5-data_5.0.3+dfsg2-1_all.deb
	sudo dpkg -i ${dir_deb}/liblua5.1-0_5.1.5-8ubuntu1_arm64.deb
	sudo dpkg -i ${dir_deb}/libwxbase3.0-0v5_3.0.2+dfsg-1.3ubuntu0.1_arm64.deb
	sudo dpkg -i ${dir_deb}/libwxgtk3.0-0v5_3.0.2+dfsg-1.3ubuntu0.1_arm64.deb
	sudo dpkg -i ${dir_deb}/gnuplot5-qt_5.0.3+dfsg2-1_arm64.deb
	sudo dpkg -i ${dir_deb}/gnuplot_4.6.6-3_all.deb
}

function cq_deb_gnumeric()
{
	cq_deb_help "gnumeric" "deb_gnumeric"
	sudo dpkg -i ${dir_deb}/gnumeric-common_1.12.28-1_all_0.deb
	sudo dpkg -i ${dir_deb}/libgsf-1-common_1.14.36-1_all_1.deb
	sudo dpkg -i ${dir_deb}/libgsf-1-114_1.14.36-1_arm64_2.deb
	sudo dpkg -i ${dir_deb}/libgoffice-0.10-10-common_0.10.28-1_all_3.deb
	sudo dpkg -i ${dir_deb}/libgoffice-0.10-10_0.10.28-1_arm64_4.deb
	sudo dpkg -i ${dir_deb}/gnumeric_1.12.28-1_arm64_5.deb
	sudo dpkg -i ${dir_deb}/gnumeric-doc_1.12.28-1_all_6.deb
	sudo dpkg -i ${dir_deb}/libsuitesparseconfig4.4.6_1%3a4.4.6-1_arm64_7.deb
	sudo dpkg -i ${dir_deb}/libcolamd2.9.1_1%3a4.4.6-1_arm64_8.deb
	sudo dpkg -i ${dir_deb}/lp-solve_5.5.0.13-7build2_arm64_9.deb
}

function cq_deb_mailx()
{
	cq_deb_help "mail" "deb_mailx"
	sudo dpkg -i ${dir_deb}/heirloom-mailx_14.8.6-1_all.deb
	sudo dpkg -i ${dir_deb}/s-nail_14.8.6-1_arm64.deb
	sudo cp ${dir_deb}/s-nail.rc /etc
}

function cq_deb_stress()
{
	cq_deb_help "stress-ng" "deb_stress"
	sudo dpkg -i ${dir_deb}/libaio1_0.3.110-2_arm64.deb
	sudo dpkg -i ${dir_deb}/stress-ng_0.05.23-1ubuntu2_arm64.deb
}

function cq_deb_s_stress()
{
	local stress_bin=$(ssh slave "which stress-ng")
	if [ -z "${stress_bin}" ]
	then
	{
		scp -r ${RUN_PATH}/lib/cq_deb/deb_stress slave:~/
		ssh slave <<-eeoff
		{
			sudo dpkg -i ~/deb_stress/libaio1_0.3.110-2_arm64.deb
			sudo dpkg -i ~/deb_stress/stress-ng_0.05.23-1ubuntu2_arm64.deb
			rm -r ~/deb_stress
		}
		eeoff
	}
	fi
}

function cq_deb_uuencode()
{
	cq_deb_help "uuencode" "deb_uuencode"
	sudo dpkg -i ${dir_deb}/sharutils_1%3a4.15.2-1ubuntu0.1_arm64.deb
}
