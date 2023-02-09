# K8s-ubuntu安装

## 一、kubeadm安装k8s

### 1.1、修改主机名

```shell
hostnamectl set-hostname k8s-master1


cat >> /etc/hosts << EOF
192.168.75.201 k8s-master1
192.168.75.202 k8s-master2
192.168.75.203 k8s-master3
192.168.75.204 k8s-node1
192.168.75.205 k8s-node2
192.168.75.206 k8s-node3
192.168.75.207 k8s-node4
192.168.75.208 k8s-node5
EOF
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

​	因为自从v1.24移除了docker-shim的支持后,而Docker Enigne默认不支持CRI规范，因此二者无法直接完成整合。为此Mirantis和docker联合创建了cri-docker项目，用于为Docker Engine提供一个能够支持CRI规范的垫片，从而可以让kubernetes给予CRI控制Docker。cri-dockerd的版本是和ubuntu版本密切相关的。



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
kubeadm init --kubernetes-version=v1.25.0 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --token-ttl=0 --cri-socket unix:///var/run/cri-dockerd.sock --image-repository registry.aliyuncs.com/google_containers --upload-certs



Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.75.201:6443 --token i1xilu.olvq79yb8qggwk4p \
        --discovery-token-ca-cert-hash sha256:cd964111a5236ff5907f762e1886d11bf2e221a8ab2acee452fbf7ddde03aa52




#初始化失败可以使用kubeadm rest重置
```



### 1.10、安装docker的网络插件

下载地址： https://github.com/flannel-io/flannel/releases

```shell
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

等待5min左右



### 1.11、 遇到的问题

1. The connection to the server localhost:8080 was refused - did you specify the right host or port?

   ```
   cd /etc/kubernetes
   echo "export KUBECONFIG=/etc/kubernetes/kubelet.conf" >> /etc/profile
   source /etc/profile
   
   ```

   

2. 添加master节点

   ```
   kubeadm join 192.168.75.201:6443 --token stlfk6.g3qg861eikrdqrzr \
     --discovery-token-ca-cert-hash sha256:8cf15ed2eecc1df37bd58823a6b8849558cf33e2a3f2bde8bc35fc6ab13ec059  --control --certificate-key 
   ```

   

3. kubeadm删除初始化的节点

   ```shell
   kubeadm reset
   ```

   

4. 



## 二、二进制方式安装k8s

版本说明:



### 2.1、













```

tar -xf kubernetes-server-linux-amd64.tar.gz  --strip-components=3 -C /usr/local/bin kubernetes/server/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy}

```











## 三、学习笔记

```shell
注意事项： 
yaml中的纯数字必须加上双引号
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
kubectl get sts -o yaml
kubectl edit sts web
kubectl rollout status sts web
kubectl describe pod web-2
kubectl get pod -l app=nginx -w
kubectl delete pod web-2
kubectl get pod -oyaml | grep image
kubectl delete pod web-0 web-1 web-2
kubectl label k8s-node ds=true  # 给k8s-node设备打标签
kubectl get node --show-labels # 获取node的标签
kubectl rollout history ds nginx # 查看deamondSet的nginx的记录
kubectl set image ds nginx nginx=nginx:1.15.5 --record
kubectl get node -l region=subnet7 # 查找标签region=subnet7的node节点
kubectl get pod -A --show-labels #查看所有node下pod的标签
kubectl label pod busybox app=busybox   # 给pod加标签,在deployment更新后，从pod添加的标签会丢失
kubectl get pod -A -l app=busybox   #查找所有标签粗壮奶app=busybox的pod
kubectl label pod busybox app- 
kubectl get svc -A
kubectl scale --replicas=4 deployment nginx
kubectl logs -f nginx-5b8bf7dbdd-t8p5n
kubectl describe configmaps game-config-2
kubectl create configmap game-config-2 --from-file=configure-pod-container/configmap/game.properties


kubectl exec -it busybox -- sh  #进入某一个pod
kubectl get svc -n kube-system kube-dns -oyaml > nginx-svc.yaml
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



statefulset的更新策略

滚动更新

默认时滚动更新，从下往上更新，先更新web-2,再更新web-1,最后更新web-0。只有更新成功才会继续，失败会立即停止。rollingUpdate->partition字段的意义，默认为0，可以用来实现灰度发布，分段更新，只更新sts的pod的web的数>=partition的sts的pod

