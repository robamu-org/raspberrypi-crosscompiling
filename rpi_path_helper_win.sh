#!/bin/sh
# This script can be used to set the path to the cross-compile toolchain
# A default path is set if the path is not supplied via command line. You can copy
# out of the repository and adapt it to your needs.
if [ $# -eq 1 ];then
	export PATH=$PATH:"$1"
else
	export PATH=$PATH:"/c/SysGCC/raspberry/bin"
	export CROSS_COMPILE="arm-linux-gnueabihf"
	export RASPBERRY_VERSION="4"
	export RASPBIAN_ROOTFS="/c/Users/<UserName>/raspberrypi/rootfs"
fi

