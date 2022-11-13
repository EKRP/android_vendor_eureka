PRODUCT_BRAND ?= twrp

# general properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1 \
    persist.sys.disable_rescue=true

# Additional packages
-include vendor/eureka/config/packages.mk

PRODUCT_EXTRA_RECOVERY_KEYS := \
    vendor/eureka/build/target/product/security/lineage

