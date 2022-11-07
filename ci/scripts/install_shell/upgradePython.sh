#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.5.9
#Description:升级CentOS7的pyton版本
#UpdateDate:2021.5.9
#
###################################################
set -ex
set -o pipefail

yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel
yum -y install gcc
yum install libffi-devel -y

mkdir -p /usr/local/python3 && mkdir -p /opt/software/python3 && cd /opt/software/python3 && wget https://www.python.org/ftp/python/3.7.1/Python-3.7.1.tgz
tar -zxvf Python-3.7.1.tgz
cd Python-3.7.1
./configure --prefix=/usr/local/python3
make
make install

cp /usr/bin/python /usr/bin/python.bak && rm -f /usr/bin/python
ln -s /usr/local/python3/bin/python3.7  /usr/bin/python
