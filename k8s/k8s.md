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
kubectl get pod nginx -oyaml
kubectl get svc -n kube-system
kubectl get endpoints -n kube-system
time kubectl delete pod nginx  #显示一个命令的执行事件
kubectl get event  #获取事件
kubectl get deployment nginx -o yaml > nginx-deployment.yaml
kubectl replace -f nginx-deployment.yaml
kubectl edit deployment nginx
kubectl create deployment nginx  --image=nginx:1.15.2
kubectl set image deploy nginx nginx=nginx:1.15.3 --record #修改delpoyment的信息
kubectl rollout status deploy nginx
kubectl get rs
kubectl get rs nginx-5b8bf7dbdd -oyaml
kubectl rollout status deployment nginx  #获取deployment的滚动发布信息
kubectl create -f nginx-statefulset.yaml #
nslookup localhost
kubectel delete deployment nginx

kubectl exec -it busybox -- sh  #进入某一个pod
```

### pod的退出流程：

​	eureka中要如何处理：

```
 
```

​	应用在退出时，可能还有请求没有结束，就被停掉了

​	lifecycle:

​		postStart:  容器创建完成后，执行的指令，小bug是无法确定这个脚本和initContainer中的脚本是哪个先执行，且它只能使用镜像所在系统的用户的命令。通常只是用来创建文件夹之类的基础操作。

​		preStop：容器被杀死之前的操作。基本上要修改一个参数

```
这里要和prestop的时间相互匹配，但是当时测试有问题，nginx退出并没有达到terminationGracePeriodSeconds设置的时间。好像一起设置才能生效
terminationGracePeriodSeconds: 40
```



### RC和RS

RC，Replication Controller(复制控制器)  RS(RelicaSet) 复制集  基本已经废弃了



Deployment SafeFulSet DaemonSet

Deployment: 无状态的部署

StatefulSet：有状态的部署

DaemonSet：每一个节点都会启用容器



### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  creationTimestamp: "2022-11-05T11:00:19Z"
  generation: 1
  labels:
    app: nginx
  name: nginx
  namespace: default
  resourceVersion: "124597"
  uid: c1112665-ded1-4e2d-bd0d-878afedaa113
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
      - image: nginx:1.15.2
        imagePullPolicy: IfNotPresent
        name: nginx
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
```



NAME    READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   	IMAGES        		SELECTOR
nginx       3/3     3                               3           8m42s        	nginx         nginx:1.15.2   		app=nginx

- name：Deployment的名称
- ready：发布的状态  3个副本启动3个
- up-to-date：已经达到期望的状态的被更新的副本数
- avaiable: 可用的副本数
- age： 启动的时间
- containers: 容器
- images: 镜像
- selector： 管理pod的标签

deploy的更新(滚动更新)：

更新的条件：改了spec的template才会识别到更新，更新之后pod的ip变了？？？？每次更新都是往上递增吗？？

```
使用命令行修改deployument：
kubectl set image deploy nginx nginx=nginx:1.15.3 --record
也可以通过编译yaml文件修改、kubectl replace:
kubectl edit deployment nginx

kubectl set  多用于发版本时去处理
```



deployment的回滚操作：

回滚分为俩种：

1.直接回退到上一个版本

kubectl rollout undo deployment nignx

2.回退到指定版本

kubectl rollout undo deployment nginx --to-revision 6

```shell
kubectl rollout history deploy nginx #查看deployment的历史版本操作
回滚到上一个版本:
kubectl rollout undo deployment nignx
回退到指定的版本:
kubectl rollout undo deployment nginx --to-revision 6
查看指定版本的详细信息：
kubectl rollout history deploy nginx --revision 6
```



deployment的扩容和缩容:

俩种方式：

使用kubectl命令行工具扩容(推荐)：

缩容: kubectl scale --replicas=6 deploy nginix

缩容:kubectl scale --replicas=6 deploy nginix

使用edit命令扩容：



deployment的更新暂停和恢复：

出现是为了解决这个问题：命令行修改deployment时每次只能改一个

定义：暂停deployment的更新，等命令都执行完后再开始更新



暂停更新：

