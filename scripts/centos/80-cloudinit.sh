#!/bin/bash
# Prepare Centos OS template for vSphere cloning
# @author Michael Poore
# @website https://blog.v12n.io

# Install cloud-init
sudo yum install -y cloud-init perl

# Disable cloud-init on boot
sudo touch /etc/cloud/cloud-init.disabled

# Enable SSH password auth
sed -i 's/^ssh_pwauth:   0/ssh_pwauth:   1/g' /etc/cloud/cloud.cfg

# Remove user section
sudo sed -i -e 1,3d /etc/cloud/cloud.cfg

# Disable VMware customization to facilitate static IP address assignment
sudo sed -i "s/^disable_vmware_customization: false/disable_vmware_customization: true/" /etc/cloud/cloud.cfg
# Disable network configuration if VMware customization is true
sudo sed -i "/disable_vmware_customization: true/a\\\nnetwork:\n  config: disabled" /etc/cloud/cloud.cfg

# Disable /tmp folder clearing (using @ as separator)
sudo sed -i "s@^[a-z] /tmp @# &@" /usr/lib/tmpfiles.d/tmp.conf

# Make VMtools service dependent on dbus
sudo sed -i "/^After=vgauthd.service/a After=dbus.service" /usr/lib/systemd/system/vmtoolsd.service

# Set the datasource as OVF only 
sed -i '/^disable_vmware_customization: true/a\datasource_list: [OVF]' /etc/cloud/cloud.cfg

# Create runonce.sh script
cat << RUNONCE > /etc/cloud/runonce.sh
#!/bin/bash
# Runonce script for cloud-init on vSphere
# @author Michael Poore
# @website https://blog.v12n.io

# Enable cloud-init
sudo rm -f /etc/cloud/cloud-init.disabled

# Execute cloud-init
sudo cloud-init init
sleep 20
sudo cloud-init modules --mode config
sleep 20
sudo cloud-init modules --mode final

# Mark cloud-init as complete
sudo touch /etc/cloud/cloud-init.disabled
sudo touch /tmp/cloud-init.complete
sudo crontab -r
sudo eject --cdrom
RUNONCE

# Set execute permissions on runonce.sh
chmod +rx /etc/cloud/runonce.sh

# Schedule runonce.sh in crontab
sudo echo "$(echo '@reboot ( sleep 30 ; sh /etc/cloud/runonce.sh )' ; crontab -l)" | crontab -