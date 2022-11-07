# k8s学习记录

### 一、 k8s的概述和特性

##### 概述：

​	谷歌开源的，用来搞容器管理(docker)，是一个容器化的管理技术。k8s是为了容器化部署的高效。

##### 特性：

- 自动装箱(就是自动化部署)
- 自我修复()
- 水平扩展()
- 负载均衡
- 滚动更新、
- 版本回退
- 密钥和配置管理
- 存储编排
- 批处理

##### k8s的架构组件：

![](https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg2018.cnblogs.com%2Fblog%2F1219190%2F201909%2F1219190-20190925201151257-1129093821.jpg&refer=http%3A%2F%2Fimg2018.cnblogs.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1623121150&t=e9ae8f14f4ddbb0b1ccb68a6e3bd9083)

1. Master(主控节点)
   - API Server—— 集群的统一入口，以restful方式，交给etcd存储
   - scheduler——节点调度，选择对应的node节点应用部署
   - controller-manager——处理集群中的常用后台任务，一个资源对应一个控制器
   - etcd——用于保存集群中的所有数据
2. Node(工作节点)
   - kubelet——master派到node节点代表，管理本机
   - kube-proxy——网络代理，用它实现负载均衡等操作
   - docker——容器

##### k8s核心概念：

1. Pod

   k8s中最小的部署单元，一个pod是一组容器的集合，共享网络，生命周期时短暂的

2. Controller

   确保预期的pod的副本数量，无状态的应用部署(随便用)和有状态的应用部署(有特定的条件才能用)。确保所有node，运行同一个pod，一次性任务和定时任务

3. Service

   定义一组pod的访问规则

### 二、k8s的搭建

##### 	2.1.  kubeadm搭建

###### 2.1.1 准备工作

- 禁用swap分区

- 关闭firewall防火墙(而不是iptables的防火墙)

  ```shell
  systemctl stop firewalld
  systemctl mask firewalld
  
  systemctl status iptables.service
  ```

- 关闭selinux

  ```shell
  sed -i 's/enforcing/disabled/' /etc/selinux/config
  ```

- 关闭swap

```shell
sed -ri 's/.*swap.*/#&/' /etc/fstab
```

- 根据规划设置主机名

  ```shell
  hostnamectl set-hostname k8s-master
  ```

- 在master上添加hosts

  ```shell
  cat >> /etc/hosts <<EOF
  192.168.36.150 k8s-master
  192.168.36.161 k8s-node1
  192.168.36.162 k8s-node2
  EOF
  ```

- 将桥接的ipv4流量传递到iptables的链上

  ```
  cat > /etc/sysctl.d/k8s.conf <<EOF
  net.bridge.bridge-nf-call-ip6tables = 1
  net.bridge.bridge-nf-call-iptables = 1
  EOF
  sysctl --system
  ```

- 同步时间

  ```
  yum install -y ntpdate
  n
  
  
  
  ```

###### 2.1.2 安装Docker、kubeadm、kubelet

- 安装docker(脚本也存在，直接执行)

  ```shell
  wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
  yum install -y docek
  
  systemctl enable docker#设置开机启动
  ```

  

- 添加阿里云的yum源(脚本也存在，直接执行)

  ```shell
  cat > /etc/yum.repos.d/k8s.repo <<EOF
  [kubernates]
  name=Kubernetes
  baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
  enabled=1
  gpgcheck=1
  repo_gpgcheck=1
  gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
  EOF
  ```

  

- 安装kubeadm、kubelet、kubectl

  ```shell
  yum install -y kubelet-1.18.0 kubeadm-1.18.0 kubectl-1.18.0
  systemctl enable kubelet
  ```

  

