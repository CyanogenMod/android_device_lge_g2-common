#
# Copyright (C) 2013 The Android Open-Source Project
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

# Overlays
DEVICE_PACKAGE_OVERLAYS := $(LOCAL_PATH)/overlay

# Device uses high-density artwork where available 
PRODUCT_AAPT_CONFIG := normal hdpi xhdpi xxhdpi
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# Init
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/init.g2.rc:root/init.g2.rc \
	$(LOCAL_PATH)/init.g2.usb.rc:root/init.g2.usb.rc \
	$(LOCAL_PATH)/ueventd.g2.rc:root/ueventd.g2.rc \
	$(LOCAL_PATH)/fstab.g2:root/fstab.g2

# Sensors
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/sensors.sh:root/sensors.sh \
    $(LOCAL_PATH)/configs/sap.conf:system/etc/sap.conf \
    $(LOCAL_PATH)/configs/sensor_def_common.conf:system/etc/sensor_def_common.conf

# Audio
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/configs/audio_policy.conf:system/etc/audio_policy.conf \
	$(LOCAL_PATH)/configs/snd_soc_msm_Taiko:system/etc/snd_soc_msm/snd_soc_msm_Taiko \
	$(LOCAL_PATH)/configs/media_profiles.xml:system/etc/media_profiles.xml \
	$(LOCAL_PATH)/configs/media_codecs.xml:system/etc/media_codecs.xml \
	$(LOCAL_PATH)/configs/mixer_paths.xml:system/etc/mixer_paths.xml \
	$(LOCAL_PATH)/configs/audio_effects.conf:system/vendor/etc/audio_effects.conf

# Thermal
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/configs/thermald-8974.conf:system/etc/thermald-8974.conf \
	$(LOCAL_PATH)/configs/thermal-engine-8974.conf:system/etc/thermal-engine-8974.conf \
	$(LOCAL_PATH)/configs/thermal-engine-8974-default.conf:system/etc/thermal-engine-8974-default.conf

# Touchscreen
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/configs/touch_dev.idc:system/usr/idc/touch_dev.idc

# WiFi
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/configs/bcmdhd.cal:system/etc/wifi/bcmdhd.cal

PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/configs/DxHDCP.cfg:system/etc/DxHDCP.cfg

# Permissions
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
	frameworks/native/data/etc/android.hardware.camera.autofocus.xml:system/etc/permissions/android.hardware.camera.autofocus.xml \
	frameworks/native/data/etc/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
	frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:system/etc/permissions/android.hardware.camera.flash-autofocus.xml \
	frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
	frameworks/native/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
	frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
	frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:system/etc/permissions/android.hardware.sensor.gyroscope.xml \
	frameworks/native/data/etc/android.hardware.sensor.barometer.xml:system/etc/permissions/android.hardware.sensor.barometer.xml \
	frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:system/etc/permissions/android.hardware.sensor.stepcounter.xml \
	frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:system/etc/permissions/android.hardware.sensor.stepdetector.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
	frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/android.hardware.audio.low_latency.xml:system/etc/permissions/android.hardware.audio.low_latency.xml \
	frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml \
	frameworks/native/data/etc/android.hardware.telephony.gsm.xml:system/etc/permissions/android.hardware.telephony.gsm.xml \
	frameworks/native/data/etc/android.hardware.telephony.cdma.xml:system/etc/permissions/android.hardware.telephony.cdma.xml

# GPS
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/configs/gps.conf:system/etc/gps.conf \
	$(LOCAL_PATH)/configs/flp.conf:system/etc/flp.conf \
	$(LOCAL_PATH)/configs/izat.conf:system/etc/izat.conf \
	$(LOCAL_PATH)/configs/sec_config:system/etc/sec_config

# Charger
PRODUCT_PACKAGES += \
	charger_res_images \
	charger

# Live Wallpapers
PRODUCT_PACKAGES += \
	LiveWallpapers \
	LiveWallpapersPicker \
	VisualizationWallpapers \
	librs_jni

# NFC packages
PRODUCT_PACKAGES += \
	Tag \
	com.android.nfc_extras

# NFCEE access control
ifeq ($(TARGET_BUILD_VARIANT),user)
	NFCEE_ACCESS_PATH := $(LOCAL_PATH)/nfc/nfcee_access.xml
else
	NFCEE_ACCESS_PATH := $(LOCAL_PATH)/nfc/nfcee_access_debug.xml
endif

# NFC access control + feature files + configuration
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/nfc/libnfc-brcm.conf:system/etc/libnfc-brcm.conf \
	$(NFCEE_ACCESS_PATH):system/etc/nfcee_access.xml \
	frameworks/native/data/etc/com.android.nfc_extras.xml:system/etc/permissions/com.android.nfc_extras.xml \
	frameworks/native/data/etc/android.hardware.nfc.xml:system/etc/permissions/android.hardware.nfc.xml \
	frameworks/native/data/etc/android.hardware.nfc.hce.xml:system/etc/permissions/android.hardware.nfc.hce.xml

