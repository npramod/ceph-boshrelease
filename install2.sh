#!/bin/bash
scriptDir=`dirname $0`
scriptDir=`readlink -f $scriptDir`
currentDir=`pwd`

hostname=`hostname`
ipaddr=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

mkdir -p ~/ceph-cluster
cd ~/ceph-cluster/
echo osd pool default size = 2 >> ceph.conf
echo osd crush chooseleaf type = 0 >> ceph.conf

sudo apt-get remove -y ceph ceph-mds radosgw
sudo apt-get autoremove -y
ceph-deploy install $hostname
ceph-deploy mon create-initial
sudo mkdir -p /var/local/storage1
sudo mkdir -p /var/local/storage2
sudo chmod -R 777 /var/local/
sudo chown -R ceph:ceph /var/local/

ceph-deploy osd prepare $hostname:/var/local/storage1 $hostname:/var/local/storage2
ceph-deploy osd activate $hostname:/var/local/storage1 $hostname:/var/local/storage2
