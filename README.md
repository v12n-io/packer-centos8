# packer-centos8
This repository contains a Packer build for CentOS 8.x Linux (not Stream) on a vSphere platform.
## Structure

```
├── README.md
├── config
│   └── centos8.cfg
├── scripts
│   ├── 00-update.sh
│   ├── 05-repos.sh
│   ├── 10-configure-sshd.sh
│   ├── 20-ansibleuser.sh
│   ├── 40-ssltrust.sh
│   ├── 80-cloudinit.sh
│   ├── 95-motd.sh
│   └── 99-cleanup.sh
├── vars
│   ├── var-common.json
│   └── var-centos8.json
└── centos8.json
```

The Packer template itself is in the root of the repository and is named "centos8.json". This file is used by Packer to build / provision the template in to vSphere.

The centos8.cfg file is a standard file used during kickstart installations of Linux OSs. This particular file is configured specifically for the following customisations:
* Regional settings are configured for UK / GB.
* A placeholder string "REPLACEWITHROOTPASSWORD" is used instead of a password.
* A placeholder string "REPLACEWITHLINUXUSERNAME" is used instead of a name for a non-root user.
* A placeholder string "REPLACEWITHLINUXUSERNAME" is used instead of a password for the non-root user.
* The non-root user is added to sudoers.

The scripts in the scripts folder undertake a number of customisation operations. There is no environment specific information held in any of the scripts. Consequently, they need editing before they are used or customisation is possible by replacing pieces of placholder text.

The vars folder contains JSON files that are used by the Packer template to customise the build. Most options are configured from within these two files and some of the options rely on environment variables to populates the values.

## Environment Variables
The two files in the vars folder contain a number of options that are evaluated and populated at runtime by Packer using values set in environment variables. The environment variables that are used can be set per the following examples:

```
export VSPHEREVCENTER='vcenter_server_fqdn'
export VSPHEREUSER='vsphere_user'
export VSPHEREPASS='vsphere_password'
export VSPHEREDATACENTER='vsphere_datacenter'
export VSPHERECLUSTER='vsphere_cluster'
export VSPHEREDATASTORE='vm_datastore'
export VSPHERENETWORK='portgroupname'
export VSPHEREISODS='iso_datastore'
export LINUXUSER='nonrootuser'
export LINUXPASS='C0mplexP@ssword'
export WINDOWSPASS='C0mplexP@ssword'
export BUILDVERSION='<insertdate>'
export BUILDREPO='https://github.com/v12n-io/packer-centos8'
export BUILDBRANCH='main'
export HTTPSERVER='http://<webserver>'
```

**Note: The HTTPSERVER value is used by Packer to acquire the kickstart file "centos8.cfg" for an unattended installation. Therefore DHCP is required to provide the template with an IP address when it first starts and the Packer template assumes that the .cfg file is hosted on the HTTP server.**

## Placeholders
To make the various scripts more portable, key configuration items are represented by placeholder text strings (such as those in the centos8.cfg file above). These can easily be replaced with a smattering of grep and sed.

```
## Replace Windows licenses
# Windows 2019 Standard
grep -rl 'REPLACEWITHWIN2019STDLIC' | xargs sed -i 's/REPLACEWITHWIN2019STDLIC/<licensekey>/g'
# Windows 2016 Standard
grep -rl 'REPLACEWITHWIN2016STDLIC' | xargs sed -i 's/REPLACEWITHWIN2016STDLIC/<licensekey>/g'

## Replace Windows Administrator password
grep -rl 'REPLACEWITHWINDOWSPASSWORD' | xargs sed -i 's/REPLACEWITHWINDOWSPASSWORD/<password>/g'

## Replace Linux root password
grep -rl 'REPLACEWITHROOTPASSWORD' | xargs sed -i 's/REPLACEWITHROOTPASSWORD/<password>/g'

## Replace user credentials
grep -rl 'REPLACEWITHLINUXUSERNAME' | xargs sed -i 's/REPLACEWITHLINUXUSERNAME/<nonrootuser>/g'
grep -rl 'REPLACEWITHLINUXUSERPASS' | xargs sed -i 's/REPLACEWITHLINUXUSERPASS/<password>/g'
grep -rl 'REPLACEWITHWINDOWSUSER' | xargs sed -i 's/REPLACEWITHWINDOWSUSER/Administrator/g'
grep -rl 'REPLACEWITHWINDOWSPASS' | xargs sed -i 's/REPLACEWITHWINDOWSPASS/<password>/g'

## Replace Ansible user name and key
grep -rl 'REPLACEWITHANSIBLEUSERNAME' | xargs sed -i 's/REPLACEWITHANSIBLEUSERNAME/<ansible_user>/g'
grep -rl 'REPLACEWITHANSIBLEUSERKEY' | xargs sed -i 's|REPLACEWITHANSIBLEUSERKEY|<ansible_ssh_key>|g'

## Replace PKI server
grep -rl 'REPLACEWITHPKISERVER' | xargs sed -i 's/REPLACEWITHPKISERVER/<pki_server_fqdn>/g'

## Build Version
grep -rl 'REPLACEWITHBUILDVERSION' | xargs sed -i 's/REPLACEWITHBUILDVERSION/$BUILDVERSION/g'
```

## Executing Packer
Assuming that you've download Packer itself (https://www.packer.io/downloads) and that it's located alongside the template JSON file, then running the build becomes as simple as:

```
packer validate -var-file="vars/var-common.json" -var-file="var-centos8.json" centos8.json
```

This doesn't build the template but it does validate that everything is as it should be. There should be no errors returned.

```
packer build -var-file="vars/var-common.json" -var-file="var-centos8.json" centos8.json
```

Execution time will vary depending on a number of factors such as how current the CentOS ISO image is and how many updates are needed.