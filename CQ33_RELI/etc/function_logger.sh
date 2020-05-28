#!/bin/bash

function log_out()
{
	local fmt_date=$(date "+%F_%T")
	# output : [xxxx-xx-xx_xx:xx:xx] [lever:DEBUG] \
	# [script:function.sh] [function:main] [content:error file]
	echo -e "[date:${fmt_date}] [level:$1] [script:$2] [function:$3] [content:$4]\n"
}

function log_debug()
{
	log_out "DEBUG" $1 $2 $3
}

function log_info()
{
	log_out "INFO" $1 $2 $3
}

function log_warn()
{
	log_out "WARN" $1 $2 $3
}

function log_error()
{
	log_out "ERROR"	$1 $2 $3
}

function log_fatal()
{
	log_out "FATAL"	$1 $2 $3
}