PRODUCT_PROPERTY_OVERRIDES += \
	ro.sf.lcd_density=480 \
	ro.opengles.version=196608 \
	ro.loki_enabled=1

# Audio configuration
PRODUCT_PROPERTY_OVERRIDES += \
	ro.qc.sdk.audio.fluencetype=fluence \
	persist.audio.fluence.voicecall=true \
	persist.audio.fluence.mode=endfire \
	persist.audio.handset.mic=digital \
	af.resampler.quality=4 \
	audio.offload.min.duration.secs=30 \
	audio.offload.buffer.size.kb=32 \
	av.offload.enable=true

# Ril
PRODUCT_PROPERTY_OVERRIDES += \
	persist.radio.apm_sim_not_pwdn=1 \
	persist.radio.add_power_save=1 \
	ro.telephony.call_ring.multiple=0 \
	ro.telephony.ril_class=LgeLteRIL \
	ro.telephony.ril.v3=qcomdsds

PRODUCT_PROPERTY_OVERRIDES += persist.hwc.mdpcomp.enable=true

PRODUCT_TAGS += dalvik.gc.type-precise

PRODUCT_PACKAGES += \
	librs_jni \
	com.android.future.usb.accessory

# Filesystem management tools
PRODUCT_PACKAGES += \
	e2fsck

PRODUCT_PACKAGES += \
	libgenlock \
	hwcomposer.msm8974 \
	gralloc.msm8974 \
	copybit.msm8974 \
	memtrack.msm8974

# Local wrapper for fixups
PRODUCT_PACKAGES += \
	camera.g2

# Audio
PRODUCT_PACKAGES += \
	audio.primary.msm8974 \
	audio.a2dp.default \
	audio.usb.default \
	audio.r_submix.default \
	libaudio-resampler \
	libqcomvisualizer \
	libqcomvoiceprocessing \
	libqcomvoiceprocessingdescriptors

# Media
PRODUCT_PACKAGES += \
	libmm-omxcore \
	libdivxdrmdecrypt \
	libOmxVdec \
	libOmxVenc \
	libOmxCore \
	libstagefrighthw \
	libc2dcolorconvert

# GPS
PRODUCT_PACKAGES += \
	libloc_adapter

# Wifi
PRODUCT_PACKAGES += \
	libnetcmdiface

PRODUCT_PACKAGES += \
	hwaddrs

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
	rild.libpath=/vendor/lib/libril-qc-qmi-1.so

PRODUCT_PROPERTY_OVERRIDES += \
	drm.service.enabled=true

PRODUCT_PROPERTY_OVERRIDES += \
	ro.bt.bdaddr_path=/data/misc/bdaddr

PRODUCT_PROPERTY_OVERRIDES += \
	wifi.interface=wlan0 \
	wifi.supplicant_scan_interval=30

# Enable AAC 5.1 output
PRODUCT_PROPERTY_OVERRIDES += \
	media.aac_51_output_enabled=true

PRODUCT_PROPERTY_OVERRIDES += \
	debug.egl.recordable.rgba8888=1

# Sensors
PRODUCT_PROPERTY_OVERRIDES += \
	ro.qualcomm.sensors.qmd=true \
	ro.qc.sdk.sensors.gestures=true \
	ro.qualcomm.sensors.pedometer=true \
	ro.qualcomm.sensors.pam=true \
	ro.qualcomm.sensors.scrn_ortn=true \
	debug.qualcomm.sns.hal=w \
	debug.qualcomm.sns.daemon=w \
	debug.qualcomm.sns.libsensor1=e

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
	persist.sys.usb.config=mtp

PRODUCT_PACKAGES += \
	lights.g2

# Input resampling configuration
PRODUCT_PROPERTY_OVERRIDES += \
	ro.input.noresample=1

# This hw ships locked, work around it with loki
PRODUCT_PACKAGES += \
	loki.sh \
	loki_tool_static_g2 \
	recovery-transform.sh

PRODUCT_PROPERTY_OVERRIDES += \
	ro.hwui.texture_cache_size=72 \
	ro.hwui.layer_cache_size=48 \
	ro.hwui.r_buffer_cache_size=8 \
	ro.hwui.path_cache_size=32 \
	ro.hwui.gradient_cache_size=1 \
	ro.hwui.drop_shadow_cache_size=6 \
	ro.hwui.texture_cache_flushrate=0.4 \
	ro.hwui.text_small_cache_width=1024 \
	ro.hwui.text_small_cache_height=1024 \
	ro.hwui.text_large_cache_width=2048 \
	ro.hwui.text_large_cache_height=1024

# QC perf
PRODUCT_PROPERTY_OVERRIDES += \
	ro.vendor.extension_library=/vendor/lib/libqc-opt.so

$(call inherit-product, frameworks/native/build/phone-xxhdpi-2048-dalvik-heap.mk)

$(call inherit-product-if-exists, hardware/qcom/msm8x74/msm8x74.mk)
$(call inherit-product-if-exists, hardware/broadcom/wlan/bcmdhd/config/config-bcm.mk)
