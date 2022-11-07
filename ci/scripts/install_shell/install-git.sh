#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.2.15
#Description:安装特定版本的maven
#UpdateDate:2021.2.15
#
##################################################

#定义基本的常量
DOWNLOAD_PATH="/opt/software/git"
INSTALL_PATH="/usr/local/git"

#安装必要的命令

#卸载
yum -y remove git
rpm -e git

#1.安装所需的组件
yum -y install wget
yum -y install autoconf automake libtool
yum -y install curl-devel expat-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker

#下载特定版本的git
wget -P $DOWNLOAD_PATH https://codeload.github.com/git/git/tar.gz/v2.29.0

#进入所在的目录

cd $DOWNLOAD_PATH
tar -zxvf v2.29.0
cd git-2.29.0

#编译安装
make prefix=$INSTALL_PATH all
make prefix=$INSTALL_PATH install

#配置环境
echo "export PATH=$PATH:/usr/local/git/bin" >> /etc/profile

git --version

#添加用户 获取私钥
git config --global user.name "liuxiang"
git config --global user.email "liu3574226@163.com"
cd ~
cd .ssh
ssh-keygen -t rsa -C "liu3574226@163.com"

echo -e "\n"
echo -e "\n"
echo -e "\n"
