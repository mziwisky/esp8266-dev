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
git pull

if [ ! -d /opt/Espressif/crosstool-NG/builds ]; then
	./bootstrap && ./configure -- prefix=`pwd` && make && make install
	./ct-ng xtensa-lx106-elf
fi

./ct-ng build
# PATH=$PWD/builds/xtensa-lx106-elf/bin:$PATH

# Create symlinks
cd /opt/Espressif/crosstool-NG
sudo rm -rf /usr/bin/xtensa-lx106-elf*
sudo rm -rf /usr/bin/xt-ar /usr/bin/xt-xcc /usr/bin/xt-nm /usr/bin/xt-cpp /usr/bin/xt-objcopy /usr/bin/xt-readelf /usr/bin/xt-objdump

sudo ln -s $PWD/builds/xtensa-lx106-elf/bin/xtensa-lx106-elf-gcc-ar /usr/bin/xtensa-lx106-elf-gcc-ar
sudo ln -s $PWD/builds/xtensa-lx106-elf/bin/xtensa-lx106-elf-gcc /usr/bin/xtensa-lx106-elf-gcc
sudo ln -s $PWD/builds/xtensa-lx106-elf/bin/xtensa-lx106-elf-nm /usr/bin/xtensa-lx106-elf-nm
sudo ln -s $PWD/builds/xtensa-lx106-elf/bin/xtensa-lx106-elf-cpp /usr/bin/xtensa-lx106-elf-cpp
sudo ln -s $PWD/builds/xtensa-lx106-elf/bin/xtensa-lx106-elf-objcopy /usr/bin/xtensa-lx106-elf-objcopy
sudo ln -s $PWD/builds/xtensa-lx106-elf/bin/xtensa-lx106-elf-readelf /usr/bin/xtensa-lx106-elf-readelf
sudo ln -s $PWD/builds/xtensa-lx106-elf/bin/xtensa-lx106-elf-objdump /usr/bin/xtensa-lx106-elf-objdump

sudo ln -s $PWD/builds/xtensa-lx106-elf/bin/xtensa-lx106-elf-gcc-ar /usr/bin/xt-ar
sudo ln -s $PWD/builds/xtensa-lx106-elf/bin/xtensa-lx106-elf-gcc /usr/bin/xt-xcc
sudo ln -s $PWD/builds/xtensa-lx106-elf/bin/xtensa-lx106-elf-nm /usr/bin/xt-nm
sudo ln -s $PWD/builds/xtensa-lx106-elf/bin/xtensa-lx106-elf-cpp /usr/bin/xt-cpp
sudo ln -s $PWD/builds/xtensa-lx106-elf/bin/xtensa-lx106-elf-objcopy /usr/bin/xt-objcopy
sudo ln -s $PWD/builds/xtensa-lx106-elf/bin/xtensa-lx106-elf-readelf /usr/bin/xt-readelf
sudo ln -s $PWD/builds/xtensa-lx106-elf/bin/xtensa-lx106-elf-objdump /usr/bin/xt-objdump

HAS_CROSS_COMPILE=`cat ~/.bashrc | grep CROSS_COMPILE`
if [ -z $HAS_CROSS_COMPILE ]; then
	echo "# Cross Compilation Settings" >> ~/.bashrc
	echo "CROSS_COMPILE=xtensa-lx106-elf-" >> ~/.bashrc
fi

# Set up the SDK
cd /opt/Espressif
LATEST_SDK_VERSION="esp_iot_sdk_v0.9.5"
CURRENT_SDK_VERSION=`readlink ESP8266_SDK`;
if [ "$LATEST_SDK_VERSION" != "$CURRENT_SDK_VERSION" ]; then
	rm -rf ESP8266_SDK
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
	ln -s esp_iot_sdk_v0.9.5 ESP8266_SDK
	cp /vagrant/tools/sdk/extra-libs/* ESP8266_SDK/lib/
	cd /opt/Espressif/ESP8266_SDK
	tar -xzf /vagrant/tools/sdk/extra-includes/include.tgz
fi

# Install ESP tool
sudo dpkg -i /vagrant/tools/esptool/esptool_0.0.2-1_i386.deb

# Install esptool-py
cd /opt/Espressif
if [ ! -d /opt/Espressif/esptool-py ]; then
	git clone https://github.com/themadinventor/esptool esptool-py
fi
cd /opt/Espressif/esptool-py
git pull
sudo rm /usr/local/bin/esptool.py
sudo ln -s $PWD/esptool-py/esptool.py /usr/local/bin/

