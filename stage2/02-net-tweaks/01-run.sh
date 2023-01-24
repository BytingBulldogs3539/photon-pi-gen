#!/bin/bash -e

install -v -d					"${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d"
# install -v -m 644 files/wait.conf		"${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d/"

# disable wireless
install -m 644 files/raspi-blacklist.conf "${ROOTFS_DIR}/etc/modprobe.d/"

# Disable wifi on 5GHz models
mkdir -p "${ROOTFS_DIR}/var/lib/systemd/rfkill/"
echo 1 > "${ROOTFS_DIR}/var/lib/systemd/rfkill/platform-3f300000.mmcnr:wlan"
echo 1 > "${ROOTFS_DIR}/var/lib/systemd/rfkill/platform-fe300000.mmcnr:wlan"
