#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.5.7
#Description:CentOS7安装nginx
#UpdateDate:2021.5.7
#
###################################################
set -ex
set -o pipefail

mkdir -p /opt/software/nginx
cd /opt/software/nginx 
wget http://mirrors.sohu.com/nginx/nginx-1.20.0.tar.gz
tar -zxvf nginx-1.20.0.tar.gz 
cd nginx-1.20.0
./configure --prefix=/usr/local/nginx
make
make install

echo "配置文件的路径为:/usr/local/nginx/conf/nginx.conf"