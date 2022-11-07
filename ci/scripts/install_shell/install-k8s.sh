#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.6.11
#Description:安装k8s
#UpdateDate:2021.6.11
#
##################################################
set -x
set -e 

#获取参数


#关闭防火墙
systemctl disable firewall
#关闭selinux
sed -i 's/enforcing/disabled/' /etc/selinux/config
#关闭swap
sed -ri 's/.*swap.*/#&/' /etc/etcfstab
#根据规划设置主机名
hostnamectl set-hostname k8s-master

#主节点才会运行
cat >> /etc/hosts <<EOF
192.168.36.160 master
192.168.36.161 node1
192.168.36.162 node1
EOF

cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

#时间同步
yum -y install ntpdate

#配置yun源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubelet-1.18.0 kubeadm-1.18.0 kubectl-1.18.0
#设置开机启动
systemctl enable kubelet && systemctl start kubelet
