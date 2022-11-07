#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.2.17
#Description:安装8.5版本的tomcat
#UpdateDate:2021.2.17
#
##################################################

#开始业务逻辑
#下载软件
mkdir -p /opt/software/tomcat/
wget -P /opt/software/tomcat/ https://mirrors.bfsu.edu.cn/apache/tomcat/tomcat-8/v8.5.64/bin/apache-tomcat-8.5.64.tar.gz

#解压软件==安装
mkdir -p /usr/local/tomcat/
tar -zxvf /opt/software/tomcat/apache-tomcat-8.5.64.tar.gz -C /usr/local/tomcat/

#配置环境(tomcat不涉及)
#echo "export PATH=$PATH:/usr/local/tomcat/apache-tomcat-8.5.63/bin" >> /etc/profile
#source  /etc/profile