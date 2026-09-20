# sudo
checkinstall --pkgname=hiraid --pkgversion=2.1.0.1 --install=no make -C /lib/modules/$(uname -r)/build M=$(pwd) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules_install
