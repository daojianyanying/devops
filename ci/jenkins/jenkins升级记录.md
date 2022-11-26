# Jenkins升级记录



一、docker下的升级jenkins

原jenkins版本：2.303.1

目标jenkins版本：2.346.1

升级过程：

1. 下载2.346.1版本的war包
2. 上传到正在运行的jenkins的镜像中
3. 重启正在执行的jenkins镜像
4. 忽略build-in的master节点的变更
5. 进行简单的测试，本次升级发现了图标的bug
6. 解决bug，将303上的图片复制到重启后的346版本的war文件夹下对应的图标位置
7. 再次重启jenkins镜像，重启后再次检查问题

