# This was tested on the Linux subsystem for Windows with Ubuntu 16.04, should work on the real Ubuntu.

### General

BUILDDIR=`pwd`
sudo apt-get install cmake build-essential curl git subversion 


### KLEE

sudo apt-get install bison flex zlib1g-dev libncurses5-dev libcap-dev \
                     python-minimal

svn co https://llvm.org/svn/llvm-project/llvm/tags/RELEASE_342/final llvm
svn co https://llvm.org/svn/llvm-project/cfe/tags/RELEASE_342/final llvm/tools/clang
svn co https://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_342/final llvm/projects/compiler-rt
svn co https://llvm.org/svn/llvm-project/libcxx/tags/RELEASE_342/final llvm/projects/libcxx
rm -rf llvm/.svn
rm -rf llvm/tools/clang/.svn
rm -rf llvm/projects/compiler-rt/.svn
rm -rf llvm/projects/libcxx/.svn
cd llvm
./configure --enable-optimized --disable-assertions --enable-targets=host --with-python='/usr/bin/python2'
make -j `nproc`
cd ..

git clone --depth 1 https://github.com/stp/minisat.git
rm -rf minisat/.git
cd minisat
make
cd ..

git clone --depth 1 --branch stp-2.2.0 https://github.com/stp/stp.git
rm -rf stp/.git
cd stp
mkdir build
cd build
cmake \
 -DBUILD_STATIC_BIN=ON \
 -DBUILD_SHARED_LIBS:BOOL=OFF \
 -DENABLE_PYTHON_INTERFACE:BOOL=OFF \
 -DMINISAT_INCLUDE_DIR="../../minisat/" \
 -DMINISAT_LIBRARY="../../minisat/build/release/lib/libminisat.a" \
 -DCMAKE_BUILD_TYPE="Release" \
 -DTUNE_NATIVE:BOOL=ON ..
make -j `nproc`
cd ../..

git clone --depth 1 --branch klee_uclibc_v1.0.0 https://github.com/klee/klee-uclibc.git
rm -rf klee-uclibc/.git
cd klee-uclibc
./configure \
 --make-llvm-lib \
 --with-llvm-config="../llvm/Release/bin/llvm-config" \
 --with-cc="../llvm/Release/bin/clang"
make -j `nproc`
cd ..

git clone --depth 1 --branch z3-4.5.0 https://github.com/Z3Prover/z3.git
rm -rf z3/.git
cd z3
python scripts/mk_make.py
cd build
make -j `nproc`
sudo make install
cd ../..

git clone --depth 1 --branch timed-access-dirty https://github.com/vignat/klee.git
rm -rf klee/.git
cd klee
# TODO we should use a KLEE with CMake...
./configure \
 LDFLAGS="-L$BUILDDIR/minisat/build/release/lib/" \
 --with-llvm=$BUILDDIR/llvm/ \
 --with-llvmcc=$BUILDDIR/llvm/Release/bin/clang \
 --with-llvmcxx=$BUILDDIR/llvm/Release/bin/clang++ \
 --with-stp=$BUILDDIR/stp/build/ \
 --with-uclibc=$BUILDDIR/klee-uclibc \
 --with-z3=$BUILDDIR/z3/build/ \
 --enable-cxx11 \
 --enable-posix-runtime
make -j `nproc` ENABLE_OPTIMIZED=1
echo 'PATH=$PATH:'"$BUILDDIR/klee/Release+Asserts/bin" >> ~/.profile
. ~/.profile
cd ..


### VeriFast

sudo apt-get install --no-install-recommends \
                     wget ca-certificates m4 \
                     ocaml-native-compilers gcc camlp4 patch unzip libgtk2.0-dev \
                     valac gtksourceview2.0-dev \
                     liblablgtk2-ocaml-dev liblablgtksourceview2-ocaml-dev

git clone --depth 1 --branch export_path_conditions https://github.com/vignat/verifast
cd verifast/src
make -j `nproc` verifast
echo 'PATH=$PATH:'"$BUILDDIR/verifast/bin" >> ~/.profile
. ~/.profile