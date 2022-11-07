# 问题总结

#### 2021/4/24问题

##### Q1、 ARP包和IP包的区别？？

##### Q2、 tcpdump的安装，这是linux上的抓包工具？

安装命令：yum -y install tcpdump

启动tcpdump: tcpdump

监视指定接口的数据包：

```shell
tcpdump -i 网络接口名
```

https://www.cnblogs.com/Jtianlin/p/4330723.html

查看可以抓包的网络接口：

```shell
sudo tcpdump -D
```

##### Q3、x86、x64、arm的区别？

##### Q4、sh  -c中的-c的作用？

##### Q5、 linux的LANG的环境变量

##### Q6、>>  /etc/passwd修改linux环境的密码？

##### Q7、防火墙、DHCP、NAT

##### Q8、 linux的/etc/services?

##### Q9、关于maven的依赖冲突

##### Q10、localhost、127.0.0.1、本地ip的区别

##### Q11、ABC类ip地址和ABC类的私有地址？

​	ABC类地址：

- A类网络的IP地址范围为：1.0.0.1－126.255.255.254

- B类网络的IP地址范围为：128.1.0.1－191.255.255.254

- C类网络的IP地址范围为：192.0.1.1－223.255.255.254

​	ABC类私有ip地址：

- A类网络的私有IP地址范围为：10.0.0.0~10.255.255.255 	1个

- B类网络的私有IP地址范围为：172.16.0.0~172.31.255.255    16个

- C类网络的私有IP地址范围为：192.168.0.0~192.168.255.255    255个





##### Q12、IPv4 forwarding is disabled. Networking will not work报错？

```shell
#centos 7 docker 启动了一个web服务 但是启动时 报
#WARNING: IPv4 forwarding is disabled. Networking will not work.
#需要做如下配置
#解决办法：
vi /etc/sysctl.conf
net.ipv4.ip_forward=1  #添加这段代码
#重启network服务
systemctl restart network && systemctl restart docker
#查看是否修改成功 （备注：返回1，就是成功）
[root@docker-node2 ~]# sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 1
```



##### Q13、 一个电脑配置多个git的ssh

https://www.jb51.net/article/200087.htm

Q14、 gitlab的clone地址显示不对 gitlab的时间不对

​	解决方式：

- 

Q5、安装配置repo，在windows上

```shell
mkdir ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+rx ~/bin/repo //如果下载下来的repo直接具有rx权限，这步可以不用做

# 先随便新建源码目录
mkdir -p ~/AOSP/.repo
cd ~/AOSP/.repo
# clone工具集
git clone https://gerrit.googlesource.com/git-repo
# 一定要改文件夹名
mv git-repo repo
# 回到AOSP源码目录
cd ..
# 保证你成功
repo init -u https://aosp.tuna.tsinghua.edu.cn/platform/manifest -b android-10.0.0_r25 --worktree //这里的url可以是http协议url也可以是ssh协议url


```

##### Q15、搭建repo的自己的命令仓库和manifest.git

出现问题和解决方案 ？

待解决的问题：是否可以影直接拷贝的sh的文件的方式就可以实现对命令的使用

- repo_url要替换成git开头的网址，否则报错？
- 修改repo中的分支
- 给自己的代码仓库加上一个tag
- windows环境会报权限问题，linux环境待验证？

解决方案：学习Python语言



