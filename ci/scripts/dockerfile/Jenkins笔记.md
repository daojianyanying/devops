# Jenkins笔记

一、 Jenkins安装

1.1. Jekins配置git的密钥项

- 账号密码方式：再输入仓库地址的时候，需要http方式的地址
- gitlab topic token: 再输入仓库地址的时候,这种方式无法选择
- GitLab API token:再输入仓库地址的时候，需要ssh方式的地址



1.2 jekins的分布式搭建

​	启动方式：

- Launch agent by connecting it to the master：在从机运行agent的jar包，先下载agent.jar，再用nohup启动
- Launch agent via execution of command on the master：
- Launch agents via SSH：有报错
- Let Jenkins control this Windows agent as a Windows service：

​	