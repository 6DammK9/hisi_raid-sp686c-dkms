# Build raid driver "hiraid" from source (OLK-6.6) #

- Fallback from [cmake approach](https://support.huawei.com/enterprise/zh/doc/EDOC1100408971/d57de8e6).

- [Latest git repo from openEuler OLK-6.6 branch.](https://gitcode.com/openeuler/kernel/blob/OLK-6.6/drivers/scsi/hisi_raid)
  - From [this random post](https://mailweb.openeuler.org/archives/list/kernel@openeuler.org/message/D6WZNIVI4RQYS75KRL33F6UXE4I3UWPN/), `CONFIG_SCSI_HISI_RAID=m`
  - *It would support most 6.x kernels.* ~~Impossible to proof because the only ITAI server I'm accessing is going to production soon.~~

- Replace the branch name for 5.x / 4.x kernels:
  - 4.x: [openEuler-1.0-LTS](https://gitee.com/openeuler/kernel/tree/openEuler-1.0-LTS/drivers/scsi/hisi_raid)
  - 5.x: [OLK-5.10](https://gitee.com/openeuler/kernel/tree/OLK-5.10/drivers/scsi/hisi_raid)

## Install via DKMS ##

- **Suggested approach. DKMS is the primary method to make driver persist across OS / kernel update.**

```sh
# Get hisi_raid to the local machine by SFTP / ISO mount / wget etc.
# Expected ARM server. May be "manylinux" already.

# Install building packages. Takes a long time.
sudo sh 01-install.sh

# Check if DKMS is installed
dkms --version

# DKMS approach. Watch logs for details.
sudo sh 05-install.sh
```

## Build and install native DEB package ##

- *Designed for remote install, which the server build the kernel modules locally.*

```sh
# Get hisi_raid to the local machine by SFTP / ISO mount / wget etc.
# Expected ARM server in Ubuntu 24.04.5

# Install building packages. Takes a long time.
sudo sh 01-install.sh

# Build the kernel module. Ignore warning messages.
sh 02-make.sh

# Load the built kernel module (to detect the RAID drives)
sudo insmod hiraid.ko

# Clean up if it fails. 
# sh 03-clean.sh

# Build the deb for post OS install
sudo 04-deb.sh

# Test installation
sudo dpkg -i hiraid_2.1.0.1-1_arm64.deb

# Remove package
# sudo dpkg -r hiraid

# If it fails, force remove
# sudo dpkg --remove --force-remove-reinstreq hiraid
```

## Procedure explained ##

### Build from source ###

```sh
# Remove existing version
sudo dpkg -r hiraid

# Need cmake to build modules.
sudo apt update
# $(uname -r)=6.8.0-139-generic
# sudo apt install build-essential checkinstall linux-headers-$(uname -r) 
sudo apt install checkinstall cmake gcc-13-aarch64-linux-gnu build-essential linux-headers-$(uname -r) -y

# make
# make: *** No targets.  Stop.

# cp ./hisi_raid/* /root/hiraid
# sudo su -
# cd /root/hiraid

cd hisi_raid

# make all
# make -C /lib/modules/$(uname -r)/build M=$(pwd) modules
make -C /lib/modules/$(uname -r)/build M=$(pwd) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules
# make clean
make -C /lib/modules/$(uname -r)/build M=$(pwd) clean
```

- (260920) Instead of original log, here is the extended DKMS build log.

```log
DKMS make.log for hiraid-2.1.0.1 for kernel 6.8.0-139-generic (aarch64)
Sun Sep 20 05:59:56 PM HKT 2026
make: Entering directory '/usr/src/linux-headers-6.8.0-139-generic'
  CC [M]  /usr/src/hiraid-2.1.0.1/hiraid_main.o
/usr/src/hiraid-2.1.0.1/hiraid_main.c:659:6: warning: no previous prototype for ‘hiraid_io_recognition_init’ [-Wmissing-prototypes]
  659 | void hiraid_io_recognition_init(struct hiraid_dev *hdev)
      |      ^~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/src/hiraid-2.1.0.1/hiraid_main.c:681:23: warning: no previous prototype for ‘hiraid_io_pick_stream’ [-Wmissing-prototypes]
  681 | struct hiraid_stream *hiraid_io_pick_stream(struct hiraid_dev *hdev,
      |                       ^~~~~~~~~~~~~~~~~~~~~
/usr/src/hiraid-2.1.0.1/hiraid_main.c:4074:6: warning: no previous prototype for ‘scsi_ncq_prio_support’ [-Wmissing-prototypes]
 4074 | bool scsi_ncq_prio_support(struct scsi_device *sdev, struct hiraid_dev *hdev)
      |      ^~~~~~~~~~~~~~~~~~~~~
  LD [M]  /usr/src/hiraid-2.1.0.1/hiraid.o
  MODPOST /usr/src/hiraid-2.1.0.1/Module.symvers
  CC [M]  /usr/src/hiraid-2.1.0.1/hiraid.mod.o
  LD [M]  /usr/src/hiraid-2.1.0.1/hiraid.ko
  BTF [M] /usr/src/hiraid-2.1.0.1/hiraid.ko
Skipping BTF generation for /usr/src/hiraid-2.1.0.1/hiraid.ko due to unavailability of vmlinux
make: Leaving directory '/usr/src/linux-headers-6.8.0-139-generic'
```

- Without build from source:

```sh
modprobe hiraid
# modprobe: ERROR: could not insert 'hiraid': Exec format error

sudo dmesg
# [ 3217.369498] hiraid: disagrees about version of symbol module_layout
# [ 5142.798058] hiraid: disagrees about version of symbol module_layout
```

- With build from source:

```sh
sudo modprobe ./hiraid.ko
# No log, no error.

modinfo hiraid.ko | grep vermagic
# vermagic:       6.8.0-139-generic SMP preempt mod_unload modversions aarch64

sudo dmesg
```

```log
[ 7707.154331] hiraid 0000:04:00.0: alloc admin cmds success, num[112]
[ 7707.154351] hiraid 0000:04:00.0: total queues num[97]
[ 7707.154367] hiraid 0000:04:00.0: set dma mask[46] success
[ 7707.154542] hiraid 0000:04:00.0: start disable controller
[ 7707.154555] cma_alloc: 2 callbacks suppressed
[ 7707.154557] cma: cma_alloc: reserved: alloc failed, req-size: 2 pages, ret: -12
[ 7707.154595] cma: cma_alloc: reserved: alloc failed, req-size: 3 pages, ret: -12
[ 7707.154616] hiraid 0000:04:00.0: start enable controller
[ 7707.156345] hiraid 0000:04:00.0: setup admin queue success, queuecount[1] online[1] pagesize[4096]
[ 7707.158907] hiraid 0000:04:00.0: device_num = 240
[ 7707.158912] hiraid 0000:04:00.0: max_cmd = 4096
[ 7707.158914] hiraid 0000:04:00.0: max_channel = 4
[ 7707.158916] hiraid 0000:04:00.0: max_tgt_id = 128
[ 7707.158917] hiraid 0000:04:00.0: max_lun = 2
[ 7707.158919] hiraid 0000:04:00.0: max_num_sge = 128
[ 7707.158921] hiraid 0000:04:00.0: lun_num_boot = 5
[ 7707.158923] hiraid 0000:04:00.0: max_data_transfer_size = 8
[ 7707.158925] hiraid 0000:04:00.0: abort_cmd_limit = 255
[ 7707.158926] hiraid 0000:04:00.0: asyn_event_num = 4
[ 7707.158928] hiraid 0000:04:00.0: card_type = 1
[ 7707.158930] hiraid 0000:04:00.0: pt_use_sgl = 1
[ 7707.158932] hiraid 0000:04:00.0: rtd3e = 200000000
[ 7707.158934] hiraid 0000:04:00.0: serial_num = 2102313XXGFSQC003891
[ 7707.158935] hiraid 0000:04:00.0: fw_verion = 1.3.13.18
[ 7707.175173] cma: cma_alloc: reserved: alloc failed, req-size: 5 pages, ret: -12
[ 7707.175240] cma: cma_alloc: reserved: alloc failed, req-size: 33 pages, ret: -12
[ 7707.175346] cma: cma_alloc: reserved: alloc failed, req-size: 25 pages, ret: -12
[ 7707.175413] cma: cma_alloc: reserved: alloc failed, req-size: 5 pages, ret: -12
[ 7707.175460] cma: cma_alloc: reserved: alloc failed, req-size: 33 pages, ret: -12
[ 7707.175541] cma: cma_alloc: reserved: alloc failed, req-size: 25 pages, ret: -12
[ 7707.175603] cma: cma_alloc: reserved: alloc failed, req-size: 5 pages, ret: -12
[ 7707.175649] cma: cma_alloc: reserved: alloc failed, req-size: 33 pages, ret: -12
[ 7707.181684] hiraid 0000:04:00.0: max_qid[96] queuecount[97] onlinequeue[1] ioqdepth[1025]
[ 7709.474902] hiraid 0000:04:00.0: queue_count[97] online_queue[97] last_online[97]
[ 7709.474924] hiraid 0000:04:00.0: mapbuf size[72], alloc_size[8]
[ 7709.474927] hiraid 0000:04:00.0: nr_hw_queues[96] can_queue[1024] unique_id[1024] cmd_size[80]
[ 7709.474932] scsi host8: hiraid
[ 7709.494240] hiraid 0000:04:00.0: mapbuf size[72], alloc_size[8]
[ 7709.494538] hiraid 0000:04:00.0: send async event to controller, cid[112]
[ 7709.494544] hiraid 0000:04:00.0: send async event to controller, cid[113]
[ 7709.494546] hiraid 0000:04:00.0: send async event to controller, cid[114]
[ 7709.494549] hiraid 0000:04:00.0: send async event to controller, cid[115]
[ 7709.498916] hiraid 0000:04:00.0: alloc io pthru cmd success, pthrunum[96]
[ 7709.510871] hiraid 0000:04:00.0: get dev list ndev num[2]
[ 7709.510882] hiraid 0000:04:00.0: devices[0], hdid[1] target[0] channel[2] lun[1] attr[0x10]
[ 7709.510886] hiraid 0000:04:00.0: devices[1], hdid[2] target[1] channel[2] lun[1] attr[0x8]
[ 7709.510895] hiraid 0000:04:00.0: scan work add device num[2]
[ 7709.510899] hiraid 0000:04:00.0: add device, hdid[1] target[0] channel[2] lun[1] attr[0x10]
[ 7709.511587] hiraid 0000:04:00.0: match device success, channel:target:lun[2:0:1]
[ 7709.534872] scsi 8:2:0:0: Direct-Access     HUAWEI   RAID1            C00  PQ: 0 ANSI: 5
[ 7709.534885] hiraid 0000:04:00.0: sdev->channel:id:lun[2:0:0] scmd_timeout[180]s maxsec[2048]
[ 7709.726865] hiraid 0000:04:00.0: add device, hdid[2] target[1] channel[2] lun[1] attr[0x8]
[ 7709.727538] hiraid 0000:04:00.0: match device success, channel:target:lun[2:1:1]
[ 7709.750867] scsi 8:2:1:0: Direct-Access     HUAWEI   RAID10           C00  PQ: 0 ANSI: 5
[ 7709.750878] hiraid 0000:04:00.0: sdev->channel:id:lun[2:1:0] scmd_timeout[180]s maxsec[2048]
[ 7709.943567] sd 8:2:0:0: Attached scsi generic sg0 type 0
[ 7709.944363] sd 8:2:1:0: Attached scsi generic sg1 type 0
[ 7709.966889] sd 8:2:0:0: [sda] 1873287168 512-byte logical blocks: (959 GB/893 GiB)
[ 7709.966892] sd 8:2:1:0: [sdb] 46871629824 512-byte logical blocks: (24.0 TB/21.8 TiB)
[ 7709.966907] sd 8:2:0:0: [sda] 4096-byte physical blocks
[ 7709.978867] sd 8:2:1:0: [sdb] Write Protect is off
[ 7709.978879] sd 8:2:1:0: [sdb] Mode Sense: 1f 00 10 08
[ 7709.978885] sd 8:2:0:0: [sda] Write Protect is off
[ 7709.978894] sd 8:2:0:0: [sda] Mode Sense: 1f 00 10 08
[ 7709.990910] sd 8:2:1:0: [sdb] Write cache: disabled, read cache: disabled, supports DPO and FUA
[ 7709.990934] sd 8:2:0:0: [sda] Write cache: disabled, read cache: disabled, supports DPO and FUA
[ 7710.002879] sd 8:2:1:0: [sdb] Preferred minimum I/O size 262144 bytes
[ 7710.002889] sd 8:2:1:0: [sdb] Optimal transfer size 1048576 bytes
[ 7710.002903] sd 8:2:0:0: [sda] Preferred minimum I/O size 65536 bytes
[ 7710.002911] sd 8:2:0:0: [sda] Optimal transfer size 65536 bytes
[ 7710.051645] sd 8:2:0:0: [sda] Attached SCSI disk
[ 7710.058545] sd 8:2:1:0: [sdb] Attached SCSI disk
```

### Export deb file for OS post installation ###

- Build the module again with different CLI. [Ref.](https://www.cnblogs.com/chulia20002001/p/7010856.html)
  - [ssgelm/checkinstall](https://github.com/ssgelm/checkinstall) which exposes install guide

```sh
# The make part is the same
sudo checkinstall --pkgname=hiraid --pkgversion=2.1.0.1 --install=no make -C /lib/modules/$(uname -r)/build M=$(pwd) modules_install

dpkg -c hiraid_2.1.0.1-1_arm64.deb
# -rw-r--r-- root/root    990832 2026-09-19 15:52 ./lib/modules/6.8.0-139-generic/updates/hiraid.ko

# From kunlun ISO
# -rw-r--r-- slave1/slave1 1048996 2026-06-29 10:37 ./lib/modules/6.8.0-31-generic/weak-updates/hiraid/hiraid.ko.new

# Important scripts is found.
dpkg-deb -R RAID-B80121-Ubuntu24.04-hiraid-2.0.4.3-aarch64.deb tmp
```

- Sanitry check for install / uninstall the deb package:

```sh
sudo dpkg -r hiraid
#(Reading database ... 98002 files and directories currently installed.)
#Removing hiraid (2.1.0.1-1) ...
#hiraid debian post uninstall Done.

sudo dpkg -i hiraid_2.1.0.1-1_arm64.deb 
#Selecting previously unselected package hiraid.
#(Reading database ... 98000 files and directories currently installed.)
#Preparing to unpack hiraid_2.1.0.1-1_arm64.deb ...
#Unpacking preparing
#Unpacking hiraid (2.1.0.1-1) ...
#Setting up hiraid (2.1.0.1-1) ...
#hiraid debian post install Done.
```

### Integrate with DKMS ###

- Read [05-dkms.sh](./hisi_raid/05-dkms.sh) for details. Instead of custom `Makefile`, I customize the `dkms.conf` instead.
