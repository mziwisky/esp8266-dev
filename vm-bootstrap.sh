#!/usr/bin/env bash
set -e

# This is based on https://github.com/esp8266/esp8266-wiki/wiki/Toolchain

# prepare the machine
sudo apt-get update
sudo apt-get -y install git autoconf build-essential gperf bison flex texinfo libtool libncurses5-dev wget gawk libc6-dev-amd64 unzip
sudo mkdir /opt/Espressif || :
sudo chown vagrant /opt/Espressif

# Build the cross-compiler
cp -r /vagrant/tools/crosstool-NG /opt/Espressif/
cd /opt/Espressif/crosstool-NG
./bootstrap && ./configure -- prefix=`pwd` && make && make install
./ct-ng xtensa-lx106-elf
./ct-ng build

# Set up the SDK
cd /opt/Espressif
unzip /vagrant/tools/sdk/esp_iot_sdk_v0.9.2_14_10_24.zip
mv esp_iot_sdk_v0.9.2 ESP8266_SDK
cp /vagrant/tools/sdk/extra-libs/* ESP8266_SDK/lib/
tar -xzf /vagrant/tools/sdk/extra-includes/include.tgz

# Install ESP tool
sudo dpkg -i /vagrant/tools/esptool/esptool_0.0.2-1_i386.deb

