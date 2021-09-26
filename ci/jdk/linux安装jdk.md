

# 一、linux的安装

### 设置linux的jdk环境变量



```shell
export JAVA_HOME=/usr/local/jdk-11
export CLASSPATH=$:CLASSPATH:$JAVA_HOME/lib/
export PATH=$PATH:$JAVA_HOME/bin

source /etc/profile ; java -version

```



### 一、repo的安装和配置

#### windows系统的配置

```shell

cd 用户目录
mkdir bin
cd bin
curl https://mirrors.tuna.tsinghua.edu.cn/git/git-repo -o repo



下载repo的的仓库上传到自己的本地仓库,一定要打tag

repo init --repo-url=ssh://git@192.168.36.150:2222/develops/git-repo.git --repo-rev=master --no-repo-verify
```



### 二、DNS服务器的搭建——bind

#### 2.1  安装bind服务，配置正反向解析

##### 2.1.0  基础配置

配置文件：

​	主配置文件：/etc/name.conf		定义bind服务程序的运行。

​	区域配置文件：/etc/named.rfc.1912.zones		用来保存域名和ip地址对应关系的所在位置。

​	数据配置文件目录：/var/named		用来保存域名和ip地址真实的对应关系的数据配置文件。

配置  /etc/name.conf

```shell
[root@localhost named]# vim /etc/named.conf
//
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//
// See the BIND Administrator's Reference Manual (ARM) for details about the
// configuration located in /usr/share/doc/bind-{version}/Bv9ARM.html

options {
        listen-on port 53 { any; };  ########################修改这里
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        recursing-file  "/var/named/data/named.recursing";
        secroots-file   "/var/named/data/named.secroots";
        allow-query     { any; };	########################修改这里

        /
```



##### 2.1.1  安装程序

**这里一定安装bind-chroot，因为之前安装bind，测试反向解析是有问题的(待验证解决，如果解决，随后附上)**

```shell
[root@localhost named]#yum -y install bind-utils
[root@localhost named]# yum install -y bind-chroot
已加载插件：fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.ustc.edu.cn
 * extras: mirrors.ustc.edu.cn
 * updates: mirrors.ustc.edu.cn
软件包 32:bind-chroot-9.11.4-26.P2.el7_9.7.x86_64 已安装并且是最新版本
无须任何处理
[root@localhost named]#
###### 安 装 完 成 ######
```



##### 2.1.2   配置正向解析

```shell
[root@localhost named]# vim /etc/named.rfc1912.zones
zone "idevop.com" IN {
        type master;
        file "idevop.com.zone";
        allow-update {none;};
};

[root@localhost named]# cd /var/named
[root@localhost named]# cp -a named.localhost idevop.com.zone
[root@localhost named]# vim idevop.com.zone
$TTL 1D
@       IN SOA  idevop.com. rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      ns.idevop.com
ns      IN A    192.168.36.131   #DNS的解析服务器
        IN MX 10        mail.idevop.com
mail    IN A    192.168.36.10
www     IN A    192.168.36.11
bbs     IN A    192.168.36.12


```

检验：

```shell
[root@localhost named]# named -u named
[root@localhost named]# nslookup mail.idevop.com
Server:         192.168.36.131
Address:        192.168.36.131#53

Name:   mail.idevop.com
Address: 192.168.36.10
```



##### 2.1.3  配置反向解析

```shell
[root@localhost named]# vim /etc/named.rfc1912.zones
zone "36.168.192.in-addr.arpa" IN {
        type master;
        file "192.168.36.arpa";
};

[root@localhost named]# cd /var/named
[root@localhost named]# cp -a named.localhost 192.168.36.arpa
[root@localhost named]# vim 192.168.36.arpa
$TTL 1D
@       IN SOA  devops.com  rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      ns.devops.com.
ns      A       192.168.36.131
11      PTR     mail.devops.com.
12      PTR     www.devops.com.

```

检验：

```shell
[root@localhost named]# nslookup 192.168.36.10
10.36.168.192.in-addr.arpa      name = ns.devops.com.

```



#### 2.2 配置从服务器

