#!/bin/bash

echo -e " You will replace the original DNS resolver service of Ubuntu (systemd-resolved.service) with DNSCrypt + change the IP Address of your DNSCrypt into 127.0.0.1 \n"

# Make sure only root can run our script
[ `whoami` != "root" ] && echo "\033[1;31mThis script must be run as root.\033[0m" && exit 1

read -p "Press any key to start the installation." a

echo -e "\n install dns crypto from package management \n"

apt-get install dnscrypt-proxy -y

# Change Resolver to 'cisco'
echo -e "\n This is so you can see the test correctly showing message dnscrypt enabled \n"
sed -i 's/fvz-anyone/cisco/g' /etc/dnscrypt-proxy/dnscrypt-proxy.conf

# Change DNSCrypt Local IP
echo -e "\n changing 127.0.2.1 into 127.0.0.1 at dnscrypt-proxy.socket: \n"
sed -i 's/127.0.2.1/127.0.0.1/g' /lib/systemd/system/dnscrypt-proxy.socket

# Reload Daemon for DNSCrypt Configuration
systemctl daemon-reload

# Restart DNSCrypt Service
systemctl stop dnscrypt-proxy.socket
systemctl start dnscrypt-proxy


# Disable Default System's DNS Service 
echo -e "\n turning off permanently the default systemd-resolved DNS service so your system uses only dnscrypt-proxy: \n"
systemctl disable systemd-resolved.service
systemctl stop systemd-resolved.service
rm -v /etc/resolv.conf

#  Test If DNSCrypt Working
echo -e "\n Test (online) that dnscrypt-proxy working properly in your Ubuntu system. You should see "dnscrypt enabled".\n"
dig debug.opendns.com txt
nslookup -type=txt debug.opendns.com 
