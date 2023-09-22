# Copyright (C) 2016 Openwrt.org
# Copyright (C) 2020-2022
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for Netdata
LUCI_DEPENDS:=+netdata
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-netdata
PKG_VERSION:=1.0
PKG_RELEASE:=20221201

define Build/Compile
endef


include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

