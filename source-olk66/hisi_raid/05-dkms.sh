echo "Subsitude version name for dkms.conf for upcoming driver updates."

DKMS_DIR=/usr/src/hiraid-2.1.0.1

mkdir -p ${DKMS_DIR}

# Original files
cp hiraid.h ${DKMS_DIR}
cp hiraid_main.c ${DKMS_DIR}
cp Kconfig ${DKMS_DIR}
cp Makefile ${DKMS_DIR}

# New DKMS config
cp dkms.conf ${DKMS_DIR}

echo "DKMS add"
sleep 1

# Add the module to the DKMS tree
dkms add -m hiraid -v 2.1.0.1

echo "DKMS build. Ignore error message."
sleep 1

# Build the module for the current kernel
dkms build -m hiraid -v 2.1.0.1

echo "DKMS install. This will success."
sleep 1

# Install the module
dkms install -m hiraid -v 2.1.0.1

sleep 1

# Verify
dkms status

# Build log
# cat /var/lib/dkms/hiraid/2.1.0.1/6.8.0-139-generic/aarch64/log/make.log

# Delete
# dkms remove -m hiraid -v 2.1.0.1

# Make it persistint after reboot
echo "Update initramfs"
update-initramfs -u