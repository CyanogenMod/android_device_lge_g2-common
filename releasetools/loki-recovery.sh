#!/system/bin/sh
#
# This leverages the loki_patch utility created by djrbliss
# See here for more information on loki: https://github.com/djrbliss/loki
#

export C=/data/local/tmp/loki_tmpdir

mkdir -p $C
dd if=/dev/block/platform/msm_sdcc.1/by-name/aboot of=$C/aboot.img
dd if=/dev/block/platform/msm_sdcc.1/by-name/recovery of=$C/recovery.img
/system/bin/loki_patch recovery $C/aboot.img $C/recovery.img $C/recovery.lok || exit 1
/system/bin/loki_flash recovery $C/recovery.lok || exit 1
rm -rf $C
exit 0
