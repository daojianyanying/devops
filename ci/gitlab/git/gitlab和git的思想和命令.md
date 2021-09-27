# gitlab和git的思想和命令

## 一、gitlab

### 1.1 gitlab的仓库所在地址

gitlab的仓库地址：/home/docker/gitlab/data/git-data/repositories   /var/opt/gitlab/git-data/repositories

```shell
[root@k8s-master repositories]# ll
总用量 0
drwxr-sr-x. 3 chrony polkitd 17 8月  20 21:07 +gitaly
drwxr-s---. 9 chrony polkitd 76 6月  27 09:03 @hashed

```

具体的地址根据项目工程的id，生成对应的hash值，就是repository地址目录：

```shell
echo -n 60 | sha256sum
```





### 二、 git

### 2.1 git push的操作

### 三、gitlab的安装配置-----配置文件

```shell
[root@k8s-master config]# grep -v "^#" gitlab.rb | grep -v "^$"
external_url 'http://192.168.36.150'
gitlab_rails['gitlab_ssh_host'] = '192.168.36.150'
gitlab_rails['time_zone'] = 'Asia/Shanghai'
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.163.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "liu3574226@163.com"
gitlab_rails['smtp_password'] = "MVPCFGTNOOBXPALC"
gitlab_rails['smtp_domain'] = "163.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = true
gitlab_rails['gitlab_email_from'] = "liu3574226@163.com"
gitlab_rails['gitlab_email_display_name'] = "gitlab_admin"
gitlab_rails['gitlab_shell_ssh_port'] = 2222
[root@k8s-master config]#

#####注意事项
```

这里的字符串一定要用双引号，其次这里的时区请用Asia/Shanghai,因为ubantu不支持Asia/Beijing，会导致gitlab启动报错