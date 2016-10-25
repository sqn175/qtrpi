#!/bin/bash

ROOT=${QTRPI_COMPILE_ROOT:-$(pwd)/cross-compile}
RPI_HOST=${1:-$QTRPI_HOST}

cd $ROOT/raspbian

sudo apt-get install qemu-user-static
sudo cp /usr/bin/qemu-arm-static sysroot/usr/bin/

# Mount sysroot part
sudo mount -o bind /proc sysroot/proc
sudo mount -o bind /dev sysroot/dev
sudo mount -o bind /sys sysroot/sys

# comment preload conf to avoid the following error during apt-get build-dep command
# qemu: uncaught target signal 4 (Illegal instruction) - core dumped
# Illegal instruction
sudo sed -i '/./s/^/#/g' sysroot/etc/ld.so.preload

# Uncomment deb-src to have access to dev packages
sudo sed -i '/deb-src/s/^#//g' sysroot/etc/apt/sources.list

# Global update

# Enter the Matrix
#sudo chroot sysroot
# not needed
#apt-get update
#apt-get dist-upgrade
# Care with changelog and chromium waiting a key pres...

# Install Qt dependencies
sudo chroot sysroot /bin/bash -c 'apt-get update'
sudo chroot sysroot /bin/bash -c 'apt-get install -y apt-transport-https'
sudo chroot sysroot /bin/bash -c 'apt-get build-dep -y qt4-x11 qtbase-opensource-src'
sudo chroot sysroot /bin/bash -c 'apt-get install -y libudev-dev libinput-dev libts-dev libxcb-xinerama0-dev libxcb-xinerama0'

sudo umount sysroot/sys
sudo umount sysroot/dev
sudo umount sysroot/proc

sudo chown -R $USER:$USER sysroot

ssh $RPI_HOST sudo mkdir /usr/local/qt5pi
ssh $RPI_HOST sudo apt-get install -y libts-0.0-0 libinput5
