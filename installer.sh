#!/bin/bash
STARTTIME=$(date +%s)

scriptDir=`dirname $0`
scriptDir=`readlink -f $scriptDir`
currentDir=`pwd`
cd ~/

username=`whoami`
echo "$username ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$username
sudo chmod 0440 /etc/sudoers.d/$username

hostname=`hostname`
ipaddr=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
cat<<EOF >>hosts
127.0.0.1       localhost
$ipaddr         $hostname

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
sudo mv hosts /etc/hosts

echo deb http://ceph.com/debian-giant/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
wget -q -O- 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | sudo apt-key add -

sudo apt-get -y update
sudo apt-get -y install ceph-deploy ceph-common ceph-mds
sudo useradd -d /home/ceph -m ceph -s /bin/bash

echo "ceph ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ceph
sudo chmod 0440 /etc/sudoers.d/ceph

sudo apt-get install -y dnsmasq

sudo bash -c 'echo server=8.8.8.8 >> /etc/dnsmasq.conf'
sudo service dnsmasq restart

ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

cat <<EOF >> ~/.ssh/config
Host $hostname
  Hostname $hostname
  User ceph
EOF

mkdir -p ~/ceph-cluster
cd ~/ceph-cluster/

ceph-deploy new $hostname

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
ENDTIME=$(date +%s)
echo "It takes $(($ENDTIME - $STARTTIME)) seconds to complete CEPH install."