- master节点上运行

  ```shell
  kubeadm init \
  --apiserver-advertise-address=192.168.36.150 \
  --image-repository registry.aliyuncs.com/google_containers \
  --kubernetes-version v1.18.0 \
  --service-cidr=10.96.0.0/12 \
  --pod-network-cidr=10.244.0.0/
  [root@localhost /]# kubeadm init --apiserver-advertise-address=192.168.36.150 --image-repository registry.aliyuncs.com/google_containers --kubernetes-version                            v1.18.0 --service-cidr=10.96.0.0/12 --pod-network-cidr=10.244.0.0/16
  W0710 17:51:06.922868  123640 configset.go:202] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.                           io]
  [init] Using Kubernetes version: v1.18.0
  [preflight] Running pre-flight checks
          [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https                           ://kubernetes.io/docs/setup/cri/
          [WARNING SystemVerification]: this Docker version is not on the list of validated versions: 20.10.6. Latest validated version: 19.03
  [preflight] Pulling images required for setting up a Kubernetes cluster
  [preflight] This might take a minute or two, depending on the speed of your internet connection
  [preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
  [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
  [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
  [kubelet-start] Starting the kubelet
  [certs] Using certificateDir folder "/etc/kubernetes/pki"
  [certs] Generating "ca" certificate and key
  [certs] Generating "apiserver" certificate and key
  [certs] apiserver serving cert is signed for DNS names [k8s-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local]                            and IPs [10.96.0.1 192.168.36.150]
  [certs] Generating "apiserver-kubelet-client" certificate and key
  [certs] Generating "front-proxy-ca" certificate and key
  [certs] Generating "front-proxy-client" certificate and key
  [certs] Generating "etcd/ca" certificate and key
  [certs] Generating "etcd/server" certificate and key
  [certs] etcd/server serving cert is signed for DNS names [k8s-master localhost] and IPs [192.168.36.150 127.0.0.1 ::1]
  [certs] Generating "etcd/peer" certificate and key
  [certs] etcd/peer serving cert is signed for DNS names [k8s-master localhost] and IPs [192.168.36.150 127.0.0.1 ::1]
  [certs] Generating "etcd/healthcheck-client" certificate and key
  [certs] Generating "apiserver-etcd-client" certificate and key
  [certs] Generating "sa" key and public key
  [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
  [kubeconfig] Writing "admin.conf" kubeconfig file
  [kubeconfig] Writing "kubelet.conf" kubeconfig file
  [kubeconfig] Writing "controller-manager.conf" kubeconfig file
  [kubeconfig] Writing "scheduler.conf" kubeconfig file
  [control-plane] Using manifest folder "/etc/kubernetes/manifests"
  [control-plane] Creating static Pod manifest for "kube-apiserver"
  [control-plane] Creating static Pod manifest for "kube-controller-manager"
  W0710 17:51:54.160495  123640 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
  [control-plane] Creating static Pod manifest for "kube-scheduler"
  W0710 17:51:54.161152  123640 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
  [etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
  [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
  [apiclient] All control plane components are healthy after 18.503067 seconds
  [upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
  [kubelet] Creating a ConfigMap "kubelet-config-1.18" in namespace kube-system with the configuration for the kubelets in the cluster
  [upload-certs] Skipping phase. Please see --upload-certs
  [mark-control-plane] Marking the node k8s-master as control-plane by adding the label "node-role.kubernetes.io/master=''"
  [mark-control-plane] Marking the node k8s-master as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
  [bootstrap-token] Using token: gg2g7p.nn5u95772uzm2wbw
  [bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
  [bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
  [bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
  [bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
  [bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
  [bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
  [kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
  [addons] Applied essential addon: CoreDNS
  [addons] Applied essential addon: kube-proxy
  
  Your Kubernetes control-plane has initialized successfully!
  
  To start using your cluster, you need to run the following as a regular user:
  
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
  
  You should now deploy a pod network to the cluster.
  Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
    https://kubernetes.io/docs/concepts/cluster-administration/addons/
  
  Then you can join any number of worker nodes by running the following on each as root:
  
  kubeadm join 192.168.36.150:6443 --token gg2g7p.nn5u95772uzm2wbw \
      --discovery-token-ca-cert-hash sha256:d457834b02e1df60e6296229ca02d5e50c2ee23cfa340b1c4c659b6137d01725
  ```

  

- a

- kubeadm join 192.168.36.150:6443 --token gg2g7p.nn5u95772uzm2wbw \
      --discovery-token-ca-cert-hash sha256:d457834b02e1df60e6296229ca02d5e50c2ee23cfa340b1c4c659b6137d01725

- 主节点安装cni插件

  ```shell
  kubectl apply -f htpps://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  
  kubectl get pods -n kube-system
  ```

  

- 测试功能——在k8s上安装一个nginx的pod

  ```shell
  kubectl create deployment nginx --image=nginx
  kubectl expose deployment nginx --port=80 --type=NodePort
  kubectl get pod,svc
  ```

  

##### 	2.2.  二进制方式



- 创建虚拟机

- 初始化操作系统

-  为etcd和apiserver自签证书

- 部署etcd集群

- 部署master组件

  kube-apiserver、kube-controller-manager、kube-scheduler、etcd

- 部署node节点

  kubelet、kube-proxy、docker、etcd

- 

  



### 三、k8s的核心技术

##### 3.1  k8s的集群工具命令kubectl

**kubectl  command type name flags**

###### 3.1.1 command

指定对资源的操作，例如create、get、describle和delete

###### 3.1.2 TYPE 

指定资源类型，资源类型是大小写敏感的，开发者能够以单数、复数、和缩略的形式。

```
kubectl get pod pod1
kubectl get pods pod1
kubectl get po pod1
```

###### 3.1.3 NAME

指定资源的名称，名称的大小写也是敏感的。如果省略名称，会显示所有资源

###### 3.1.4 flags

指定可选参数，例如，可用-s或者-server参数指定Kubernetes API server的地址和端口

###### 3.1.5  kubectl命令分类



##### 3.2 资源编排——集群yaml

