#!/bin/bash
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
# $PREFIX/bin/$TARGET-gcc --version

echo "Updating and installing dependencies...🕖"

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install gcc -y
sudo apt-get install g++ -y 
sudo apt-get install make -y
sudo apt-get install bison -y
sudo apt-get install flex -y
sudo apt-get install gawk -y 
sudo apt-get install libgmp3-dev -y
sudo apt-get install libmpfr-dev libmpfr-doc libmpfr libmpfr-dbg libmpc-dev -y
sudo apt-get install mpc -y
sudo apt-get install texinfo -y
sudo apt-get install libcloog-isl-dev -y
sudo apt-get install build-essential -y
sudo apt-get install glibc-devel -y
sudo apt-get -y install gcc-multilib libc6-dev-i386 -y

echo "Building cross-compiler for $TARGET...🕖"

# Create build directory
mkdir -p ~/cross-build/$TARGET && cd ~/cross-build/$TARGET

# Download sources
wget https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.gz
wget https://ftp.gnu.org/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.gz
wget https://ftp.gnu.org/gnu/gdb/gdb-12.1.tar.gz
wget https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz

# Build mpc
tar -zvxf mpc-1.3.1.tar.gz
mkdir build-mpc && cd build-mpc
../mpc-1.3.1/configure --prefix="$PREFIX"
make -j2
make -j2 check
make -j2 install
cd ..

# # Build binutils
tar -zvxf binutils-2.40.tar.gz
mkdir build-binutils && cd build-binutils
../binutils-2.40/configure --target=$TARGET --prefix="$PREFIX" \
    --with-sysroot --disable-nls --disable-werror
make -j2
make -j2 install
cd ..

# Build GDB
tar -zvxf gdb-12.1.tar.gz
mkdir build-gdb && cd build-gdb
../gdb-12.1/configure --target=$TARGET --prefix="$PREFIX" \
    --disable-werror
make -j2 all-gdb
make -j2 install-gdb
cd ..

# Build GCC
tar -zvxf gcc-12.2.0.tar.gz
mkdir build-gcc && cd build-gcc
cd build-gcc
../gcc-12.2.0/configure --target=$TARGET --prefix="$PREFIX" \
    --disable-nls --enable-languages=c,c++ --without-headers --with-mpc="$PREFIX"
make -j2 all-gcc
make -j2 all-target-libgcc
make -j2 install-gcc
make -j2 install-target-libgcc

echo "Finished building cross-compiler for $TARGET ✅✅✅"