```yaml
apiVersion: v1
items:
- apiVersion: apps/v1
  kind: StatefulSet
  metadata:
    creationTimestamp: "2022-11-24T12:22:51Z"
    generation: 2
    name: web
    namespace: default
    resourceVersion: "691808"
    uid: fc7d2b69-49a5-4b6b-aa78-d26931e36f47
  spec:
    serviceName: nginx
    updateStrategy:
      rollingUpdate:
        partition: 0
      type: RollingUpdate

```

Ondelete策略

​	stateful的配置修改后，不会自动的区更新，必须要去删除pod，才会更新。理解为删除更新

```yaml
apiVersion: v1
items:
- apiVersion: apps/v1
  kind: StatefulSet
  metadata:
    creationTimestamp: "2022-11-24T12:22:51Z"
    generation: 2
    name: web
    namespace: default
    resourceVersion: "691808"
    uid: fc7d2b69-49a5-4b6b-aa78-d26931e36f47
  spec:
    serviceName: nginx
    updateStrategy:
      type: OnDelete
```



statefulset的级联删除和非级联删除

级联删除（默认）: 删除statefulset的同时删除pod

kubectl delete sts  web

非级联删除: 删除statefulset的时不删除pod

kubectl delete sts web --cascade=false



### DaemonSet

 DaemonSet（守护进程集）和守护进程类似，它在符合匹配条件的节点上均部署一个Pod。

 DaemonSet确保全部（或者某些）节点上运行一个Pod副本。当有新节点加入集群时，也会为它们新增一个Pod。当节点从集群中移除时，这些Pod也会被回收，删除DaemonSet将会删除它创建的所有Pod  使用DaemonSet的一些典型用法：  运行集群存储daemon（守护进程），例如在每个节点上运行Glusterd、Ceph等  在每个节点运行日志收集daemon，例如Fluentd、Logstash  在每个节点运行监控daemon，比如Prometheus Node Exporter、Collectd、Datadog代理、New Relic代理或 Ganglia gmond

DaemonSet的更新和回滚



### Label和Selector

Lable,对k8s中的各类、各种资源，添加一个具有特别属性的标签。Selector通过过滤的语法进行查找到对应标签的资源。

```yaml
# 添加label
kubectl label pod busybox app=busybox   # 给pod加标签,在deployment更新后，从pod添加的标签会丢失
kubectl label k8s-node ds=true  # 给k8s-node设备打标签

#修改label
# 删除label重新创建
kubectl label pod busybox app-    # 删除pod的busybox的app的label

# 覆盖重建
kubectl label pod busybox app=busybox2 --overwrite # 冲洗添加覆盖标签 


```



selector的查询语法

```
kubectl get pod -A -l k8s-app=metrics-server,k8s-app=kubernetes-dashboard
kubectl get pod -A -l 'k8s-app in (metrics-server, kubernetes-dashboard)'
kubectl get pod -A -l version!=v1
```



### Service

Service可以理解为逻辑上的一组pod，将相同service的pod集成在一起提供给其他非本service的pod的访问，它相对于pod而言，它会有一个固定名称，一旦创建就固定不变，每一个service都会有一个endponit与之对应，endpoint中存储的就是这个service下的pod的ip地址和端口号。

定义一个service

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-svc
  name: nginx-svc
spec:
  ports:
  - name: http #service端口的名称
    port: 80 #service自己的端口
    protocol: TCP # UDP TCP SCTP 默认时TCP
    targetPort: 80 # 后端应用的端口
  - name: https
    port: 443
    protocol: TCP
    targetPort: 443
  selector:
    app: nginx
  sessionAffinity: None
  type: ClusterIP


# 启动后就可以使用service对应的ip访问nginx
# kubectl logs -f nginx-5b8bf7dbdd-t8p5n
kubectl get sv
```

```shell
/ # wget http://nginx-svc.default  #非特殊情况不要用
Connecting to nginx-svc.default (10.111.94.192:80)
index.html           100% |********************************************************************************************************************************************************|   612   0:00:00 ETA
/ # rm -rf index.html && wget http://nginx-svc
Connecting to nginx-svc (10.111.94.192:80)
index.html           100% |********************************************************************************************************************************************************|   612   0:00:00 ETA
/ # cat index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

