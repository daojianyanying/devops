

# 一、linux的服务安装

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

### 三、安装ftp服务器

#### 3.1 虚拟用户模式下的ftp服务器

```shell
#安装工具
[root@localhost ~] yum -y install vsftpd ftp
[root@localhost ~] cd /etc/vsftpd/
[root@localhost ~] vim vuser.list #基数行为账号，偶数行为密码
#配置明文信息加密
[root@localhost ~] db_load -T -t hash -f vuser.list vuser.db
[root@localhost ~] file vuser.db
[root@localhost ~] chmod 600 vuser.db
[root@localhost ~] rm -rf vuser.list
#配置ftp共享目录
[root@localhost ~] useradd -d /var/ftproot -s /sbin/nologin virtual
[root@localhost ~] ls -ld /var/ftproot/
[root@localhost ~] chmod -Rf 755 /var/ftproot
#配置PAM认证
[root@localhost ~]vim /etc/pam.d/vsftpd.vu
auth	required	pam.userdb.so	db=/etc/vsftpd/vuser
account	required	pam.userdb.so	db=/etc/vsftpd/vuser
#配置用户的ftp权限
[root@localhost ~] mkdir /etc/vsftpd/vusers_dir/
[root@localhost ~] cd /etc/vsftpd/vusers_dir/
[root@localhost ~] touch lisi
[root@localhost ~] vim zhangsan
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
#修改配置文件
[root@localhost ~] vim /etc/vsftpd/vsftpd.conf
#增加/修改项
anonymoue_enable=NO
local_enable=YES
guest_enable=YES
guest_username=YES
allow_writeable_chroot=YES
pam_service_name=vsftpd.vu
user_config_dir=/etc/vsftpd/vusers_dir
#重启测试
[root@localhost ~] systemctl restart vsftpd
[root@localhost ~] systemctl enable vsftpd
#打开selinux的限制
[root@localhost ~] getsebool -a | grep ftp 
[root@localhost ~] setsebool -P ftpd_full_access=on
#测试

```



#### 3.2 ftp的命令

##### 3.2.1	ftp的工作方式

type	查看当前的传输模式

​	FTP支持两种模式，一种方式叫做Standard (也就是 PORT方式，主动方式)，一种是 Passive (也就是PASV，被动方式)。 Standard模式 FTP的客户端发送 PORT 命令到FTP服务器。Passive模式FTP的客户端发送 PASV命令到 FTP Server。

​	Port模式FTP 客户端首先和FTP服务器的TCP 21端口建立连接，通过这个通道发送命令，客户端需要接收数据的时候在这个通道上发送PORT命令。 PORT命令包含了客户端用什么端口接收数据。在传送数据的时候，服务器端通过自己的TCP 20端口连接至客户端的指定端口发送数据。 FTP server必须和客户端建立一个新的连接用来传送数据。（可以看到在这种方式下是客户端和服务器建立控制连接，服务器向客户端建立数据连接，其中，客户端的控制连接和数据连接的端口号是大于1024的两个端口号（临时端口），而FTP服务器的数据端口为20，控制端口为21）

　　Passive模式在建立控制通道的时候和Standard模式类似，但建立连接后发送的不是Port命令，而是Pasv命令。FTP服务器收到Pasv命令后，随机打开一个临时端口（也叫自由端口，端口号大于1023小于65535）并且通知客户端在这个端口上传送数据的请求，客户端连接FTP服务器此端口，然后FTP服务器将通过这个端口进行数据的传送，这个时候FTP server不再需要建立一个新的和客户端之间的连接。（可以看到这种情况下的连接都是由客户端向服务器发起的，与下面所说的“为了解决服务器发起到客户的连接的问题，人们开发了一种不同的FTP连接方式。这就是所谓的被动方式”相对应，而服务器端的数据端口是临时端口，而不是常规的20）

　　很多防火墙在设置的时候都是不允许接受外部发起的连接的，所以许多位于防火墙后或内网的FTP服务器不支持PASV模式，因为客户端无法穿过防火墙打开FTP服务器的高端端口；而许多内网的客户端不能用PORT模式登陆FTP服务器，因为从服务器的TCP 20无法和内部网络的客户端建立一个新的连接，造成无法工作。

##### 3.2.2 ftp的传输方式

 ASCII传输模式和二进制数据传输模式

bin	设定传输模式为二进制

ascii	设定传输模式为ASCII

