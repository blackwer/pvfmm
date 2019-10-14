#!/usr/bin/env bash

mkdir -p build
cd build

CXXFLAGS="-march=x86-64" cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=yes \
    ..

cmake --build . -- -j${CPU_COUNT}
make install

# ./autogen.sh
# ./configure --prefix=$PREFIX
# make -j${CPU_COUNT}
# make install
