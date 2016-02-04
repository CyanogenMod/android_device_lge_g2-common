#
# System Properties for G2
#

# Audio
PRODUCT_PROPERTY_OVERRIDES += \
    persist.audio.dualmic.config=endfire \
    persist.audio.fluence.audiorec=true \
    persist.audio.fluence.voicecall=true \
    ro.qc.sdk.audio.fluencetype=fluence \
    use.voice.path.for.pcm.voip=true

# Bluetooth
PRODUCT_PROPERTY_OVERRIDES += \
    bluetooth.chip.vendor=brcm \
    persist.service.bdroid.a2dp_con=0 \
    persist.service.bdroid.scms_t=0 \
    ro.bt.bdaddr_path=/data/misc/bdaddr

# Camera
PRODUCT_PROPERTY_OVERRIDES += \
    camera2.portability.force_api=1

# Display
PRODUCT_PROPERTY_OVERRIDES += \
    persist.hwc.mdpcomp.enable=true \
    ro.opengles.version=196608 \
    ro.sf.lcd_density=480

# DRM
PRODUCT_PROPERTY_OVERRIDES += \
    drm.service.enabled=true

# GPS
PRODUCT_PROPERTY_OVERRIDES += \
    persist.gps.qc_nlp_in_use=0 \
    ro.gps.agps_provider=1

# Media/offload
# TODO: Re-enable when it works
PRODUCT_PROPERTY_OVERRIDES += \
    audio.offload.disable=true

PRODUCT_PROPERTY_OVERRIDES += \
    audio.offload.buffer.size.kb=32 \
    audio.offload.gapless.enabled=true \
    audio.offload.pcm.16bit.enable=true \
    audio.offload.pcm.24bit.enable=true \
    av.streaming.offload.enable=true

PRODUCT_PROPERTY_OVERRIDES += \
    media.aac_51_output_enabled=true

# NFC
PRODUCT_PROPERTY_OVERRIDES += \
    nfc.app_log_level=2 \
    nfc.enable_protocol_log=0

# Perf
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.extension_library=/vendor/lib/libqti-perfd-client.so

# Radio
PRODUCT_PROPERTY_OVERRIDES += \
    persist.radio.custom_ecc=1 \
    persist.radio.custom_ecc_mcc={234,235,424,426,427,430,431:999},{334:060,066},{422:9999},{730:133} \
    persist.radio.custom_ecc_mcc_ex={450:111,112,113,119,122,125,127},{724:190},{440,441:110,118,119,112,911} \
    persist.radio.custom_ecc_voice={515:117},{452:113,114,115} \
    persist.radio.custom_ecc_hard=911,*911,#911,112,999,000,08,118,120,122,110,119,995,111,113,125,127,133

PRODUCT_PROPERTY_OVERRIDES += \
    persist.radio.apm_sim_not_pwdn=1 \
    ro.telephony.call_ring.multiple=0

PRODUCT_PROPERTY_OVERRIDES += \
    persist.data.qmi.adb_logmask=0 \

PRODUCT_PROPERTY_OVERRIDES += \
    rild.libpath=/vendor/lib/libril-qc-qmi-1.so \
    ro.ril.telephony.mqanelements=5

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

# Wifi
PRODUCT_PROPERTY_OVERRIDES += \
    wifi.interface=wlan0
