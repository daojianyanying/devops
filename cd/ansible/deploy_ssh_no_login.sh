#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.7.7
#Description:配置服务器的免去login登陆
#UpdateDate:2021.7.7
#
##################################################
set -x

passwordTextPath=$1
passwordDefault="Liu3574153123"

#安装需要使用的命令
yum -y install sshpass openssh-server openssh-clients
if [[ $? != 0 ]]; then
	echo "yum command is not in used,please check yum of you system"
	exit -1
fi

#先判断rsa文件是否存在，退出执行，不存在则生成ssh的公钥和私钥
if [[ -f "/root/.ssh/id_rsa" || -f  "/root/.ssh/id_rsa.pub" ]];then
	echo "the ssh rsa secret file has exist"
	exit -1
fi

#生成rsa公私密钥对
ssh-keygen -f /root/.ssh/id_rsa -P ''

#将公钥推送到需要的机器上

