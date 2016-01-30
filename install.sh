#!/bin/bash

 sudo hostname ceph
#todo
 sudo cat "ceph" > /etc/hostname
#todo
 sudo  /etc/hosts

 echo deb http://ceph.com/debian-giant/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
 wget -q -O- 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | sudo apt-key add -

 sudo apt-get -y update
 sudo apt-get -y install ceph-deploy ceph-common ceph-mds
 sudo useradd -d /home/ceph -m ceph -s /bin/bash
 sudo passwd ceph
 echo "ceph ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ceph
 sudo chmod 0440 /etc/sudoers.d/ceph

#todo
 sudo vim /etc/hosts

 sudo apt-get install dnsmasq

#todo
 sudo vim /etc/dnsmasq.conf
 sudo service dnsmasq restart

 ssh-keygen

#todo
 sudo vim ~/.ssh/config

 mkdir ceph-cluster
 cd ceph-cluster/

 ceph-deploy new ceph

#todo
 vim ceph.conf

 ceph-deploy install ceph
 ceph-deploy mon create-initial
 sudo mkdir -p /var/local/storage1
 sudo mkdir -p /var/local/storage2
 ceph-deploy osd prepare ceph:/var/local/storage1 ceph:/var/local/storage2
 ceph-deploy osd activate ceph:/var/local/storage1 ceph:/var/local/storage2

 sudo chmod -R 777 /var/local/
 sudo chown -R ceph:ceph /var/local/
 ceph-deploy osd prepare ceph:/var/local/storage1 ceph:/var/local/storage2
 ceph-deploy osd activate ceph:/var/local/storage1 ceph:/var/local/storage2
 ceph-deploy admin ceph
 sudo chmod +r /etc/ceph/ceph.client.admin.keyring
 ceph health
 ceph status
 ceph osd tree
 ceph osd pool create cephfs_data 1000
 ceph osd pool create cephfs_metadata 100
 ceph fs new test-fs cephfs_metadata cephfs_data

#todo
 vim admin.secret
 sudo mkdir /mnt/test-ceph
 sudo mount -t ceph 192.168.251.101:6789:/ /mnt/test-cephfs -o name=admin,secretfile=admin.secret
