# Linux命令

### 一、 chkconfig命令 ——centos6设置服务开机重启

​	chkconfig命令主要用来更新（启动或停止）和查询系统服务的运行级信息。谨记chkconfig不是立即自动禁止或激活一个服务，它只是简单的改变了符号连接。chkconfig是管理系统服务(service)的命令行工具。所谓系统服务(service)，就是随系统启动而启动，随系统关闭而关闭的程序。

```shell
[root@localhost ~]# ls /etc/init.d/
functions  jenkins  netconsole  network  README
```

​	**用法：**

```shell
Linux chkconfig命令使用范例：
chkconfig--list#列出所有的系统服务
chkconfig--addhttpd#增加httpd服务
chkconfig--delhttpd#删除httpd服务
chkconfig --level httpd 2345 on#设置httpd在运行级别为2、3、4、5的情况下都是on（开启）的状态
chkconfig --list#列出系统所有的服务启动情况
chkconfig --listmysqld#列出mysqld服务设置情况
chkconfig --level 35 mysqld on#设定mysqld在等级3和5为开机运行服务，--level35表示操作只在等级3和5执行，on表示启动，off表示关闭
chkconfig mysqld on#设定mysqld在各等级为on，“各等级”包括2、3、4、5等级
```

```
Linux chkconfig命令如何增加一个服务：
1.服务脚本必须存放在/etc/ini.d/目录下；
2.chkconfig--addservicename
在chkconfig工具服务列表中增加此服务，此时服务会被在/etc/rc.d/rcN.d中赋予K/S入口了；
3.chkconfig--level35mysqldon
修改服务的默认启动等级。
```

```shell
[root@localhost ~]$ chkconfig --list                                      # 等级0：关机
atop            0:off   1:off   2:off   3:off   4:off   5:off   6:off     # 等级1：单用户模式/救援模式
auditd          0:off   1:off   2:off   3:off   4:on    5:off   6:off     # 等级2：无网络连接的多用户命令行模式
crond           0:off   1:off   2:on    3:on    4:on    5:on    6:off     # 等级3：有网络连接的多用户命令行模式
ipset           0:off   1:off   2:on    3:on    4:on    5:on    6:off     # 等级4：不可用
iptables        0:off   1:off   2:off   3:off   4:on    5:off   6:off     # 等级5：带图形界面的多用户模式
mysql           0:off   1:off   2:on    3:on    4:on    5:on    6:off     # 等级6：重启
```

### 二、systemctl —— 服务管理方式

​	systemd是Linux系统最新的初始化系统(init),作用是提高系统的启动速度，尽可能启动较少的进程，尽可能更多进程并发启动。

systemd对应的进程管理命令是systemctl。systemctl 是系统服务管理器命令，它实际上将 service 和 chkconfig 这两个命令组合到一起。

```text
systemctl list-units --all --type=service  //列出系统所有服务
systemctl list-unit-files|grep myapp //查看系统服务文件是否被识别
ls /usr/lib/systemd/system  //启动的脚本文件目录
systemctl enable crond.service //开机启动 .service可以省略
systemctl disable crond.service //禁止开机启动
systemctl status crond.service  //查看服务状态
systemctl start crond.service //启动服务
systemctl stop crond.service  //停止服务
systemctl restart crond.service  //重启服务
systemctl is-enabled crond.service  //查看某个服务是否开机启动
service --status-all //查看当前所有服务

```

​	

​	Centos7的服务systemctl脚本存放在：`/usr/lib/systemd/`目录下，有系统（system）和用户（user）之分，一般需要开机不登录就能运行的程序，就存放在`/usr/lib/systemd/system/`目录下

