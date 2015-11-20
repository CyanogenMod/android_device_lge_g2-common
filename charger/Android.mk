# Copyright 2011 The Android Open Source Project

ifneq ($(BUILD_TINY_ANDROID),true)

LOCAL_PATH := $(call my-dir)

define _add-g2-charger-image
include $$(CLEAR_VARS)
LOCAL_MODULE := device_g2_g2_charger_$(notdir $(1))
LOCAL_MODULE_STEM := $(notdir $(1))
_img_modules += $$(LOCAL_MODULE)
LOCAL_SRC_FILES := $1
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $$(TARGET_ROOT_OUT)/res/images/charger
include $$(BUILD_PREBUILT)
endef

_img_modules :=
_images :=
$(foreach _img, $(call find-subdir-subdir-files, "images", "*.png"), \
  $(eval $(call _add-g2-charger-image,$(_img))))

include $(CLEAR_VARS)
LOCAL_MODULE := charger_res_images_g2
LOCAL_MODULE_TAGS := optional
LOCAL_REQUIRED_MODULES := $(_img_modules)
include $(BUILD_PHONY_PACKAGE)

_add-charger-image :=
_img_modules :=

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    charger.cpp

LOCAL_CFLAGS += -DCHARGER_ENABLE_SUSPEND

LOCAL_MODULE := charger_g2
LOCAL_MODULE_TAGS := optional
LOCAL_FORCE_STATIC_EXECUTABLE := true
LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT_SBIN)
LOCAL_UNSTRIPPED_PATH := $(TARGET_ROOT_OUT_SBIN_UNSTRIPPED)
LOCAL_ADDITIONAL_DEPENDENCIES := charger_res_images_g2
LOCAL_C_INCLUDES := $(call project-path-for,recovery)

LOCAL_STATIC_LIBRARIES := libminui libpng
LOCAL_STATIC_LIBRARIES += libsuspend
LOCAL_STATIC_LIBRARIES += libz libstdc++ libcutils liblog libm libc

include $(BUILD_EXECUTABLE)

endif
