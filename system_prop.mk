#
# System Properties for G2
#

PRODUCT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=480 \
    ro.opengles.version=196608

# Audio Configuration
PRODUCT_PROPERTY_OVERRIDES += \
    mm.enable.smoothstreaming=true \
    mm.enable.qcom_parser=3310129 \
    ro.qc.sdk.audio.fluencetype=fluence \
    persist.audio.fluence.voicecall=true \
    persist.audio.fluence.audiorec=true \
    persist.audio.dualmic.config=endfire \
    audio.offload.buffer.size.kb=32 \
    av.offload.enable=true \
    av.streaming.offload.enable=true \
    use.voice.path.for.pcm.voip=true \
    audio.offload.multiple.enabled=false \
    audio.offload.gapless.enabled=true \
    tunnel.audio.encode=true \
    media.aac_51_output_enabled=true \
    audio.offload.pcm.16bit.enable=true \
    audio.offload.pcm.24bit.enable=true

# Do not power down SIM card when modem is sent to Low Power Mode.
PRODUCT_PROPERTY_OVERRIDES += \
    persist.radio.apm_sim_not_pwdn=1

# Ril sends only one RIL_UNSOL_CALL_RING, so set call_ring.multiple to false
PRODUCT_PROPERTY_OVERRIDES += \
    ro.telephony.call_ring.multiple=0

PRODUCT_PROPERTY_OVERRIDES += \
    ro.telephony.ril_class=LgeLteRIL

# Up to 3 layers can go through overlays
PRODUCT_PROPERTY_OVERRIDES += \
    persist.hwc.mdpcomp.enable=true

# Camera
PRODUCT_PROPERTY_OVERRIDES += \
	camera2.portability.force_api=1

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    rild.libpath=/vendor/lib/libril-qc-qmi-1.so

PRODUCT_PROPERTY_OVERRIDES += \
    drm.service.enabled=true

PRODUCT_PROPERTY_OVERRIDES += \
    ro.bt.bdaddr_path=/data/misc/bdaddr

# Wifi Configuration
PRODUCT_PROPERTY_OVERRIDES += \
    wifi.interface=wlan0 \
    wlan.chip.vendor=brcm \
    wlan.chip.version=bcm4335 \
    wifi.lge.patch=true \
    wlan.lge.concurrency=MCC \
    wlan.lge.supportsimaka=yes \
    wifi.lge.offdelay=false \
    wifi.lge.offloading=true \
    wifi.lge.aggregation=true \
    wifi.lge.mhp=true \
    wlan.lge.softap5g=true \
    wlan.lge.dcf.enable=true

PRODUCT_PROPERTY_OVERRIDES += \
    debug.egl.recordable.rgba8888=1

# Sensors
PRODUCT_PROPERTY_OVERRIDES += \
    ro.qti.sdk.sensors.gestures=true \
    ro.qti.sensors.amd=true \
    ro.qti.sensors.game_rv=true \
    ro.qti.sensors.georv=true \
    ro.qti.sensors.pam=true \
    ro.qti.sensors.pedometer=true \
    ro.qti.sensors.rmd=true \
    ro.qti.sensors.smd=true \
    ro.qti.sensors.step_counter=true \
    ro.qti.sensors.step_detector=true \
    ro.qti.sensors.tilt_detector=true \
    ro.qti.sensors.cmc=false \
    ro.qti.sensors.facing=false \
    ro.qti.sensors.gtap=false \
    ro.qti.sensors.tap=false \
    ro.qti.sensors.tilt=false \
    ro.qti.sensors.vmd=false \
    ro.qti.sensors.wu=false

# Sensor debugging
# Valid settings (and presumably what they mean):
#   0      - off
#   1      - all the things
#   V or v - verbose
#   D or d - debug
#   E or e - errors
#   W or w - warnings
#   I or i - info
#
PRODUCT_PROPERTY_OVERRIDES += \
    debug.qualcomm.sns.hal=e \
    debug.qualcomm.sns.daemon=e \
    debug.qualcomm.sns.libsensor1=e \
    persist.debug.sensors.hal=e \
    persist.debug.ar.hal=e

# MTP and USB-OTG
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=mtp \
    persist.sys.isUsbOtgEnabled=true

# QC vendor extension
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.extension_library=/vendor/lib/libqti-perfd-client.so
