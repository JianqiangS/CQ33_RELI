#!/bin/bash

PWD=$(pwd)
echo ${PWD}

LD_LIBRARY_PATH+=":${PWD}/lib"
export LD_LIBRARY_PATH
echo $PATH

./check_camera $1
