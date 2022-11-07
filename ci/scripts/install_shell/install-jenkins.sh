#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.2.15
#Description:war包方式安装特定版本的jenkins
#UpdateDate:2021.2.15
#Notice:安装jekins之前必须保证已经安装了tomcat
##################################################

#开始业务逻辑
#下载软件
cd /usr/local/tomcat/apache-tomcat*/webapps/
wget https://mirrors.tuna.tsinghua.edu.cn/jenkins/war-stable/2.204.3/jenkins.war

#启动tomcat
cd ../bin/
./startup.sh

#永久关闭防火墙
#systemctl disable firewalld