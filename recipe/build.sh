#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=yes \
    ..

cmake --build . -- -j${CPU_COUNT}

# ./autogen.sh
# ./configure --prefix=$PREFIX
# make -j${CPU_COUNT}
# make install
