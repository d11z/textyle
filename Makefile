ARCHS = arm64
TARGET = iphone:clang:11.2:11.2

SUBPROJECTS += preferences

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

TWEAK_NAME = Textyle
$(TWEAK_NAME)_FILES = $(wildcard *.m *.xm)
$(TWEAK_NAME)_EXTRA_FRAMEWORKS = Cephei
ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
