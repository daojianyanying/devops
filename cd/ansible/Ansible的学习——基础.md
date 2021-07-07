# Ansible的学习——基础

### 零、 devops的技术栈

- 代码管理：gitlab、svn、gerrit、github、bitbucket
- 构建工具：maven、ant、gradle、cmake/makefile、go

- 自动部署：Capistrano、 CodeDeploy
- 持续集成：jenkins、travis
- 配置管理：Ansible、SaltStack
- 容器：Docker
- 编排：k8s
- 服务注册与发现：Zookeeper
- 脚本语言：python、shell
- 日志管理：ELK
- 系统监控： Prometheus、Zabbix
- 性能监控：AppDynamic、New Relic
- 压力测试：JMeter
- 应用服务器：Tomcat、JBoss
- web服务器：Apache、nginx



一、 Ansible的安装以及可能遇到的问题

1.1 yum方式安装

​	查看可用的ansible的版本

```shell
[root@k8s-master ~]# yum info ansible
已加载插件：fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * epel: mirrors.tuna.tsinghua.edu.cn
 * extras: mirrors.aliyun.com
 * updates: mirrors.aliyun.com
已安装的软件包
名称    ：ansible
架构    ：noarch
版本    ：2.9.21
发布    ：1.el7
大小    ：103 M
源    ：installed
来自源：epel
简介    ： SSH-based configuration management, deployment, and task execution system
网址    ：http://ansible.com
协议    ： GPLv3+
描述    ： Ansible is a radically simple model-driven configuration management,
         : multi-node deployment, and remote task execution system. Ansible works
         : over SSH and does not require any software or daemons to be installed
         : on remote nodes. Extension modules can be written in any language and
         : are transferred to managed machines automatically.

[root@k8s-master ~]# 

```

安装ansible

```shell
[root@k8s-master ~]# yum -y install ansible
```

查看ansible的版本

```shell
[root@k8s-master ~]# ansible --version
ansible 2.9.21
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.5 (default, Nov 16 2020, 22:23:17) [GCC 4.8.5 20150623 (Red Hat 4.8.5-44)]
[root@k8s-master ~]# 
```



二、 Ansible的目录和配置文件

2.1 配置文件

- /etc/ansible/ansible.cfg		主配置文件，配置ansible工作特性
- /etc/ansible/hosts                  主机清单
- /etc/ansible/roles/                 存放角色的目录

2.2 主配置文件——ansible.cfg

- 打开host_key_checking = False，ssh链接时不在询问,不用输入yes
- 打开日志log_path=/var/log/ansible.log



```shell
[defaults]
# some basic default values...

#inventory      = /etc/ansible/hosts					#主机配置列表
#library        = /usr/share/my_modules/				#库文件存放目录
#module_utils   = /usr/share/my_module_utils/			#
#remote_tmp     = ~/.ansible/tmp						#临时py文件存放在远程主机的目录
#local_tmp      = ~/.ansible/tmp						#本地的临时命令执行目录
#plugin_filters_cfg = /etc/ansible/plugin_filters.yml	
#forks          = 5										#默认并发数
#poll_interval  = 15
#sudo_user      = root									#默认sudo用户
#ask_sudo_pass = True									#每次执行ansible命令是否 ssh密码
#ask_pass      = True									#
#transport      = smart								
#remote_port    = 22									#
#module_lang    = C										#
#module_set_locale = False								#
#host_key_checking = False								#是否检查对应服务器的host_key
#log_path=/var/log/ansible.log							#日志文件，建议启用
#module_name = command									#默认模块，可以修改为shellm模块
```



```shell
[root@k8s-master ~]# file /usr/bin/ansible
/usr/bin/ansible: symbolic link to `/usr/bin/ansible-2.7'
```





三、 ansible命令的使用·

**ansible  <host-pattern>  [-m  module_name]  [-a args]**

- --version				#显示版本
- -m module            #指定模块，默认为command
- -V  -VV  -VVV          #显示详细过程
- --list-hosts             #显示主机列表
- -k                            #提示输入ssh输入密码，默认key验证
- -C                            #检查并不执行
- -T                            #执行命令的超时时间
- -u                           #执行远程执行的用户
- -b                           #代替旧版的sudo   切换sudo
-  --become-user=USERNAME   #指定sudo的runas用户，默认为root
- -K                           #提示sudo时的指令