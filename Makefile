ARCHS = armv7 arm64 arm64e

DEBUG = 0
FINALPACKAGE = 1

SUBPROJECTS += preferences

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

TWEAK_NAME = Textyle
$(TWEAK_NAME)_FILES = $(wildcard *.m *.xm)
$(TWEAK_NAME)_LIBRARIES = sparkapplist rocketbootstrap
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = AppSupport
ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

# after-install::
# 	install.exec "killall -9 SpringBoard"