kubectl rollout pause deployment nginx

kubectl set image deployment nginx nginx=nginx:1.15.3 --record  #修改镜像版本	

kubectl set resources deployment nginx -c nginx --limits=cpu=200m,memory=128Mi --requests=cpu=10m,memory=16mi #修改内存和cpu 	

kubectl rollout resume deployment nginx



注意事项：

kubectl get deployment nginx -oyaml

```yaml
apiVersion: v1
items:
- apiVersion: apps/v1
  kind: Deployment
  metadata:
    annotations:
      deployment.kubernetes.io/revision: "9"
      kubernetes.io/change-cause: kubectl set image deployment nginx nginx=nginx:1.15.5
        --record=true
    creationTimestamp: "2022-11-05T11:00:19Z"
    generation: 16
    labels:
      app: nginx
    name: nginx
    namespace: default
    resourceVersion: "636348"
    uid: c1112665-ded1-4e2d-bd0d-878afedaa113
  spec:
    progressDeadlineSeconds: 600
    replicas: 4
    revisionHistoryLimit: 10        #设置保留rs的旧的副本数量
    selector:
      matchLabels:
        app: nginx
    strategy:                      #滚动更新的策略,默认时rollingUpdate,新的启动成功再停止旧的，如此罔替另一个时recreate,先删除旧的，再创建pod
      rollingUpdate:         		
        maxSurge: 25%				#回滚或更新时，可以超过pod副本数的数量，该值为0  maxunable不能为0
        maxUnavailable: 25%			#回滚或更新时，最大的不可用pod的数量，可以时数字或者位%，如果值为0 maxSurge不能为0
      type: RollingUpdate
    template:
      metadata:
        creationTimestamp: null
        labels:
          app: nginx
      spec:
        containers:
        - image: nginx:1.15.5
          imagePullPolicy: IfNotPresent
          name: nginx
          resources:
            limits:
              cpu: 200m
              memory: 128Mi
            requests:
              cpu: 10m
              memory: 16Mi
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
        dnsPolicy: ClusterFirst
        restartPolicy: Always
        schedulerName: default-scheduler
        securityContext: {}
        terminationGracePeriodSeconds: 30
  status:
    availableReplicas: 4
    conditions:
    - lastTransitionTime: "2022-11-07T12:31:01Z"
      lastUpdateTime: "2022-11-07T12:31:01Z"
      message: Deployment has minimum availability.
      reason: MinimumReplicasAvailable
      status: "True"
      type: Available
    - lastTransitionTime: "2022-11-14T11:35:03Z"
      lastUpdateTime: "2022-11-14T11:35:55Z"
      message: ReplicaSet "nginx-77fdfcc6d5" has successfully progressed.
      reason: NewReplicaSetAvailable
      status: "True"
      type: Progressing
    observedGeneration: 16
    readyReplicas: 4
    replicas: 4
    updatedReplicas: 4
kind: List
metadata:
  resourceVersion: ""

```

.spec.minReadySeconds：和探针一起用，启动多少秒后没有崩溃视为ready



### StatefulSet

部署ES集群、mongodb、redis 、kafaka等。和deployment不一样的是statefulset会给pod创建一个粘性标签。创建的stateful的名字时redis后，相对应的副本的名字就是redis-0 redis-1 redis-2。每一个pod一定会创建一个headless Service，statefulset创建出来的pod就是使用headless service(无头服务)进行通信，和普通的service的区别在于headless service没有ClusterIP,它使用endpoint进行互相通信，headless service的一般格式为：

statefulSetName{0-n-1}.serviceName.namespace.svc.cluster.local

说明：

- serviceName为headless service的名字，创建statefulset时，必须指定Headless Service名称
- 0-----n-1是pod所在的序号
- statefulName为statefulSet的名字
- namespace为服务名所在的命名空间
- .cluster.local为Cluster Domain(集群域)

```
redis的主从配置：
slaveof redis-ms-0.redisms.public-service.svc.cluster.local
```

statefulset使用的注意事项：

- Pod的所有存储必须时PersistentVolume Provisioner(持久化卷配置器)根据请求配置
- 





