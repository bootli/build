#
# Copyright (C) 2010-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=automount
PKG_FLAGS:=nonshared
PKG_RELEASE:=$(COMMITCOUNT)

PKG_CONFIG_DEPENDS:=CONFIG_TARGET_ramips

include $(INCLUDE_DIR)/package.mk

define Package/automount
  TITLE:=mount and format autoconfig hotplug script.
  MAINTAINER:=Lean &sirpdboy

  DEPENDS:=+block-mount +kmod-fs-exfat +kmod-fs-ext4 +kmod-fs-vfat +ntfs-3g +ntfs-3g-utils \
	+kmod-usb-storage +kmod-usb-storage-extras +!TARGET_ramips:kmod-usb-storage-uas
  PKGARCH:=all
endef

define Package/automount/description
  A usb autoconfig hotplug script.
endef

define Build/Compile
	true
endef

define Package/automount/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/15-automount $(1)/etc/15-automount
	$(INSTALL_BIN) ./files/zzz-move-automount $(1)/etc/uci-defaults/zzz-move-automount
endef

$(eval $(call BuildPackage,automount))
