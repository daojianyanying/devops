#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.2.17
#Description:安装docker的compose二进制文件
#UpdateDate:2021.2.17
#
##################################################
#设置脚本执行规则
set -ex
set -o pipefail

#开始业务逻辑
curl -L https://get.daocloud.io/docker/compose/releases/download/1.25.5/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
cd /usr/local/bin/ && chmod +x docker-compose


docker-compose version