```shell
[root@localhost system]# ll | grep  service
-rw-r--r--. 1 root root  275 8月   9 2019 arp-ethers.service
-rw-r--r--. 1 root root 1384 8月   8 2019 auditd.service
lrwxrwxrwx. 1 root root   14 9月  16 2020 autovt@.service -> getty@.service
-r--r--r--. 1 root root  429 3月  16 23:26 blk-availability.service
-rw-r--r--. 1 root root  116 8月  19 2019 brandbot.service
-rw-r--r--. 1 root root  209 8月   6 2019 chrony-dnssrv@.service
-rw-r--r--. 1 root root  495 8月   8 2019 chronyd.service
-rw-r--r--. 1 root root  472 9月  19 2018 chrony-wait.service
-rw-r--r--. 1 root root  787 4月   1 2020 console-getty.service
-rw-r--r--. 1 root root  749 4月   1 2020 console-shell.service
-rw-r--r--. 1 root root 1263 3月   9 06:56 containerd.service
-rw-r--r--. 1 root root  808 4月   1 2020 container-getty@.service
-rw-r--r--. 1 root root  294 4月   1 2020 cpupower.service
-rw-r--r--. 1 root root  318 8月   9 2019 crond.service

```

​	**systemctl启动服务编写**

服务如果需要自动启动，需要在/etc/systemd/system/multi-user.target.wants/***.service添加链接文件到/usr/lib/systemd/system/***.service

重新加载配置文件：systemctl daemon-reload	

1. 服务以.service结尾，一般会分为3部分：**[Unit]、[Service]和[Install]**，以sshd为实例如下：

```shell
[Unit]
#描述信息
Description=OpenSSH server daemon 
#一个url 定义服务的具体介绍网址
Documentation=man:sshd(8) man:sshd_config(5)
#表示服务需要在***服务启动之后执行
After=network.target sshd-keygen.service 
#弱依赖关系
Wants=sshd-keygen.service 

[Service]
#定义影响ExecStart及相关参数的功能的unit进程启动类型
#1.simple默认参数，进程作为主进程
#2.forking是后台运行的形式，主进程退出，os接管子进程
#3.oneshot 类似simple，在开始后续单元之前，过程退出
#4.DBUS 类似simple，但随后的单元只在主进程获得D总线名称之后才启动
#5.notify 类似simple，但是随后的单元仅在通过sd_notify()函数发送通知消息之后才启动
#6.idle类似simple，服务二进制文件的实际执行被延迟到所有作业完成为止，不与其他服务的输出相混合,如状态输出与服务的shell输出混合
Type=notify 
#环境配置文件
EnvironmentFile=/etc/sysconfig/sshd
#指明启动unit要运行命令或脚本的绝对路径
ExecStart=/usr/sbin/sshd -D $OPTIONS
#重启当前服务时执行的命令
ExecReload=/bin/kill -HUP $MAINPID
#control-group（默认值）：当前控制组里面的所有子进程，都会被杀掉
#process：只杀主进程
#mixed：主进程将收到 SIGTERM 信号，子进程收到 SIGKILL 信号
#none：没有进程会被杀掉，只是执行服务的 stop 命令。
KillMode=process
#当设定Restart=1 时，则当次daemon服务意外终止后，会再次自动启动此服务
Restart=on-failure
#定义 Systemd 停止当前服务之前等待的秒数
RestartSec=42s
#设置服务运行的用户
User=root
#设置服务运行的用户组
Group=root
#为存放PID的文件路径, 对于type设置为forking建议使用该项
PIDFile==

[Install]
#WantedBy 表示该服务所在的 Target， multi-user.target 可以设置为多用户模式具体参考手册systemd.unit(5)
WantedBy=multi-user.target
```



### 三、service命令

​	"/etc/init.d/"  服务所在的目录，也就是说，service只能操作这个目录下的服务。如果要使用service管理服务，就必须把相应服务的脚本存放在这个目录下即可。/etc/init.d 是 /etc/rc.d/init.d 的软链接(soft link)

```shell
[root@localhost init.d]# ll
总用量 48
-rw-r--r--. 1 root root 18281 8月  19 2019 functions
-rwxr-xr-x. 1 root root  6772 9月  26 2020 jenkins
-rwxr-xr-x. 1 root root  4569 8月  19 2019 netconsole
-rwxr-xr-x. 1 root root  7928 8月  19 2019 network
-rw-r--r--. 1 root root  1160 4月   1 2020 README
[root@localhost init.d]#

```

### 四、ps命令

 