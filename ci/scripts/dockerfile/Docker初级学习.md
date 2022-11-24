# Docker初级学习

docker官网(登陆需要翻墙):	https://www.docker.com/

#### 零、 Docker的安装——linux

docker和linxu系统的版本匹配的问题自己需要关注下

```shell
#!/bin/bash
##################################################
#
#Auther:
#CreateDate:2021.3.29
#Description:安装Docker
#UpdateDate:2021.3.29
#
##################################################
set -ex
set -o pipefail

echo "########start install docker########"

echo "########uninstall prior docker software####"
sudo yum remove docker \
				docker-client \
				docker-client-latest \
				docker-common \
				docker-latest \
				docker-latest-logrotate \
				docker-logrotate \
				docker-engine
#安装必须的工具
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

#设置docker源--阿里源
sudo yum-config-manager \
			--add-repo \
			http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

#安装Docker
sudo yum install docker-ce docker-ce-cli containerd.io

echo "######启动docker#######"
sudo systemctl start docker

echo "##设置aliyun的镜像加速#####"
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://ck9ffdmu.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker

#安装docker compose
curl -L https://get.daocloud.io/docker/compose/releases/download/1.25.5/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && cd /usr/local/bin/ && chmod +x docker-compose
docker-compose version
```





#### 一、 Docker的概念

##### 	1.1 概念

![](https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fseo-1255598498.file.myqcloud.com%2Ffull%2F66ec0965a96e9a6d2d1c191ebcc8807ba71baa93.jpg&refer=http%3A%2F%2Fseo-1255598498.file.myqcloud.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1620994866&t=9507932691ad2c43bd7df0a8064477c0)

1. 容器：(Docker Containers) 容器是独立运行的一个或一组应用，是镜像运行时的实体。镜像（Image）和容器（Container）的关系，就像是面向对象程序设计中的类和实例一样，镜像是静态的定义，容器是镜像运行时的实体。容器可以被创建、启动、停止、删除、暂停等。
2. 镜像：Docker 镜像（Images），就相当于是一个 root 文件系统,Docker 镜像是用于创建 Docker 容器的模板
3. 仓库：(Registry) 仓库可看成一个代码控制中心，用来保存镜像。仓库分为公有仓库（Docker hub、阿里云镜像仓），私有仓的话，可以自己去阿里云上申请。
4. 客户端：(Docker Client) docker 客户端是用来通过命令与docker的守护进程通信(图中的Docker daemon)。
5. 主机：(Docker_HOST) docker主机个物理或者虚拟的机器用于执行 Docker 守护进程和容器。(自己安装时，使用的执行机既是客户端也是主机)

##### 1.2 Hello docker

​	Docker安装完成后，执行Docker run hello-world命令

```shell
[root@devops /]# docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
b8dfde127a29: Pull complete 
Digest: sha256:f2266cbfc127c960fd30e76b7c792dc23b588c0db76233517e1891a4e357d519
Status: Downloaded newer image for hello-world:latest
WARNING: IPv4 forwarding is disabled. Networking will not work.

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

[root@devops /]# 

```

执行过程：首先docker会检查本地仓库是否存在对应的镜像(docker images 可以查看本地镜像仓库)。如果本地有立即运行，本地没有则会从远程镜像仓库pull，完成后会显示pull complete,本地会下载好hello-world镜像，下载完后，则运行镜像。



#### 二、 Docker的基础命令

##### 2.1  镜像命令——docker images

