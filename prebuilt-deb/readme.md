# Prebuilt Debian package for offline OS installation #

- It is just the [hiraid.ko](../prebuilt-ko/) with the post-install scripts, which is just reproduced from the official "package appraoch".
- **This doesn't include the sourcecode or the dkms scripts.** Therefore you will be very likely fail in the `depmod` stage.
- The general post install procedure applies, because it is a **out-of-tree kernel module**.

```sh
# -rw-r--r-- root/root    990832 2026-09-19 15:52 ./lib/modules/6.8.0-139-generic/updates/hiraid.ko
dpkg -c hiraid_2.1.0.1-1_arm64.deb
# Post install before restart
# Need to switch to "target root" (package count is different! e.g. 97881 vs 92318)
sudo su -
cp /home/ubuntu-server/hisi_raid/hiraid_2.1.0.1-1_arm64.deb /target/root
chroot /target/
cd root
dpkg -i hiraid_2.1.0.1-1_arm64.deb

#Selecting previously unselected package hiraid.
#(Reading database ... 98000 files and directories currently installed.)
#Preparing to unpack hiraid_2.1.0.1-1_arm64.deb ...
#Unpacking preparing
#Unpacking hiraid (2.1.0.1-1) ...
#Setting up hiraid (2.1.0.1-1) ...
#Adding driver to initramfs
#hiraid debian post install Done.

# If no post install actions is found, or it doesn't work
# Add "hiraid" to the following files
depmod
modprobe hiraid
echo "hiraid" | sudo tee -a /etc/initramfs-tools/modules
echo "hiraid" | sudo tee -a /etc/modules-load.d/hiraid.conf
update-initramfs -u
# update-initramfs: Generating /boot/initrd.img-6.8.0-139-generic
mkinitramfs -k -o /boot/initrd.img-$(uname -r) $(uname -r)
# Working files in /var/tmp/mkinitramfs_5m29wj, list of files for main initramfs in /var/tmp/mkinitramfs-MAIN_files_Gu0kYg, list of files for uncompressed initramfs in /var/tmp/mkinitramfs-UNCOMPRESSED_files_ea2SYn, early initramfs in /var/tmp/mkinitramfs-FW_jkxvxy and overlay in /var/tmp/mkinitramfs-OL_SedKw5

# Install log without error
exit
exit
# Back to user mode. Move to install page and reboot
```
