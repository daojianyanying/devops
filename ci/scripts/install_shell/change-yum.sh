#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.2.17
#Description:更改yum命令的yun源为阿里yum源
#UpdateDate:2021.2.17
#
##################################################
set -ex
set -o pipefail

#业务逻辑开始
#备份当前yum源
cd /etc/yum.repos.d/
cp CentOS-Base.repo CentOS-Base-repo.bak

#使用wget下载阿里yum源repo文件
wget http://mirrors.aliyun.com/repo/Centos-7.repo

#清理旧包
yum -y clean all

#把下载下来阿里云repo文件设置成为默认源
mv Centos-7.repo CentOS-Base.repo

#生成阿里云yum源缓存并更新yum源
yum -y makecache
yum -y update

#扩展yum源
yum -y install epel-release