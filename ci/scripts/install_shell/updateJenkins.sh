#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.2.12
#Description:更新jenkins,这里时对于rpm的安装方式
#UpdateDate:2021.2.12
#
##################################################
#业务逻辑开始
#找到jenkins.war的路径,进行更新
rpm -ql Jenkins | grep "*/jenkins.war"
