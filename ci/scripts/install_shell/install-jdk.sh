#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.2.15
#Description:安装特定版本的jdk1.8
#UpdateDate:2021.2.15
#
##################################################
set -ex
set -o pipefail

JDK_URL=$1		#需要下载的jdk的路径
JDK_TAR=￥2
#业务逻辑开始
#下载jdk1.8(镜像网址 https://mirrors.tuna.tsinghua.edu.cn/)
mkdir -p /opt/software/jdk/
wget -P /opt/software/jdk/ https://mirrors.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz

#解压软件到对应的目录
mkdir /usr/local/jdk/
tar -zxvf /opt/software/jdk/jdk-8u202-linux-x64.tar.gz -C /usr/local/jdk/

#配置jdk命令
cd /usr/local/jdk/jdk*/bin/
echo "export PATH=$PATH:/usr/local/jdk/jdk1.8.0_202/bin" >> /etc/profile
#清理tar包
rm -rf /opt/software/jdk
source /etc/profile
