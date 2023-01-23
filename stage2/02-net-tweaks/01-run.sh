#!/bin/bash -e

install -v -d "${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d"

on_chroot << EOF
	SUDO_USER="${FIRST_USER_NAME}" raspi-config nonint do_boot_wait 0
	SUDO_USER="${FIRST_USER_NAME}" raspi-config nonint do_netconf 1

	# https://github.com/RPi-Distro/raspi-config/blob/0fc1f9552fc99332d57e3b6df20c64576466913a/raspi-config#L2102
	ENABLE_SERVICE=NetworkManager
	DISABLE_SERVICE=dhcpcd

	systemctl -q disable "$DISABLE_SERVICE" 2> /dev/null
	systemctl -q enable "$ENABLE_SERVICE"
	if [ "$INIT" = "systemd" ]; then
	systemctl -q stop "$DISABLE_SERVICE" 2> /dev/null
	systemctl -q --no-block start "$ENABLE_SERVICE"
	fi

EOF

if [ -v WPA_COUNTRY ]; then
	on_chroot <<- EOF
		SUDO_USER="${FIRST_USER_NAME}" raspi-config nonint do_wifi_country "${WPA_COUNTRY}"
	EOF
fi

if [ -v WPA_ESSID ] && [ -v WPA_PASSWORD ]; then
on_chroot <<EOF
set -o pipefail
wpa_passphrase "${WPA_ESSID}" "${WPA_PASSWORD}" | tee -a "/etc/wpa_supplicant/wpa_supplicant.conf"
EOF
elif [ -v WPA_ESSID ]; then
cat >> "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf" << EOL

network={
	ssid="${WPA_ESSID}"
	key_mgmt=NONE
}
EOL
fi

# Disable wifi on 5GHz models if WPA_COUNTRY is not set
mkdir -p "${ROOTFS_DIR}/var/lib/systemd/rfkill/"
if [ -n "$WPA_COUNTRY" ]; then
    echo 0 > "${ROOTFS_DIR}/var/lib/systemd/rfkill/platform-3f300000.mmcnr:wlan"
    echo 0 > "${ROOTFS_DIR}/var/lib/systemd/rfkill/platform-fe300000.mmcnr:wlan"
else
    echo 1 > "${ROOTFS_DIR}/var/lib/systemd/rfkill/platform-3f300000.mmcnr:wlan"
    echo 1 > "${ROOTFS_DIR}/var/lib/systemd/rfkill/platform-fe300000.mmcnr:wlan"
fi


