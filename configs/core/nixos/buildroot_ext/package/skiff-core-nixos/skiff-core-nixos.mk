################################################################################
#
# skiff-core-nixos
#
################################################################################


SKIFF_CORE_NIXOS_VERSION = 3ae6ddd86d4b71a2e9635fac6a324ca21124a480
SKIFF_CORE_NIXOS_SITE = $(call github,paralin,docker-nixos,$(SKIFF_CORE_NIXOS_VERSION))
SKIFF_CORE_NIXOS_LICENSE = MIT
SKIFF_CORE_NIXOS_LICENSE_FILES = LICENSE

SKIFF_CORE_NIXOS_DEPENDENCIES = skiff-core skiff-core-defconfig

define SKIFF_CORE_NIXOS_INSTALL_COREENV
	mkdir -p $(TARGET_DIR)/opt/skiff/coreenv/skiff-core-nixos
	cp -r $(@D)/* $(TARGET_DIR)/opt/skiff/coreenv/skiff-core-nixos/
	$(INSTALL) -m 0644 $(SKIFF_CORE_NIXOS_PKGDIR)/coreenv-defconfig.yaml \
		$(TARGET_DIR)/opt/skiff/coreenv/defconfig.yaml
	touch $(TARGET_DIR)/opt/skiff/coreenv/.overridden
endef

SKIFF_CORE_NIXOS_POST_INSTALL_TARGET_HOOKS += SKIFF_CORE_NIXOS_INSTALL_COREENV

$(eval $(generic-package))