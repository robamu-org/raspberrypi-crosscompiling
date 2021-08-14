#!/bin/bash -i
echo "Entering Raspberry Pi 4 environment"
export PATH=$PATH:"$HOME/x-tools/armv8-rpi4-linux-gnueabihf/bin"
export CROSS_COMPILE="armv8-rpi4-linux-gnueabihf"
export RASPBERRY_VERSION="4"
export LINUX_ROOTFS="${HOME}/rpi4/rootfs"

export CONSOLE_PREFIX="[Raspberry Pi 4]"
exec /bin/bash
