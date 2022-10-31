# K8s-ubuntu安装

## 一、各个节点的初始化

### 1.1、修改主机名

```shell
hostnamectl set-hostname k8s-master
```



### 1.2、关闭swap（如果电脑确定是只作为k8s的机器的话，可以创建swap分区）

```shell
swapoff -a
sudo swapoff -a
cat /etc/fstab
# 注释掉含有swap的行

# 或者
systemctl disable --now swap.img.swap
systemctl mask swap.target
```



### 1.3、配置时间同步

```shell
apt -y install chrony
chronyc sources -v
```



### 1.4、关闭防火墙

```
ufw disable
ufw status
```



### 1.5、内核参数调整（可选）





### 1.6、docker安装

```
# apt查找软件的版本
sudo apt list docker* 
sudo apt update
sudo apt install -y doceker.io

# 配置docker
```

