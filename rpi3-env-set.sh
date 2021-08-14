#!/bin/bash -i
echo "Entering Raspberry Pi 3 environment"
export PATH=$PATH:"$HOME/x-tools/armv8-rpi3-linux-gnueabihf/bin"
export CROSS_COMPILE="armv8-rpi3-linux-gnueabihf"
export RASPBERRY_VERSION="3"
export LINUX_ROOTFS="${HOME}/rpi3/rootfs"

export CONSOLE_PREFIX="[Raspberry Pi 3]"
exec /bin/bash
