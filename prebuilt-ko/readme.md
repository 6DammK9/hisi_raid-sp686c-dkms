# Prebuilt Kernel Module for offline OS installation #

- Notice that `insmod` is very strict which checks the `vermagic`, so make sure your target OS version down to specific minor version (e.g. Ubuntu 24.04.5).

```sh
# 6.8.0-139-generic
uname -r
# vermagic:       6.8.0-139-generic SMP preempt mod_unload modversions aarch64
modinfo hiraid.ko | grep vermagic
# Switch to insert kernel module in page "mirror"
# Or feed it in initramfs busybox e.g. wget or mount from nvme / achi drive
insmod hiraid.ko
```

- If you have missed the [post install](../prebuilt-deb/) scripts and getting stuck after reboot, this may help you to get into OS.

- Here is an example for the `wget` approach.

```sh
# Set up the ethernet connection from scratch
ifconfig enp1s0f0np0 192.168.50.164 netmask 255.255.255.0 broadcast 192.168.50.1
ifconfig enp1s0f0np0 up

# No SFTP, only wget is available
cd /lib/modules/6.8.0-139-generic
mkdir updates
cd updates
wget 192.168.50.87/hiraid.ko
insmod hiraid.ko

# Magic happens!
exit
```
