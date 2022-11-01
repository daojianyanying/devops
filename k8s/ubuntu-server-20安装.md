



# ubantu-server安装

版本：20.4.5-server

安装环境：VMare-16pro

安装步骤：

- 选择语言

![](./image/ubuntu_install_1.png)



- 选择是否在安装时更新，选择的话，将会下载最新的ubuntu的版本进行安装，这里不用更新

![](./image/ubuntu_install_2.png)



- 键盘语言设置

![](./image/ubuntu_install_3.png)



- 设置静态ip，ubuntu20.4的网络配置如下。如果用Vmare的话，网关时XXX.XXX.XXX.2

  ```shell
  sudo vim /etc/netplan/00-installer-config.yaml
  # This is the network config written by 'subiquity'
  network:
   ethernets:
    ens32:
     addresses:
     - 192.168.xx.xx/24      ## 此处改为自己的IP
     gateway4: 192.168.xx.1   ## 网关
     nameservers:
      addresses:
      - 119.29.29.29
   version: 2
   
   netplan apply
   ping -c 3 www.baidu.com
  ```

  

![](./image/ubuntu_install_4.png)

![](./image/ubuntu_install_5.png)

![](./image/ubuntu_install_6.png)

![](./image/ubuntu_install_7.png)



- 代理地址

![](./image/ubuntu_install_8.png)



- 填写apt使用的源

![](./image/ubuntu_install_9.png)



- 分区

![](./image/ubuntu_install_10.png)

![](./image/ubuntu_install_11.png)

![](./image/ubuntu_install_12.png)

![](./image/ubuntu_install_13.png)

![](./image/ubuntu_install_14.png)

![](./image/ubuntu_install_15.png)

![](./image/ubuntu_install_16.png)

![](./image/ubuntu_install_17.png)



- 计算机名、账户密码设置

![](./image/ubuntu_install_18.png)

![](./image/ubuntu_install_19.png)



- 不启动ftp服务器

![](./image/ubuntu_install_20.png)



- 选择系统安装软件

![](./image/ubuntu_install_21.png)

![](./image/ubuntu_install_22.png)

![](./image/ubuntu_install_23.png)

