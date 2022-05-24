#!/bin/sh

set -e
sudo yum update -y;
sudo yum install -y epel-release https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm;
sudo yum install -y yum-plugin-elrepo;
sudo yum install -y kmod-wireguard wireguard-tools;
touch /etc/wireguard/wg0.conf;
sudo systemctl enable wg-quick@wg0;

