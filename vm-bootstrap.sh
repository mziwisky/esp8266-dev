#!/usr/bin/env bash
set -e

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
cd /opt/Espressif
if [ ! -d /opt/Espressif/crosstool-NG ]; then
	git clone -b lx106 git://github.com/jcmvbkbc/crosstool-NG.git
fi

cd /opt/Espressif/crosstool-NG

# Git complains if these values are not set
GIT_USERNAME=`git config --global user.name : `
if [ -z "$GIT_USERNAME" ]; then
	git config --global user.name "Your Name"
fi
GIT_USEREMAIL=`git config --global user.email : `
if [ -z "$GIT_USEREMAIL" ]; then
	git config --global user.email "you@example.com"
fi

function gitsha() { 
	git show --format=%H | head -1; 
}
OLDSHA=`gitsha`
git pull origin lx106

if [ "$OLDSHA" != `gitsha` ] || [ ! -d /opt/Espressif/crosstool-NG/builds ]; then
	./bootstrap && ./configure -- prefix=`pwd` && make && make install
	./ct-ng xtensa-lx106-elf
fi

./ct-ng build

# Setup the cross compiler
HAS_PATH=`cat ~/.bashrc | grep "/opt/Espressif/crosstool-NG/builds/xtensa-lx106-elf/bin:" || :`
if [ -z "$HAS_PATH" ]; then
	echo "# Add Xtensa Compiler Path" >> ~/.bashrc
	echo "export PATH=$PWD/builds/xtensa-lx106-elf/bin:\$PATH" >> ~/.bashrc
	echo "export XTENSA_TOOLS_ROOT=$PWD/builds/xtensa-lx106-elf/bin" >> ~/.bashrc 
fi

cd /opt/Espressif/crosstool-NG/builds/xtensa-lx106-elf/bin
sudo rm -f xt-*
for i in `ls xtensa-lx106*`; do
	XT_NAME=`echo -n $i | sed s/xtensa-lx106-elf-/xt-/`
	echo "symlinking: $XT_NAME"
	sudo ln -s "$i" "$XT_NAME"
done
sudo ln -s xt-cc xt-xcc # the RTOS SDK needs it
sudo chown vagrant -R /opt/Espressif/crosstool-NG/builds/xtensa-lx106-elf/bin

HAS_CROSS_COMPILE=`cat ~/.bashrc | grep "CROSS_COMPILE" || :`
if [ -z "$HAS_CROSS_COMPILE" ]; then
	echo "# Cross Compilation Settings" >> ~/.bashrc
	echo "export CROSS_COMPILE=xtensa-lx106-elf-" >> ~/.bashrc
fi

# Set up the SDK
# TODO: can this be automated? is there a place to check what the latest SDK
# is, and then install it the same way each time? probably not -- updates to
# this repo will have to manually change this chunk of steps.
cd /opt/Espressif
LATEST_SDK_VERSION="esp_iot_sdk_v0.9.5"
CURRENT_SDK_VERSION=`readlink esp8266_sdk || :`

if [ "$LATEST_SDK_VERSION" != "$CURRENT_SDK_VERSION" ]; then
	rm -rf esp8266_sdk
	unzip -o /vagrant/tools/sdk/esp_iot_sdk_v0.9.5_15_01_23.zip
	mv License esp_iot_sdk_v0.9.5/
	mv release_note.txt esp_iot_sdk_v0.9.5/
	cd esp_iot_sdk_v0.9.5/include
	unzip -o /vagrant/tools/sdk/esp_iot_sdk_v0.9.5_15_01_23_patch1.zip  user_interface.h
	cd ../lib
	mv libmain.a libmain.a.old

	unzip -o /vagrant/tools/sdk/esp_iot_sdk_v0.9.5_15_01_23_patch1.zip libmain_fix_0.9.5.a
	mv libmain_fix_0.9.5.a libmain.a
	cd ../../
	ln -s esp_iot_sdk_v0.9.5 esp8266_sdk
	cp /vagrant/tools/sdk/extra-libs/* esp8266_sdk/lib/
	cd /opt/Espressif/esp8266_sdk
	tar -xzf /vagrant/tools/sdk/extra-includes/include.tgz
fi

HAS_SDK_BASE=`cat ~/.bashrc | grep "ESP8266_SDK_BASE" || :`
if [ -z "$HAS_SDK_BASE" ]; then
	echo "# ESP8266 SDK Base" >> ~/.bashrc
	echo "export ESP8266_SDK_BASE=/opt/Espressif/esp8266_sdk" >> ~/.bashrc
	echo "export SDK_BASE=/opt/Espressif/esp8266_sdk" >> ~/.bashrc
	echo "export SDK_EXTRA_INCLUDES=/opt/Espressif/esp8266_sdk/include" >> ~/.bashrc 
fi

# Set up the RTOS SDK
cd /opt/Espressif
if [ ! -d /opt/Espressif/esp8266_rtos_sdk ]; then
	git clone https://github.com/espressif/esp_iot_rtos_sdk.git esp8266_rtos_sdk
	git clone https://github.com/espressif/esp_iot_rtos_sdk_lib.git esp8266_rtos_sdk_lib
	cp esp8266_rtos_sdk_lib/lib/* esp8266_rtos_sdk/lib
	sed -i -e 's/xt-xcc/xt-cc/' /opt/Espressif/esp8266_rtos_sdk/Makefile
fi

cd /opt/Espressif/esp8266_rtos_sdk
git pull origin master
make

HAS_RTOS_SDK_BASE=`cat ~/.bashrc | grep "ESP8266_RTOS_SDK_BASE" || :`
if [ -z "$HAS_RTOS_SDK_BASE" ]; then
	echo "# ESP8266 RTOS SDK Base" >> ~/.bashrc
	echo "export ESP8266_RTOS_SDK_BASE=/opt/Espressif/esp8266_rtos_sdk" >> ~/.bashrc
fi


# Install ESP tool
sudo dpkg -i /vagrant/tools/esptool/esptool_0.0.2-1_i386.deb

# Install esptool-py
cd /opt/Espressif
if [ ! -d /opt/Espressif/esptool-py ]; then
	git clone https://github.com/themadinventor/esptool esptool-py
fi
cd /opt/Espressif/esptool-py
git pull origin master
sudo ln -sf $PWD/esptool.py /usr/local/bin/

