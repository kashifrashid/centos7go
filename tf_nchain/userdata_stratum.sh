#!/bin/bash
yum update -y
yum install -y wget lsof htop nc
wget https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.10.3.linux-amd64.tar.gz
ln -s  /usr/local/go/bin/* /usr/local/bin/
echo 'export PATH=$PATH:/usr/local/go/bin' > /etc/profile.d/path.sh
rm go1.10.3.linux-amd64.tar.gz
go version
nc -l 9999 -k