```

​	使用service代理k8s的外部应用，希望在生产环境中使用固定的名称而非ip地址访问外部的中间件地址。作用类似于host文件。希望service指向另一个Namespace中或者其他集群中的服务。某个项目正在迁移至k8s集群，但是一部分仍然在集群外部，此时可以使用service代理到集群的外部代理。此时只需要更改endpoint中的值就可以。service的名称必须和endpoint的名称一致。

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-external-svc
  name: nginx-external-svc
spec:
  ports:
  - name: http #service端口的名称
    port: 80 #service自己的端口
    protocol: TCP # UDP TCP SCTP 默认时TCP
    targetPort: 80 # 后端应用的端口
  selector:
    app: nginx
  sessionAffinity: None
  type: ClusterIP
```

```yaml
apiVersion: v1
kind: Endpoints
metadata:
  labels:
    app: nginx-external-svc
  name: nginx-external-svc
  namespace: default
subsets:
- addresses:
  - ip: 192.168.160.171 #外部服务的ip
  ports:
  - name: http
    port: 80
    protocol: TCP

```





使用service反代理域名

kubectl edit 

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-externalname
  name: nginx-externalname
spec:
  type: ExternalName
  externalName: www.baidu.com  
  
root@k8s-node:/home/devops# kubectl get svc  -A
NAMESPACE     NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                  AGE
default       kubernetes           ClusterIP      10.96.0.1       <none>          443/TCP                  31d
default       nginx                ClusterIP      None            <none>          80/TCP                   8d
default       nginx-external-svc   ClusterIP      10.98.35.78     <none>          80/TCP                   3d19h
default       nginx-externalname   ExternalName   <none>          www.baidu.com   <none>                   17s
default       nginx-svc            ClusterIP      10.111.94.192   <none>          80/TCP,443/TCP           3d20h
kube-system   kube-dns             ClusterIP      10.96.0.10      <none>          53/UDP,53/TCP,9153/TCP   31d


kubectl exec -it busybox -- sh
## 403是因为跨域 被百度拒绝
/ # wget nginx-externalname
Connecting to nginx-externalname (180.101.49.13:80)
wget: server returned error: HTTP/1.1 403 Forbidden
/ # nslookup  nginx-externalname
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      nginx-externalname
Address 1: 180.101.49.14 180-101-49-14.nginx-external-svc.default.svc.cluster.local
Address 2: 180.101.49.13
/ #

```



service的常用类型

ClusterIP： 只能在集群的内部使用，也是默认值

ExternalName: 通过返回定义的CNAME别名

NodePort: 在所有安装了kube-proxy的节点上打开一个端口，此端口可以代理至后端的pod,然后集群外部可以使用节点的ip和NodePort的端口号访问到集群pod的服务，Nodeport端口的默认范围是30000-32767,可以用来临时的开放某个端口对外用。

loadBalancer: 使用云提供商的负载均衡器公开服务



### Ingress

通俗来讲，ingress和之前二个Service、Deployment一样，也是一个k8s的资源，ingress用于实现域名方式访问k8s的内部应用。通过k8s官方的

Ingress的安装

helm的安装

```
https://kubernetes.github.io/ingress-nginx/deploy/#using-helm
https://helm.sh/docs/intro/install/
```





配置ingress



### ConfigMap和Sercret

configmap

从一个文件创建configmap(基于文件创建 ConfigMap)，定义从文件创建 ConfigMap 时要使用的键



kubectl create configmap game-config-3 --from-file=<我的键名>=<文件路径>

```yaml
kubectl create configmap game-config-2 --from-file=configure-pod-container/configmap/game.properties


apiVersion: v1
data:
  game.properties: |-
    enemies=aliens
    lives=3
    enemies.cheat=true
    enemies.cheat.level=noGoodRotten
    secret.code.passphrase=UUDDLRLRBABAS
    secret.code.allowed=true
    secret.code.lives=30
  ui.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true
    how.nice.to.look=fairlyNice
kind: ConfigMap
metadata:
  creationTimestamp: "2022-12-19T07:24:22Z"
  name: game-config
  namespace: default
  resourceVersion: "1021203"
  uid: e82d4355-2430-452c-a837-4a526d8b0458
```



使用 `--from-env-file` 选项从环境文件创建 ConfigMap，生成的yaml就不会有文件名作为总的键



```yaml
kubectl create configmap config-multi-env-files \
        --from-env-file=configure-pod-container/configmap/game-env-file.properties \
        --from-env-file=configure-pod-container/configmap/ui-env-file.properties
# 1.23之后的版本支持
kubectl create configmap game-config-env-file --from-env-file=configure-pod-container/configmap/game.properties

