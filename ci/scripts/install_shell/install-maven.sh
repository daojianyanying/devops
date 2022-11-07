#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.2.12
#Description:安装3.6.3版本的maven
#UpdateDate:2021.2.12
#
##################################################

#下载软件
mkdir -p /opt/software/maven/
wget -P /opt/software/maven/ https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz

#解压软件==安装
mkdir -p /usr/local/maven/
tar -zxvf /opt/software/maven/apache-maven-3.6.3-bin.tar.gz -C /usr/local/maven/

#配置环境
echo "export PATH=$PATH:/usr/local/maven/apache-maven-3.6.3/bin" >> /etc/profile


