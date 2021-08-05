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



### 一、 Ansible的安装以及可能遇到的问题

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



### 二、 Ansible的目录和配置文件

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





### 三、 ansible命令的使用·

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



### 四、yml语法规则——模块

##### 4.1  user模块

- name: 必选参数，指定要操作的用户名

- group: 用于指定用户的所属组

- groups: 指定用户所在的附加组

- append: 是否覆盖原先的附加组，和groups一起使用

- shell: 指定用户的默认shell

- uid: 指定用户的id号

- expires : 设置用户的过期时间，相当于/etc/shadow文件的第8列

  ```shell
  [root@k8s-master playbook]# date -d 2021-12-31 +%s
  1640880000
  expire=1640880000
  ```

- state: present表示用户存在， absent表示删除用户

- home: 

- create_home: yes或者no 当创建用户，目录不存在时，为用户创建home目录

- home: 指定用户的home目录

- password： 设定用户的密码

- system: 是否设置为系统账户



##### 4.2 group模块

- name: 指定要操作的用户组
- state: 默认为present,为absent表示删除所数组
- gid: 指定组的gid
- system: 是否设置为系统账户



##### 4.3 service模块

- name: 指定操作服务的名字
- state=started|stopped|restarted|reloaded：指定服务的状态
- enabled=yes|no：指定服务是否为开机启动项



##### 4.4 shell模块

- chdir： 指定一个命令操作目录
- creates: 使用参数指定一个目录，文件存在就不会执行命令
- removes: 指定一个文件，不存在时就不会执行该命令
- 

### 五、 playbooks的使用

##### 5.1  核心元素

- Hosts：针对哪些主机

- Tasks：任务集

- Variables：内置变量或自定义变量在playbooks中调用

- Template：模板 可以替换模板文件中的变量并实现一些简单逻辑文件

- Handler和notify结合使用：由特定条件触发的操作，满足条件方才执行，否则不执行

- tags：标签 执行某条任务的执行，用于选择执行playbooks中的部分代码

  

###### 5.1.1 Hosts

用于指定用执行任务的主机

```shell
www.devops.com #
www.devops.com:www.ci.com:www.cd.com #
192.168.36.150 #
192.168.36.* #
devops:test #或者
devops:&ci #交集
devops:!ci #在devops组，但是不在ci组的
```

###### 5.1.2  remote_user组件

用于Host和Task中，也可以通过指定其通过sudo的方式在远程主机上执行任务，其可用于play全局或者某任务，此外，甚至可以在sudo时使用sudo_user指定sudo时切换的用户。

```yaml
- hosts: devops
    remote_user: root
  tasks: 
    - name: test connection
      ping: 
      remote_user: magedu
      sudo: yes
      sudo_user: wang
```

###### 5.1.3 task列表和action组件

play的主体时task list



**task的俩种格式：**

- action: model arguments
- module: arguments (建议使用)

```yaml
---
- hosts: devops
  remote_user: root
  task: 
    - name: install httpd
      yum: name=httpd
    - name: start httpd
      service: name=http state=started enabled=yes
```

###### 5.1.4 其他组件

某任务的状态在运行后为changed时，可以通过“notify”通知给相应的handlers任务。

任务可以用过打tags标签，可以在ansible-playbook命令上使用-t调用



###### 5.1.5 ShellScript VS playbooks

```shell
#/bin/bash
#shell实现方式
#安装Apache HTTP
yum install -y --quiet httpd
#复制配置文件
cp /tmp/httpd.conf /etc/httpd/conf/httpd.conf
cp /tmp/vhosts.conf /etc/httpd/conf.d/
#启动Apache,并且设置为开机启动
systemctl enable --now httpd
```

```yaml
#playbooks实现
---
  - hosts: devops
    remote_user: root
    tasks: 
      - name: "a安装Apache HTTP"
        yum: name=httpd
      - name: "复制配置文件"
        copy: src=/tmp/httpd.conf dest=/etc/httpd/conf/httpd.conf
      - name: "复制配置文件"
        copy: src=/tmp/vhosts.conf dest=/etc/httpd/conf.d/
      - name: "设置为开机启动"
        service: name=httpd state=started enabled=yes
    
```



##### 5.2 playbooks命令

**格式：** **ansible-playbook  filename.yaml  ...  options**

- -C:——只检测可能发生的改变，但是不执行
- --list-host:——列出运行任务的主机
- --list-tags:——列出tag
- --list-tasks:——列出tasks
- --limit 主机列表:——只针对主机列表中的主机执行
- -v   -vv   -vvv: 显示过程



