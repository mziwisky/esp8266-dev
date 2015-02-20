#!/bin/bash

# Simple script to prepare the current environment for cross-compiling.
# @author: Slavey Karadzhov <slav@attachix.com>


TOOLCHAIN=$(pushd $(dirname $(readlink -f $BASH_SOURCE)) > /dev/null; pwd; popd > /dev/null)
if ! echo $PATH | grep -q $TOOLCHAIN ; then
    export PATH="${TOOLCHAIN}/usr/bin:${PATH}"
fi

export AR="xtensa-lx106-elf-ar"
export AS="xtensa-lx106-elf-as"
export CXX="xtensa-lx106-elf-g++"
export CC="xtensa-lx106-elf-gcc"
export LD="xtensa-lx106-elf-ld"
export NM="xtensa-lx106-elf-nm"
export OBJDUMP="xtensa-lx106-elf-objdump"
export RANLIB="xtensa-lx106-elf-ranlib"
export READELF="xtensa-lx106-elf-readelf"
export STRIP="xtensa-lx106-elf-strip"

export LD_LIBRARY_PATH="${TOOLCHAIN}/lib:${TOOLCHAIN}/lib32:${LD_LIBRARY_PATH}"

