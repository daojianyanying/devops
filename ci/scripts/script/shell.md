# Shell脚本

1. #### SSH免密认证

   - ssh-keygen
   - sshpass
   - shell的语法

   ```shell
   su -用户名 -c "命令"  #
   
   
   $? $# $0
   
   
   ```

   - aaaa

   

   shell免密认证代码：

   ```bash
   #!/bin/bash
   set -ex
   #ubantu默认的sh不是bash，可以通过sudo dpkg-reconfigure dash，选择否 然后确认
   set -o pipefail   
   
   ROOT_PASSWORD="123456"
   USER_NAME=$1
   USER_PASSWORD=$2
   
   ROOT_PASS="redhat"
   HOST_LIST="192.168.10.20 192.168.10.67 192.168.10.25"
   
   if [ $# -lt 2 ]
   then
   	echo Usage $0 username password
   	exit 1
   fi
   
   useradd $USER_NAME
   echo $USER_PASSWORD | passwd --stdin $USER_NAME
   
   su -$USER_NAME -c "echo "" | ssh-keygen -t rsa"
   ssh_public_key="`cat /home/$USER_NAME/id_rsa.pub`"
   
   for host in HOST_LIST;
   do
   	sshpass -p$ROOT_PASSWORD ssh -o StrictHostKeyChecking=no root@$host "useradd $USER_NAME"
   	sshpass -p$ROOT_PASSWORD ssh -o StrictHostKeyChecking=no root@$host "echo $USER_PASSWORD | passwd --stdin $USER_NAME"
   	sshpass -p$ROOT_PASSWORD ssh -o StrictHostKeyChecking=no root@$host "mkdir /home/$USER_NAME/.ssh"
   	sshpass -p$ROOT_PASSWORD ssh -o StrictHostKeyChecking=no root@$host "echo $ssh_public_key > /home/$USER_NAME/.ssh/authorized_keys"
   	sshpass -p$ROOT_PASSWORD ssh -o StrictHostKeyChecking=no root@$host "chmod 600 /home/$USER_NAME/.ssh/authorized_keys"
   	sshpass -p$ROOT_PASSWORD ssh -o StrictHostKeyChecking=no root@$host "chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh/authorized"
   done
   
   ```

   

2. 