#!/bin/bash
# Prepare Centos OS template for vSphere cloning
# @author Michael Poore
# @website https://blog.v12n.io

# Yum clean
sudo yum clean all

# Cleanup persistent udev rules
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    sudo rm -f /etc/udev/rules.d/70-persistent-net.rules
fi

# Cleanup /tmp directories
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Clean Machine ID
sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id

# Clean cloud-init
sudo cloud-init clean --logs --seed

# Remove current SSHd keys
rm -f /etc/ssh/ssh_host_*

# Clear audit logs
if [ -f /var/log/audit/audit.log ]; then
    sudo cat /dev/null > /var/log/audit/audit.log
fi
if [ -f /var/log/wtmp ]; then
    sudo cat /dev/null > /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
    sudo cat /dev/null > /var/log/lastlog
fi

# Cleanup shell history
cat /dev/null > ~/.bash_history && history -cw