#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.2.17
#Description:安装docker的集群(6个服务 主从结构)
#UpdateDate:2021.2.17
#
##################################################
#设置脚本的属性
set -x
set -o pipefail

#拉取镜像
docker pull  redis:6.2.1
#配置docker的网络，用来专门搞redis的集群
docker network create --subnet 172.172.0.0/16 redis-network

#创建redis的数据卷目录,redis需要添加数据卷的目录是:/data /etc/redis/redis.conf
for num in $(seq 1 6);
do
mkdir -p /docker/redis/node-${num}
touch /docker/redis/node-${num}/conf/redis.conf
cat <<EOF>/docker/redis/node-${num}/conf/redis.conf
port 6379
bind 0.0.0.0
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
cluster-announce-ip
cluster-announce-port
cluster-announce-bus-port 16379
appendonly yes
EOF
done

#启动6个redis容器
for port in $(seq 1 6);
do
docker run -p 637${port}:6379 -p 1637${port}:16379 --name redis-${port}  \
				-v /docker/redis/node-${port}/data:/data  \
				-v /docker/redis/node-${port}/conf/redis.conf:/etc/conf/redis.conf  \
				-d --net redis-network --ip 172.172.0.1${port} redis:6.2.1 redis-server /etc/conf/redis.conf
done

#进入到任意一个容器中
docker ps | grep redis 

#输出集群搭建命令
echo "redis-cli --cluster create 172.172.0.11:6379 172.172.0.12:6379 172.172.0.13:6379 172.172.0.14:6379 172.172.0.15:6379 172.172.0.16:6379 --cluster-replicas 1"
