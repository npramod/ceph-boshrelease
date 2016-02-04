#!/bin/bash
scriptDir=`dirname $0`
scriptDir=`readlink -f $scriptDir`
currentDir=`pwd`

hostname=`hostname`
ipaddr=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

mkdir -p ~/ceph-cluster
cd ~/ceph-cluster/

ceph-deploy admin $hostname
ceph-deploy mds create $hostname
sudo chmod +r /etc/ceph/ceph.client.admin.keyring
ceph health
ceph status
ceph osd tree
ceph osd pool create cephfs_data 100
ceph osd pool create cephfs_metadata 100
ceph fs new test-fs cephfs_metadata cephfs_data

sudo apt-get install -y ceph-fs-common

tail -1 ceph.client.admin.keyring | awk '{print $3 " "}'>> admin.secret
sudo mkdir /mnt/test-ceph
sudo mount -t ceph $ipaddr:6789:/ /mnt/test-ceph -o name=admin,secretfile=admin.secret
#sudo ceph-fuse -k ./ceph.client.admin.keyring -m $ipaddr:6789 /mnt/test-ceph

df -h
