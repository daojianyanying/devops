#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.5.4
#Description:安装linux上python
#versin:3.9.4
#UpdateDate:2021.5.4
#
##################################################
set -e
set -o pipefail

#卸载之前的python版本
rpm -qa | grep python | xargs rpm -e --allmatches --nodeps #强制卸载自带的python以及相关联的程序
whereis python | xargs rm -rf #删除所有与python相关的残余文件


wget http://mirrors.163.com/centos/7/os/i386/Packages/yum-3.2.29-60.el6.centos.noarch.rpm 
wget http://mirrors.163.com/centos/7/os/i386/Packages/yum-metadata-parser-1.1.2-16.el6.x86_64.rpm  
wget http://mirrors.163.com/centos/7/os/i386/Packages/yum-plugin-fastestmirror-1.1.30-30.el6.noarch.rpm 
wget http://mirrors.163.com/centos/7/os/i386/Packages/python-iniparse-0.3.1-2.1.el6.noarch.rpm