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

