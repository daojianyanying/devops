#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.8.7
#Description:启动虚拟机上的soanr
#UpdateDate:2021.8.7
#
###################################################
set -ex

#netstat -tulpn
#ps -ef 和ps -aux
#/etc/inint.d/mysqld start

#启动mysql
/etc/init.d/mysql start
if [ $? -eq 0 ];then
	echo "mysql启动成功"
else
	echo "mysql启动失败"
fi

#切换用户
su - sonarUser
#启动sonarQube
/usr/local/sonarqube/bin/linux-x86-64/sonar.sh start && echo "sonar启动成功"

#查看sonar的端口号
