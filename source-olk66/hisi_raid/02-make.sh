#export CC=clang
#export CLANG_TRIPLE=aarch64-linux-gnu-
#export CROSS_COMPILE=aarch64-linux-gnu-
#export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

make -C /lib/modules/$(uname -r)/build M=$(pwd) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules