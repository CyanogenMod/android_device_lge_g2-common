#
# Copyright (C) 2013 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

TARGET_GLOBAL_CFLAGS += -mfpu=neon -mfloat-abi=softfp
TARGET_GLOBAL_CPPFLAGS += -mfpu=neon -mfloat-abi=softfp
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_SMP := true
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_VARIANT := krait
ARCH_ARM_HAVE_TLS_REGISTER := true

# Krait optimizations
TARGET_USE_KRAIT_BIONIC_OPTIMIZATION := true
TARGET_USE_KRAIT_PLD_SET := true
TARGET_KRAIT_BIONIC_PLDOFFS := 10
TARGET_KRAIT_BIONIC_PLDTHRESH := 10
TARGET_KRAIT_BIONIC_BBTHRESH := 64
TARGET_KRAIT_BIONIC_PLDSIZE := 64

TARGET_NO_RADIOIMAGE := true
TARGET_NO_BOOTLOADER := true

TARGET_SPECIFIC_HEADER_PATH := device/lge/g2-common/include

# Kernel information
BOARD_KERNEL_BASE     := 0x00000000
BOARD_KERNEL_CMDLINE := console=ttyHSL0,115200,n8 androidboot.hardware=g2 user_debug=31 msm_rtb.filter=0x0 androidboot.selinux=permissive
BOARD_MKBOOTIMG_ARGS  := --ramdisk_offset 0x05000000 --tags_offset 0x04800000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_SEPARATED_DT := true

BOARD_CUSTOM_BOOTIMG_MK := device/lge/g2-common/releasetools/mkbootimg.mk
TARGET_KERNEL_SOURCE := kernel/lge/msm8974

BOARD_USES_ALSA_AUDIO:= true
BOARD_USES_FLUENCE_INCALL := true
BOARD_USES_SEPERATED_AUDIO_INPUT := true
BOARD_USES_SEPERATED_VOICE_SPEAKER := true
BOARD_USES_SEPERATED_VOICE_SPEAKER_MIC := true

TARGET_BOOTLOADER_BOARD_NAME := galbi
TARGET_BOARD_PLATFORM := msm8974

WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
WPA_SUPPLICANT_VERSION      := VER_0_8_X
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_bcmdhd
BOARD_HOSTAPD_DRIVER        := NL80211
BOARD_HOSTAPD_PRIVATE_LIB   := lib_driver_cmd_bcmdhd
BOARD_WLAN_DEVICE           := bcmdhd
WIFI_DRIVER_FW_PATH_PARAM   := "/sys/module/bcmdhd/parameters/firmware_path"
WIFI_DRIVER_FW_PATH_STA     := "/system/etc/firmware/fw_bcmdhd.bin"
WIFI_DRIVER_FW_PATH_AP      := "/system/etc/firmware/fw_bcmdhd_apsta.bin"
WIFI_DRIVER_FW_PATH_P2P     := "/system/etc/firmware/fw_bcmdhd_p2p.bin"

BOARD_EGL_CFG := device/lge/g2-common/egl.cfg

## the main variant works... except for video scaling :(
TARGET_QCOM_DISPLAY_VARIANT := mdss
USE_OPENGL_RENDERER := true
TARGET_USES_ION := true
TARGET_USES_OVERLAY := true
TARGET_USES_C2D_COMPOSITION := true

BOARD_USES_QCOM_HARDWARE := true
TARGET_USES_QCOM_BSP := true
COMMON_GLOBAL_CFLAGS += -DQCOM_HARDWARE -DQCOM_BSP -DLG_CAMERA_HARDWARE -DLPA_DEFAULT_BUFFER_SIZE=512
#TARGET_DISPLAY_USE_RETIRE_FENCE := true

# Audio
TARGET_QCOM_AUDIO_VARIANT := caf
#TARGET_USES_QCOM_COMPRESSED_AUDIO := true
BOARD_HAVE_LOW_LATENCY_AUDIO := true
BOARD_USES_LEGACY_ALSA_AUDIO := true

# Camera
USE_DEVICE_SPECIFIC_CAMERA := true
# needed for camera blob only
COMMON_GLOBAL_CFLAGS += -DNEEDS_VECTORIMPL_SYMBOLS

# Media
TARGET_QCOM_MEDIA_VARIANT := v4l2

RECOVERY_FSTAB_VERSION = 2
TARGET_RECOVERY_FSTAB = device/lge/g2-common/fstab.g2
BOARD_USE_CUSTOM_RECOVERY_FONT := \"roboto_23x41.h\"
ENABLE_LOKI_RECOVERY := true
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
BOARD_HAS_NO_SELECT_BUTTON := true

TARGET_USERIMAGES_USE_EXT4 := true
BOARD_BOOTIMAGE_PARTITION_SIZE := 23068672 # 22M
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 23068672 # 22M
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 880803840 # 840M

BOARD_USERDATAIMAGE_PARTITION_SIZE := 6189744128 # 5.9G
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)

BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_BCM := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/lge/g2-common/bluetooth
BOARD_BLUEDROID_VENDOR_CONF := device/lge/g2-common/bluetooth/vnd_g2.txt

# GPS
BOARD_VENDOR_QCOM_GPS_LOC_API_HARDWARE := $(TARGET_BOARD_PLATFORM)
TARGET_NO_RPC := true

BOARD_CHARGER_ENABLE_SUSPEND := true

BOARD_HARDWARE_CLASS := device/lge/g2-common/cmhw/

BOARD_SEPOLICY_DIRS += \
    device/lge/g2-common/sepolicy

BOARD_SEPOLICY_UNION := \
    app.te \
    device.te \
    file_contexts

BOARD_NFC_HAL_SUFFIX := g2

TARGET_RELEASETOOLS_EXTENSIONS := device/lge/g2-common/releasetools

COMMON_GLOBAL_CFLAGS += -DBOARD_CHARGING_CMDLINE_NAME='"androidboot.mode"' -DBOARD_CHARGING_CMDLINE_VALUE='"chargerlogo"'
BOARD_USES_QC_TIME_SERVICES := true
