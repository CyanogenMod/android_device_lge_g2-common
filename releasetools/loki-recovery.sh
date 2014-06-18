#!/system/bin/sh
#
# This leverages the loki_patch utility created by djrbliss
# See here for more information on loki: https://github.com/djrbliss/loki
#

export C=/data/local/tmp/loki_tmpdir
RECSIZE=$1
RECSHA1=$2
BOOTSIZE=$3
BOOTSHA1=$4

rm -rf $C
mkdir -p $C

dd if=/dev/block/platform/msm_sdcc.1/by-name/recovery of=$C/recovery.lok
/system/bin/loki_tool unlok $C/recovery.lok $C/recovery.img

if ! applypatch -c EMMC:$C/recovery.img:$RECSIZE:$RECSHA1; then
  log -t recovery "recovery is outdated. unloki-ing all the things"
  dd if=/dev/block/platform/msm_sdcc.1/by-name/boot of=$C/boot.lok
  dd if=/dev/block/platform/msm_sdcc.1/by-name/aboot of=$C/aboot.img
  /system/bin/loki_tool unlok $C/boot.lok $C/boot.img
  log -t recovery "Installing new recovery image"
  applypatch -b /system/etc/recovery-resource.dat EMMC:$C/boot.img:$BOOTSIZE:$BOOTSHA1 EMMC:$C/recovery.img $RECSHA1 $RECSIZE $BOOTSHA1:/system/recovery-from-boot.p || exit 1
  /system/bin/loki_tool patch recovery $C/aboot.img $C/recovery.img $C/recovery.lok || exit 1
  /system/bin/loki_tool flash recovery $C/recovery.lok || exit 1
else
  log -t recovery "Recovery image already installed"
fi

rm -rf $C
exit 0