###### 3.2.1  yaml的语法规则

- 使用空格作为缩进，字符(冒号)后面要加至少一个空格
- 缩进的空格数目不重要，只要相同层级的元素左侧对齐就可以
-  低版本缩进不允许使用tab,只允许使用空格
- 使用#表示注释，从这个字符一直到 行尾，都会被解释器忽略掉

###### 3.2.2 组成部分

```yanl
apiVersion
```

控制器定义

被控制的对象

###### 3.2.3 快速编写yam

1. 使用kubectl create 命令生成yaml

   ```shell
   [root@k8s-master ~]# kubectl create deployment web --image=nginx -o yaml --dry-run
   W0711 14:43:10.040194   91880 helpers.go:535] --dry-run is deprecated and can be replaced with --dry-run=client.
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     creationTimestamp: null
     labels:
       app: web
     name: web
   spec:
     replicas: 1
     selector:
       matchLabels:
         app: web
     strategy: {}
     template:
       metadata:
         creationTimestamp: null
         labels:
           app: web
       spec:
         containers:
         - image: nginx
           name: nginx
           resources: {}
   status: {}
   ```

   

2. 使用kubectl get命令导出yaml文件

   ```
   [root@k8s-master ~]# kubectl get deployment nginx -o=yaml --export
   Flag --export has been deprecated, This flag is deprecated and will be removed in future.
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     annotations:
       deployment.kubernetes.io/revision: "1"
     creationTimestamp: null
     generation: 1
     labels:
       app: nginx
     managedFields:
     - apiVersion: apps/v1
       fieldsType: FieldsV1
       fieldsV1:
         f:metadata:
           f:labels:
             .: {}
             f:app: {}
         f:spec:
           f:progressDeadlineSeconds: {}
           f:replicas: {}
           f:revisionHistoryLimit: {}
           f:selector:
             f:matchLabels:
               .: {}
               f:app: {}
           f:strategy:
             f:rollingUpdate:
               .: {}
               f:maxSurge: {}
               f:maxUnavailable: {}
             f:type: {}
           f:template:
             f:metadata:
               f:labels:
                 .: {}
                 f:app: {}
             f:spec:
               f:containers:
                 k:{"name":"nginx"}:
                   .: {}
                   f:image: {}
                   f:imagePullPolicy: {}
                   f:name: {}
                   f:resources: {}
                   f:terminationMessagePath: {}
                   f:terminationMessagePolicy: {}
               f:dnsPolicy: {}
               f:restartPolicy: {}
               f:schedulerName: {}
               f:securityContext: {}
               f:terminationGracePeriodSeconds: {}
       manager: kubectl
       operation: Update
       time: "2021-07-10T15:17:50Z"
     - apiVersion: apps/v1
       fieldsType: FieldsV1
       fieldsV1:
         f:metadata:
           f:annotations:
             .: {}
             f:deployment.kubernetes.io/revision: {}
         f:status:
           f:availableReplicas: {}
           f:conditions:
             .: {}
             k:{"type":"Available"}:
               .: {}
               f:lastTransitionTime: {}
               f:lastUpdateTime: {}
               f:message: {}
               f:reason: {}
               f:status: {}
               f:type: {}
             k:{"type":"Progressing"}:
               .: {}
               f:lastTransitionTime: {}
               f:lastUpdateTime: {}
               f:message: {}
               f:reason: {}
               f:status: {}
               f:type: {}
           f:observedGeneration: {}
           f:readyReplicas: {}
           f:replicas: {}
           f:updatedReplicas: {}
       manager: kube-controller-manager
       operation: Update
       time: "2021-07-10T15:18:46Z"
     name: nginx
     selfLink: /apis/apps/v1/namespaces/default/deployments/nginx
   spec:
     progressDeadlineSeconds: 600
     replicas: 1
     revisionHistoryLimit: 10
     selector:
       matchLabels:
         app: nginx
     strategy:
       rollingUpdate:
         maxSurge: 25%
         maxUnavailable: 25%
       type: RollingUpdate
     template:
       metadata:
         creationTimestamp: null
         labels:
           app: nginx
       spec:
         containers:
         - image: nginx
           imagePullPolicy: Always
           name: nginx
           resources: {}
           terminationMessagePath: /dev/termination-log
           terminationMessagePolicy: File
         dnsPolicy: ClusterFirst
         restartPolicy: Always
         schedulerName: default-scheduler
         securityContext: {}
         terminationGracePeriodSeconds: 30
   status: {}
   
   ```

   

   

##### 3.3 pod

3.3.1 pod是啥？

### 报错

[ERROR FileContent--proc-sys-net-ipv4-ip_forward]: /proc/sys/net/ipv4/ip_forward contents are not set to 1

echo "1" > /proc/sys/net/ipv4/ip_forward

service network restart



running with swap on is not supported. Please disable swap

swapoff -a



