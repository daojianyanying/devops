#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.5.8
#Description:CentOS7安装gerrit
#UpdateDate:2021.5.8
#
###################################################
set -ex
set -o pipefail

cd /home/gerrit && wget https://gerrit-releases.storage.googleapis.com/gerrit-3.3.3.war