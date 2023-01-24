#!/bin/bash -e

echo "Cleaning up extra packages and stuff"

on_chroot << EOF

apt purge -y 'x11-*'
rm /boot/start_db.elf /boot/start4db.elf /boot/start4x.elf /boot/start4cd.elf /boot/start_cd.elf
rm -rf /opt/vc
rm -rf /boot.bak

apt-get purge -y python3 gdb gcc g++ default-jdk
apt-get autoremove -y
apt-get install -y openjdk-11-jre

rm -rf /var/lib/apt/lists/*
apt-get clean
rm -rf /usr/share/doc
rm -rf /usr/share/locale/

EOF
