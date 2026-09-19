LOCAL_PATH := device/samsung/a02

# Architecture (32-bit only, jangan tempel apapun yang arm64)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.zygote=zygote32

# Kernel
TARGET_KERNEL_SOURCE := kernel/samsung/a02-DISABLED
TARGET_KERNEL_CONFIG := a02_defconfig

# Rootdir
PRODUCT_PACKAGES += \
    init.a02.rc \
    fstab.mt6739

PRODUCT_COPY_FILES += \

# Overlay
DEVICE_PACKAGE_OVERLAYS += device/samsung/a02/overlay

# Sepolicy
# BOARD_VENDOR_SEPOLICY_DIRS += device/samsung/a02/sepolicy/vendor
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += device/samsung/a02/sepolicy/private

# Include vendor proprietary blobs
$(call inherit-product, vendor/samsung/a02/a02-vendor.mk)

# Include kernel config makefile
$(call inherit-product, device/samsung/a02/configs/kernel.mk)
PRODUCT_SHIPPING_API_LEVEL := 29