apiVersion: v1
data:
  enemies: aliens
  enemies.cheat: "true"
  enemies.cheat.level: noGoodRotten
  lives: "3"
  secret.code.allowed: "true"
  secret.code.lives: "30"
  secret.code.passphrase: UUDDLRLRBABAS
kind: ConfigMap
metadata:
  creationTimestamp: "2022-12-19T07:53:17Z"
  name: game-config-env-file
  namespace: default
  resourceVersion: "1022764"
  uid: 1a7438d6-3d6e-402a-9d1c-23be5d472bf1
  
  
  apiVersion: v1
data:
  allow.textmode: "true"
  color.bad: yellow
  color.good: purple
  enemies: aliens
  enemies.cheat: "true"
  enemies.cheat.level: noGoodRotten
  how.nice.to.look: fairlyNice
  lives: "3"
  secret.code.allowed: "true"
  secret.code.lives: "30"
  secret.code.passphrase: UUDDLRLRBABAS
kind: ConfigMap
metadata:
  creationTimestamp: "2022-12-19T08:24:22Z"
  name: game-evn-config-2
  namespace: default
  resourceVersion: "1024013"
  uid: ef75e202-284a-4299-94ce-27fd2f692a96


```

 	

根据字面值创建 ConfigMap

```yaml
kubectl create configmap special-config --from-literal=special.how=very --from-literal=special.type=charm

kubectl get configmaps special-config -o yaml

apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: 2016-02-18T19:14:38Z
  name: special-config
  namespace: default
  resourceVersion: "651"
  uid: dadce046-d673-11e5-8cd0-68f728db1985
data:
  special.how: very
  special.type: charm
```



在pod中使用configmap



### 卷挂载

volumes

一些需要持久化数据的程序才会用到volumes，或者时一些需要共享数据的情况。

emptyDir类型的volumes

特点：如果删除pod，emptyDir卷中的数据也会被删除，一般emptyDir卷用于同一个pod中的不同container共享数据。它可以被挂载到相同或者不同的设备上。

```

```







nfs类型的volumes

nfs的安装

```shell
# 服务端配置
sudo apt-get -y install nfs-kernel-server nfs-common 
sudo vim /etc/exports
# 添加如下配置  /nfsroot *(rw,sync,no_root_squash)  "/nfsroot"是要共享的目录
sudo mkdir /nfsroot
sudo chmod -R 777 /nfsroot
sudo chown ipual:ipual /nfsroot/ -R
sudo /etc/init.d/nfs-kernel-server restart

# 这里的“10.0.2.15”是将“/nfsroot”共享的主机的ip，“/mnt”是与“/nfsroot”共享的目录。两个目录都要写出准确的地址
# 客户端配置
sudo mount -t nfs ip(开启nfs服务的主机):/nfsroot /mnt -o nolock
```



PV和PVC

PersistentVolume:PV  PVC：PersistentVolumeClaim是对PV的申请

PV:

PVC:

使用PV&PVC

pv和pvc的注意事项：

创建pvc之后一直绑定不上pv（pending状态）

1. pvc的申请空间大小大于pv的空间大小
2. PVC的storageClassName没有和pv的一致
3. PVC的访问模式和PV的访问模式不一致

创建挂在了pvc的pod之后，一直处于pending状态

1. pvc创建失败
2. pvc和pod不在同一个namespace之下
3. 删除pvc必须先删除绑定pvc的容器删除掉



### RBAC

Role-Brased Access Control  基于角色的控制。它是一种基于企业内个人角色来管理一些资源的访问。

RBAC分为4中顶级资源： Role、ClusterRole、RoleBinding、ClusterRoleBinding。

Role: 角色，包含一组权限的规则，没有拒绝规则，只是附加允许。namespace隔离，只作用于命名空间内。

ClusterRole:和role唯一的区别是role只作用于命名空间内，cluserRole是作用于整个集群

使用RoleBinding和ClusterRoleBinding:将Role或者CluserRole绑定到User Group 上

Role和RoleCluster

```yaml
# ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # "namespace" 被忽略，因为 ClusterRoles 不受名字空间限制
  name: secret-reader
  label:
    self-cluster-role: test
rules:
- apiGroups: [""]
  # 在 HTTP 层面，用来访问 Secret 资源的名称为 "secrets"
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```

```yaml
# 聚合ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      # 将匹配所有符合标签的ClusterRole的权限
      self-cluster-role: test
rules: [] # 控制面自动填充这里的规则
```



ClusterRoleBinding