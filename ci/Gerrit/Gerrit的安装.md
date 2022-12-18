# Gerrit的安装

### 零、版本选择

操作系统：ubuntu 20.4

Gerrit + jdk + nginx + git

Gerrit：3.7

jdk：java 11

git: 

gerrit插件地址: https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.7/ 

Gerrit下载链接

```
https://gerrit-releases.storage.googleapis.com/gerrit-3.7.0.war

sudo apt-cache search jdk
sudo apt install -y openjdk-11-jdk
sudo apt install apache2-utils
```



### 一、mysql的安装

```shell
#!/bin/bash
##################################################
#
#Auther:liuxiang
#CreateDate:2021.6.19
#Description:安装mysql 5.7.20
#UpdateDate:2021.6.19
#
##################################################
set -x

#下载对应mysql版本
mkdir -p /opt/software/mysql && cd /opt/software/mysql
wget https://cdn.mysql.com/archives/mysql-5.7/mysql-5.7.20-linux-glibc2.12-x86_64.tar.gz -O mysql-5.7.20.tar.gz
tar -zxvf mysql-5.7.20.tar.gz 
mv mysql-5.7.20-linux-glibc2.12-x86_64 mysql && mv mysql /usr/local

#创建用户组和用户
groupadd mysql
useradd -r -g mysql mysql
chown -R mysql /usr/localmysql/
chgrp -R mysql /usr/localmysql/

#创建配置文件
cat > /etc/my.cnf<<EOF
[client]
port = 3306
socket = /tmp/mysql.sock

[mysqld]
character_set_server=utf8
init_connect='SET NAMES utf8'
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data
socket=/tmp/mysql.sock
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
#不区分大小写
lower_case_table_names = 1
sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
max_connections=5000
default-time_zone = '+8:00'
EOF

#安装依赖包
yum -y install libaio
mkdir -p /var/log && touch /var/log/mysqld.log && cd /var/log &&  chmod 777 mysqld.log && chown mysql:mysql mysqld.log

#初始化数据库
/usr/local/mysql/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data

#打印密码
cat /var/log/mysqld.log | grep "root@localhost"

mkdir -p /var/run/mysqld && cd /var/run/ && chmod 777 mysqld && cd /var/run/mysqld 
touch mysqld.pid && chmod 777 mysqld.pid && chown mysql:mysql mysqld.pid

/usr/local/mysql/support-files/mysql.server start

#设置开机启动
cd /usr/local/mysql/support-files
cp mysql.server /etc/init.d/mysqld
chkconfig --add mysqld

#修改mysql的密码:
#1.修改/etc/my.cnf  在[mysqld]下面添加一条命令：skip-grant-tables
#2.重启mysql，就可以免密登陆
#3.使用mysql命令修改密码
#	use mysql
#	update user set authentication_string=password('填入新密码”') where user='root';
#	flush privileges;
#	exit
#4.再更改/etc/my.cnf，删除skip-grant-tables
#
#mysql的几个目录的说明：
#1.socket=/tmp/mysql.sock
#2.pid-file=/var/run/mysqld/mysqld.pid
#
#
#安装时可能遇到的问题
#1.mysql连接IP地址失败，链接的ip显示错误，是因为root用户的链接设置只是给了localhost需要修改
#	use mysql;
#	update user set host='%' where user = 'root'
#重启服务后即可
#2.设置当前用户的密码
#	set password=password("youpassword");
#	 flush privileges;
#
```





### 二、gerrit的安装

```shell
java -jar gerrit-2.7.0.war init -d /data/gerrit_site  #默认不配置，直接全部回车，完成后再进入配置文件修
vim gerrit.config
#####
[gerrit]
        basePath = git
        canonicalWebUrl = http://devops:28080/
        serverId = 89817610-3ba7-448c-8f8e-99189e90282e
[container]
        javaOptions = "-Dflogger.backend_factory=com.google.common.flogger.backend.log4j.Log4jBackendFactory#getInstance"
        javaOptions = "-Dflogger.logging_context=com.google.gerrit.server.logging.LoggingContext#getInstance"
        user = root
        javaHome = /usr/lib/jvm/java-11-openjdk-amd64
[index]
        type = lucene
[auth]
        type = HTTP
[receive]
        enableSignedPush = false
[sendemail]
        smtpServer = localhost
[sshd]
        listenAddress = *:29418
[httpd]
        listenUrl = http://*:28080/
[cache]
        directory = cache

```



### 三、nginx的安装和配置

auth_basic_user_file /home/gerrit/gerrit.password 这一行和你安装的代码路径和httppasswd

```shell
sudo apt install nginx
sudo nginx -v
sudo vim /etc/nginx/sites-enabled/default

server {
listen 28081;
server_name localhost;

#charset koi8-r;

#access_log logs/host.access.log main;

location / {
    #root html;
    #index index.html index.htm;
    auth_basic "Gerrit Code Review";
    auth_basic_user_file /data/gerrit_site/etc/gerrit.password;
    proxy_pass http://10.0.2.37:28080;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header Host $host;
}


nginx -s reload
```



### 四、用户创建

```shell
sudo apt install apache2-utils
sudo htpasswd -c /data/gerrit_site/etc/gerrit.password admin
```

