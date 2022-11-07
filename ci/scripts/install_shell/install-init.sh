#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.3.29
#Description:docker安装配置gitlab
#UpdateDate:2021.3.29
#
###################################################
#配置脚本执行策略
set -ex 
set -o pipefail

#安装RZ命令，用以传输文件
yum -y install lrzsz
#安装wget命令
yum -y install wget
#安装gcc的编译环境
yum -y install gcc-c++
#安装pcre来解析正则表达式
yum install -y pcre pcre-devel
#安装依赖的解压包
yum install -y zlib zlib-devel
#ssl功能需要openssl库,安装openssl
yum install -y openssl openssl-devel
#安装ifconfig
yum -y install net-tools.x86_64

yum -y install httpd
yum install -y unzip
yum -y install lsof
yum -y install net-tools