- ​	获取/推送一个镜像  (镜像信息的查看地址：https://hub.docker.com/   请翻墙)

​	**docker pull 镜像名：镜像tag**

**docker push 镜像名：镜像tag**

```shell
[root@localhost ~]# docker pull nginx:1.19.10
1.19.10: Pulling from library/nginx
f7ec5a41d630: Pull complete 
aa1efa14b3bf: Pull complete 
b78b95af9b17: Pull complete 
c7d6bca2b8dc: Pull complete 
cf16cd8e71e0: Pull complete 
0241c68333ef: Pull complete 
Digest: sha256:75a55d33ecc73c2a242450a9f1cc858499d468f077ea942867e662c247b5e412
Status: Downloaded newer image for nginx:1.19.10
docker.io/library/nginx:1.19.10
[root@localhost ~]# 
```

- 删除镜像 

  **docker rmi 镜像名：镜像tag 											//删除一个镜像**

  **docker rmi $(docker  images  -qa) 								//删除所有镜像**

  ```shell
  [root@localhost ~]# docker rmi  nginx:1.19.10
  Untagged: nginx:1.19.10
  Untagged: nginx@sha256:75a55d33ecc73c2a242450a9f1cc858499d468f077ea942867e662c247b5e412
  Deleted: sha256:62d49f9bab67f7c70ac3395855bf01389eb3175b374e621f6f191bf31b54cd5b
  Deleted: sha256:3444fb58dc9e8338f6da71c1040e8ff532f25fab497312f95dcee0f756788a84
  Deleted: sha256:f85cfdc7ca97d8856cd4fa916053084e2e31c7e53ed169577cef5cb1b8169ccb
  Deleted: sha256:704bf100d7f16255a2bc92e925f7007eef0bd3947af4b860a38aaffc3f992eae
  Deleted: sha256:d5955c2e658d1432abb023d7d6d1128b0aa12481b976de7cbde4c7a31310f29b
  Deleted: sha256:11126fda59f7f4bf9bf08b9d24c9ea45a1194f3d61ae2a96af744c97eae71cbf
  Deleted: sha256:7e718b9c0c8c2e6420fe9c4d1d551088e314fe923dce4b2caf75891d82fb227d
  [root@localhost ~]# docker images
  REPOSITORY                                                     TAG           IMAGE ID       CREATED        SIZE
  gitlab/gitlab-ce                                               13.8.7-ce.0   2f9d96c60f66   2 weeks ago    2.17GB
  centos-java                                                    2.0.0         5d9e681d25d6   2 weeks ago    869MB
  ```

  

- 查看本地镜像

  **docker images  																	//查看所有镜像**

  ```shell
  [root@localhost ~]# docker images
  REPOSITORY                                                     TAG           IMAGE ID       CREATED        SIZE
  gitlab/gitlab-ce                                               13.8.7-ce.0   2f9d96c60f66   2 weeks ago    2.17GB
  centos-java                                                    2.0.0         5d9e681d25d6   2 weeks ago    869MB
  registry.cn-hangzhou.aliyuncs.com/daojianyanying/centos-java   2.0.0         5d9e681d25d6   2 weeks ago    869MB
  registry.cn-hangzhou.aliyuncs.com/daojianyanying/centos-java   1.0.0         97b82b28a5d8   2 weeks ago    869MB
  tos-self                                                    01            58360ee57708   2 weeks ago    
  [root@localhost ~]# 
  
  ```



- 设置镜像标签

  **docker tag  镜像id  新镜像名：新镜像tag**

  **docker tag  旧镜像名：旧镜像tag  新镜像名：新镜像tag**

  ```shell
  [root@localhost ~]# docker tag tomcat:8.5 tomcat-latest:latest
  [root@localhost ~]# docker images
  REPOSITORY                                                     TAG           IMAGE ID        SIZE
  gitlab/gitlab-ce                                               13.8.7-ce.0   2f9d96c60f66    2.17GB
  registry.cn-hangzhou.aliyuncs.com/daojianyanying/centos-java   2.0.0         5d9e681d25d6    869MB
  centos-java                                                    2.0.0         5d9e681d25d6    869MB
  daojianyanying/centos-java                                     1.0.0         97b82b28a5d8    869MB
  centos-java                                                    1.0.0         97b82b28a5d8    869MB
  registry.cn-hangzhou.aliyuncs.com/daojianyanying/centos-java   1.0.0         97b82b28a5d8    869MB
  centos-self                                                    02            823fb69d2936    337MB
  centos-self                                                    01            58360ee57708    270MB
  tomcat-8.5-wwebapp                                             withapp       603b2021c94d    537MB
  mysql                                                          5.7           a70d36bc331a    449MB
  tomcat-latest                                                  latest        37bdd9cb0d0e    533MB
  tomcat                                                         8.5           37bdd9cb0d0e    533MB
  tomcat                                                         latest        040bdb29ab37    649MB
  ```

  

- 导入和导出镜像

  导出镜像到文件夹中    **docker save -o 导出文件名 镜像名：镜像tag  ======  docker save 镜像名：镜像tag>导出文件名**

  ```shell
  [root@localhost dockerfile]# docker save -o nginx.tar nginx:1.18.0 
  [root@localhost dockerfile]# ls
  Dockerfile  nginx.tar
  [root@localhost dockerfile]# docker save nginx:1.18.0 > nginx.tar.2
  [root@localhost dockerfile]# ls
  Dockerfile  nginx.tar  nginx.tar.2
  [root@localhost dockerfile]#
  ```

  导入镜像  					**docker load -i save的镜像名**

  ```shell
  [root@localhost dockerfile]# docker load -i nginx.tar
  Loaded image: nginx:1.18.0
  
  ```

- 查看镜像的信息

  **docker images inspect 镜像id**

```shell
[root@localhost ~]# docker image inspect b9e1dc12387a
[
    {	
    	#
        "Id": "sha256:b9e1dc12387ae52eee5da783128deb8bdee0dc3b29fc3874cd81cf2190f71099", 
        "RepoTags": [
            "nginx:1.18.0"
        ],
        "RepoDigests": [
            "nginx@sha256:ebd0fd56eb30543a9195280eb81af2a9a8e6143496accd6a217c14b06acd1419"
        ],
        "Parent": "",
        "Comment": "",
        "Created": "2021-01-12T10:19:48.659168948Z",
        "Container": "532f2a046dc7add2dfe33a50deadfab25ab290083f63208a7a28be4af8df723a",
        "ContainerConfig": {
            "Hostname": "532f2a046dc7",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "ExposedPorts": {
                "80/tcp": {}
            },
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "NGINX_VERSION=1.18.0",
                "NJS_VERSION=0.4.4",
                "PKG_RELEASE=2~buster"
            ],
            "Cmd": [
                "/bin/sh",
                "-c",
                "#(nop) ",
                "CMD [\"nginx\" \"-g\" \"daemon off;\"]"
            ],
            "Image": "sha256:fa1fa2b1df44f4b913732ec164a6415ae5911a997667a339e8080a5150372408",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": [
                "/docker-entrypoint.sh"
            ],
            "OnBuild": null,
            "Labels": {
                "maintainer": "NGINX Docker Maintainers <docker-maint@nginx.com>"
            },
            "StopSignal": "SIGQUIT"
        },
        "DockerVersion": "19.03.12",
        "Author": "",
        "Config": {
            "Hostname": "",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "ExposedPorts": {
                "80/tcp": {}
            },
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "NGINX_VERSION=1.18.0",
                "NJS_VERSION=0.4.4",
                "PKG_RELEASE=2~buster"
            ],
            "Cmd": [
                "nginx",
                "-g",
                "daemon off;"
            ],
            "Image": "sha256:fa1fa2b1df44f4b913732ec164a6415ae5911a997667a339e8080a5150372408",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": [
                "/docker-entrypoint.sh"
            ],
            "OnBuild": null,
            "Labels": {
                "maintainer": "NGINX Docker Maintainers <docker-maint@nginx.com>"
            },
            "StopSignal": "SIGQUIT"
        },
        "Architecture": "amd64",
        "Os": "linux",
        "Size": 132853477,
        "VirtualSize": 132853477,
        "GraphDriver": {
            "Data": {
                "LowerDir": "/var/lib/docker/overlay2/f6f5f45790bbeaa9a269574f85d7ead01e35129667f4be98cb34221b1e5dfe53/diff:/var/lib/docker/overlay2/1b01f7b2ae8b3f3bad7da9a9fbb91858b45c475442014e79e28fe77f2ac9efc9/diff:/var/lib/docker/overlay2/660eb27f1206e80bce1d8e091b80b9c9d1f240dbf2fd715e922f0aa9a0c3ef9c/diff:/var/lib/docker/overlay2/d2d35b1defe2c427b57d9c7862df249fbee20fe82554fa8a8ab94d3d138a2b1c/diff",
                "MergedDir": "/var/lib/docker/overlay2/37b974fa2b4c3a1a8cf70fc37360487ea099b23e3bbdd57877dee635feffa139/merged",
                "UpperDir": "/var/lib/docker/overlay2/37b974fa2b4c3a1a8cf70fc37360487ea099b23e3bbdd57877dee635feffa139/diff",
                "WorkDir": "/var/lib/docker/overlay2/37b974fa2b4c3a1a8cf70fc37360487ea099b23e3bbdd57877dee635feffa139/work"
            },
            "Name": "overlay2"
        },
        "RootFS": {
            "Type": "layers",
            "Layers": [
                "sha256:cb42413394c4059335228c137fe884ff3ab8946a014014309676c25e3ac86864",
                "sha256:fd1498fb7ef6724bdd1a093339141a67a3b52369f4ab954d43766995ac4e9b1a",
                "sha256:c67dd3decb624f7a11fcad1d04268dea5919eefa74f756609d2c3dccaa51dec6",
                "sha256:13545bbbc98b3bf216d3dcb2d49f04a4ff66f2ab7918c1cd93842c51dc8dce9a",
                "sha256:1a4f5de7f6843ded207f31357d585cd570c5396a32dbf4007609fb26d05f5d28"
            ]
        },
        "Metadata": {
            "LastTagTime": "0001-01-01T00:00:00Z"
        }
    }
]

```

##### 2.1  容器命令

​	运行容器		docker  run -it  -d  --name=""  镜像id  --net=""  /bin/bash

​	

```shell

```

​	查看容器		docker ps -aq

​	

#### 三、 Docker网络

​	**安装docker时，它会自动创建三个网络，bridge（创建容器默认连接到此网络）、 none 、host**

1. Host模式：容器将不会虚拟出自己的网卡，配置自己的IP等，而是使用宿主机的IP和端口
2. Bridge模式：此模式会为每一个容器分配、设置IP等，并将容器连接到一个docker0虚拟网桥，通过docker0网桥以及Iptables nat表配置与宿主机通信。
3. None模式：该模式关闭了容器的网络功能。
4. Container：创建的容器不会创建自己的网卡，配置自己的IP，而是和一个指定的容器共享IP、端口范围。
5. 自定义网络

```shell
[root@iZ8vbisqeqec8ptea2a4cxZ docker]# docker network ls
NETWORK ID     NAME                  DRIVER    SCOPE
320b596beabe   bridge                bridge    local
fe155abe138a   composetest_default   bridge    local
a5684f0c88b2   host                  host      local
0a50348eb8a8   none                  null      local
[root@iZ8vbisqeqec8ptea2a4cxZ docker]#
```

当docker运行时，会自动使用bridge模式，这个bridge 网络代表docker0网络接口卡，每次启动一个容器都是默认使用bridge，这个可以通过docker  run --network=""来指定网络

```shell
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.28.87.5  netmask 255.255.240.0  broadcast 172.28.95.255
        inet6 fe80::216:3eff:fe08:62ee  prefixlen 64  scopeid 0x20<link>
        ether 00:16:3e:08:62:ee  txqueuelen 1000  (Ethernet)
        RX packets 2189186  bytes 865354016 (825.2 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1438374  bytes 812398363 (774.7 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
 [root@iZ8vbisqeqec8ptea2a4cxZ docker]# docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "320b596beabe4b47bb2a2ad215f5cf60e9501f5973465b420d2266307b9e7438",
        "Created": "2021-04-26T20:08:15.79442833+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
[root@iZ8vbisqeqec8ptea2a4cxZ docker]# 
```

##### 3.1  docker网络原理

​	**evth-pair**技术



##### 3.2 自定义网络

​	自定义网络时，一般使用bridge模式。

​	创建网络：	**docker network create --driver bridge --subnet=192.168.0.0/16  --gateway 192.168.0.1  develpos**

​	启动容器时指定网络： 	**docker run -d -p --name="" --net develops 容器名**

​	容器互相ping：	 **docker exec -it 容器名1 ping 容器名2**



#### 四、dockerfile

4.1、

​	

#### 八、 docker-compose

#### 九、 dockerfile多个FROM

​	

#### 十、 docker实际的用法

1. Docker运行Jenkins

   ```shell
   docker run -d -p 8880:8080 -p 50000:50000 --privileged=true --net="develops" -v /home/docker/jenkins:/var/jenkins_home jenkins/jenkins:2.277.3-centos7
   ```

   问题：

   ​	cannot touch '/var/jenkins_home/copy_reference_file.log': Permission denied报错：需要修改下目录权限, 因为当映射本地数据卷时，/home/docker/jenkins目录的拥有者为root用户，而容器中jenkins user的uid为1000
   执行如下命令即可：

   chown -R 1000:1000  /var/docker/jenkins && docker run -d -p 8880:8080 -p 50000:50000 --privileged=true --net="develops"  -v /var/docker/jenkins:/var/jenkins_home jenkins/jenkins:2.277.3-centos7

   docker run -d -p 8288:8080 -p 50000:50000 --privileged=true  -v /var/docker/jenkins:/var/jenkins_home jenkins/jenkins:lts-jdk8

   

   修改jenkins的maven下载插件： vim hudson.model.UpdateCenter.xml 替换地址为这个 URL 改成http://mirror.xmission.com/jenkins/updates/update-center.json 或https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json；或者直接用nginx代理--待研究

   

    No such plugin: cloudbees-folder：由于DockerHub中提供的jenkins的版本太低，安装插件cloudbees-folder失败，是因为下载的Jenkins.war里没有cloudbees-folder插件

2. 查看docker的镜像地址： docker info

3. 

4. 

​	

#### 十一、 应用搭建自己的jenkins镜像

##### 	11.1  jenkins的master节点的搭建

​		要求：git版本 1.18以上，需要卸载掉原先的版本

​					maven版本：要求3.30以上，需要配置文件外挂

​					

#### 十二、 windows作为linux的agent机器

​	既可以有java命令，也可以使用javaw,俩者的区别是一个时阻塞式，一个是非阻塞式的。运行之后在windows上可以用jps命令查看

java的进程,结束的话，就直接取

```shell
java/javaw -jar C:\Users\liu35\Downloads\agent.jar -jnlpUrl http://192.168.36.131:8288/computer/windows/jenkins-agent.jnlp -secret 677f68601be58840dc4361bf66e336211bdbc1560df1b7a29399608237d4217b -workDir "D:\jenkins-agent"
```

```shell
liu35@lx MINGW64 ~/Desktop
$ jps
22944 Jps

######################################
liu35@lx MINGW64 ~/Downloads
$ jps
12612 Jps
5172 jar

```

#### 十二、 用windows链接windows10系统

开始 ----> 命令行输入远程桌面链接 ---->出现弹窗后，点击选项输入ip地址和用户名  ---->点击连接  ---->  点击使用其他账号 ---->  无法验证，仍然选择是



#### 十三、 docker镜像怎么不用pull的方式传到设备上

1.将docker镜像导出成tar包

docker save 镜像名：镜像版本  > tar包

2.将tar包导入jenkins



#### 十四、webhook的注意事项

管理员 ---> setting ---> network ---> outbound request



#### 十五、 jenkins应该如何集成tscancode

@echo off
rem TscanCode web account

rem set your src file path
set srcpath="F:/test"
set cppresult=./log/cppresult.xml
set csharpresult=./log/csharpresult.xml
set luaresult=./log/luaresult.xml

./TscanCode --xml --enable=all --lua ./log %srcpath% 2>%cppresult%
./TscSharp --xml --lua ./log %srcpath% 2>%csharpresult%
./tsclua --xml --csharp ./log -fr ./log/csharp.lua.exp -fr ./log/cpp.lua.exp %srcpath% 2>%luaresult% 



#### 十六、gitlab镜像的安装

1. 镜像启动

```bash
docker run 
-d                #后台运行，全称：detach
-p 8443:443      #将容器内部端口向外映射
-p 8090:80       #将容器内80端口映射至宿主机8090端口，这是访问gitlab的端口
-p 8022:22       #将容器内22端口映射至宿主机8022端口，这是访问ssh的端口
--restart always #容器自启动
--name gitlab    #设置容器名称为gitlab
-v /usr/local/gitlab/etc:/etc/gitlab    #将容器/etc/gitlab目录挂载到宿主机/usr/local/gitlab/etc目录下，若宿主机内此目录不存在将会自动创建
-v /usr/local/gitlab/log:/var/log/gitlab    #与上面一样
-v /usr/local/gitlab/data:/var/opt/gitlab   #与上面一样
--privileged=true         #让容器获取宿主机root权限
twang2218/gitlab-ce-zh    #镜像的名称，这里也可以写镜像ID
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
docker run \
-d \
-p 8443:443 \
-p 8090:80 \
-p 8022:22 \
--restart always \
--name gitlab \
-v /usr/local/gitlab/etc:/etc/gitlab \
-v /usr/local/gitlab/log:/var/log/gitlab \
-v /usr/local/gitlab/data:/var/opt/gitlab \
--privileged=true \
gitlab/gitlab-ce:14.10.2-ce.0

```

2. gitlab配置

   gitlab.rb

   修改ssh的ip和端口：

   ```
   gitlab_rails['gitlab_ssh_host'] = '192.168.XX.XX'
   gitlab_rails['gitlab_shell_ssh_port'] = 8022
   ```

   修改时区：

   ```
   gitlab_rails['time_zone'] = 'Asia/Shanghai'
   ```

   修改gitlab网页的ip和端口号

   ```
   /usr/local/gitlab/data/gitlab-rails/etc/gitlab.yml
   ==================================================
   host:
   port:8090
   ```

   

3. 初始密码在/etc/initial_root_password



#### 十七、gitlab-runner的安装

##### 一、windows上的安装

##### 二、linux上的安装



