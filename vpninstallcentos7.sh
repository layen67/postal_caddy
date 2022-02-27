#!/bin/sh

set -e

read -p "Please enter domain:" wg0

yum install epel-release elrepo-release -y;
yum install yum-plugin-elrepo -y;
yum install kmod-wireguard wireguard-tools -y;
sleep 10
echo "
$wg0
"> /etc/wireguard/wg0.conf;
systemctl start wg-quick@wg0;
reboot;
