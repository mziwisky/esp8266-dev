#!/usr/bin/env bash
set -ex

# This is based on https://github.com/esp8266/esp8266-wiki/wiki/Toolchain

# prepare the machine
sudo apt-get update
sudo apt-get -y install git autoconf build-essential \
     gperf bison flex texinfo libtool libncurses5-dev \
     wget gawk libc6-dev-amd64 python-serial libexpat-dev unzip
if [ ! -d /opt/Espressif ]; then
  sudo mkdir /opt/Espressif
fi
sudo chown vagrant /opt/Espressif

# Build the cross-compiler
cd /opt/

IS_EMPTY=`find Espressif/ -maxdepth 0 -empty -exec echo -n 1 \;`
if [ "$IS_EMPTY" == "1" ]; then
	git clone https://github.com/pfalcon/esp-open-sdk.git Espressif
fi
cd Espressif
git pull
git submodule update
# TODO: if the build fails try to clean the code by uncommenting the line below
# make clean
make STANDALONE=y

export PATH=$PWD/xtensa-lx106-elf/bin:$PATH

# Setup the cross compiler
HAS_PATH=`cat ~/.bashrc | grep "$PWD/xtensa-lx106-elf/bin:" || :`
if [ -z "$HAS_PATH" ]; then
  echo "# Add Xtensa Compiler Path" >> ~/.bashrc
  echo "export PATH=$PWD/builds/xtensa-lx106-elf/bin:\$PATH" >> ~/.bashrc
  echo "export XTENSA_TOOLS_ROOT=$PWD/builds/xtensa-lx106-elf/bin" >> ~/.bashrc
fi

cd $PWD/xtensa-lx106-elf/bin
chmod u+w .
rm -f xt-*
for i in `ls xtensa-lx106*`; do
  XT_NAME=`echo -n $i | sed s/xtensa-lx106-elf-/xt-/`
  echo "symlinking: $XT_NAME"
  ln -s "$i" "$XT_NAME"
done
sudo ln -s xt-cc xt-xcc # the RTOS SDK needs it
sudo chown vagrant -R /opt/Espressif/xtensa-lx106-elf/bin

HAS_CROSS_COMPILE=`cat ~/.bashrc | grep "export CROSS_COMPILE" || :`
if [ -z "$HAS_CROSS_COMPILE" ]; then
  echo "# Cross Compilation Settings" >> ~/.bashrc
  echo "export CROSS_COMPILE=xtensa-lx106-elf-" >> ~/.bashrc
fi

HAS_SDK_BASE=`cat ~/.bashrc | grep "export SDK_BASE" || :`
if [ -z "$HAS_SDK_BASE" ]; then
  echo "# ESP8266 SDK Base" >> ~/.bashrc
  echo "export SDK_BASE=/opt/Espressif/esp8266_sdk" >> ~/.bashrc
  echo "export SDK_EXTRA_INCLUDES=/opt/Espressif/esp8266_sdk/include" >> ~/.bashrc
fi

# Install ESP tool
sudo dpkg -i /vagrant/tools/esptool/esptool_0.0.2-1_i386.deb

# Install esptool-py
sudo ln -sf /opt/Espressif/esptool/esptool.py /usr/local/bin/


# Compile the NodeMCU firmware
if [ ! -d ~/dev ]; then
	mkdir ~/dev
fi
cd ~/dev
if [ ! -d ~/dev/nodemcu-firmware ]; then
	git clone https://github.com/nodemcu/nodemcu-firmware.git
fi
cd nodemcu-firmware
git pull
make

cd ~/dev
# Compile the Micropython firmware
if [ ! -d ~/dev/micropython ]; then
	git clone https://github.com/micropython/micropython.git
fi
cd ~/dev/micropython/esp8266
git pull
make V=1

