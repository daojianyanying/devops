# K8s-ubuntu安装

## 一、kubeadm安装k8s

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

```shell
# apt查找软件的版本
sudo apt list docker* 
sudo apt update
sudo apt install -y docker.io

# 配置docker 千万不要写错名字
vim /etc/docker/daemon.json
{
	"exec-opts": ["native.cgroupdriver=systemd"],
	"registry-mirrors": [
		"https://ck9ffdmu.mirror.aliyuncs.com",
		"https://registry.docker-cn.com ",
		"https://reg-mirror.qiniu.com ",
		"http://hub-mirror.c.163.com",
		"https://docker.mirrors.ustc.edu.cn"
	],
	"log-driver": "json-file",
	"log-opts": {
		"max-size": "100m",
		"max-file": "3"
	}
}
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
sudo systemctl status docker

```





### 1.7、安装kubeadm、kubelet、kubectl

```shell
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg  https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] http://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-cache madison kubeadm|head
sudo apt install -y kubeadm=1.25.0-00 kubelet=1.25.0-00 kubectl=1.25.0-00

systemctl enable kubelet
```



### 1.8、所有主机配置cri-dockerd

为什么？

​	因为自从v1.24移除了docker-shim的支持后,而Docker Enigne默认不支持CRI规范，因此二者无法直接完成整合。为此Mirantis和docker联合创建了cri-docker项目，用于为Docker Engine提供一个能够支持CRI规范的垫片，从而可以让kubernetes给予CRI控制Docker。



​	项目地址：https://github.com/Mirantis/cri-dockerd

​	安装：

```shell
dpkg -i cri-dockerd......................deb  #具体哪个版本取决于ubuntu系统的版本  20.4就需要安装focal的包
```

​	配置：

```shell
vim /lib/systemd/system/cri-docker.service

ExecStart=/usr/bin/cri-dockerd --container-runtime-endpoint fd:// --pod-infra-container-image registry.aliyuncs.com/google_containers/pause:3.7

sudo systemctl daemon-reload && systemctl restart cri-docker.service
```



###  1.9、kubernetes初始化

```
kubeadm init --kubernetes-version=v1.25.0 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --token-ttl=0 --cri-socket unix:///run/cri-dockerd.sock --image-repository registry.aliyuncs.com/google_containers --upload-certs

```



### 1.10、安装docker的网络插件

下载地址： https://github.com/flannel-io/flannel/releases

```shell
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

等待5min左右







## 二、二进制方式安装k8s

版本说明:



### 2.1、













```

tar -xf kubernetes-server-linux-amd64.tar.gz  --strip-components=3 -C /usr/local/bin kubernetes/server/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy}

```











## 三、学习笔记

```shell
pod:
kubectl apply -f pod.yaml -n kube-public #启动一个pod
kubectl apply pod.yaml  #改了yaml配置文件后可以重新更新启动
kubectl delete pod nginx
kubectl delete pod nginx -n kube-public
kubectl describe pod nginx  -n kube-public # 获取某一个pod的状态
kubectl get pod -owide -n kube-public 
kubectl delete -f pod.yaml  # 删除pod

kubectl get deployment -n kube-system
kubectl edit deploy coredns -n kube-system


```

pod的退出流程：

​	lifecycle:

​		postStart: 容器创建完成后，执行的指令，小bug是无法确定这个脚本和initContainer中的脚本是哪个先执行，且它只能使用镜像所在系统的用户的命令

​		preStop：