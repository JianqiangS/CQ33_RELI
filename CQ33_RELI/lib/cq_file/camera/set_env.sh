#!/bin/bash

PWD=$(pwd)
echo ${PWD}

LD_LIBRARY_PATH+=":${PWD}/lib"
export LD_LIBRARY_PATH
echo $PATH
echo $LD_LIBRARY_PATH

#./check_camera
