# Linux中重要的用法

### 零、正则表达式



### 一、awk的用法

#### 1.1  基础知识

##### 	1.1.1  awk内置函数

| **属性** | **说明**                                   |
| -------- | ------------------------------------------ |
| $0       | 当前记录段（作为单个变量）                 |
| $1~$n    | 当前记录的第n个字段，字段间由FS分隔        |
| FS       | 输入字段分隔符 默认是空格                  |
| NF       | 当前记录中的字段个数，就是有多少列         |
| NR       | 已经读出的记录数，就是行号/段落号，从1开始 |
| RS       | 输入的记录他隔符默 认为换行符              |
| OFS      | 输出字段分隔符 默认也是空格                |
| ORS      | 输出的记录分隔符，默认为换行符             |

#### 1.2  awk案例

##### 	1.2.1  插入几个字段，在“a, b, c,d”的b后面插入三个字段e f g

当修改$2时，会根据OFS重建$0

```shell
$ echo "a b c d e" | awk '{$2="b e f g";print}'
a b e f g c d e
```



##### 	1.2.2  格式化空白，将如下文件格式化

```shell
	a b		cd e
cc 	e	gg h
dk ddd   d fu 
---1.txt

awk 'BEGIN{OFS="\t"}{$1=$1;print}' 1.txt
#注意这里的$1=$1,不能写成$0=$0
```



##### 	1.2.3  ifconfig筛选ipv4,出去lo网卡

```shell
#方式1:
ifconfig | awk '/inet / && !($2 ~/^127/) {print $2} '
#方式2:
ifconfig | awk 'BEGIN{RS=""}!/^lo:/ {print $6}'   #注意这里的RS="" 不能写成RS=" "
#方式3:
ifconfig | awk 'BEGIN{RS="";FS="\n"} !/^lo:/ {$0=$2;FS=" "; $0=$0; print $2}'

[root@localhost ~]# ifconfig
ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.36.131  netmask 255.255.255.0  broadcast 192.168.36.255
        inet6 fe80::c4c7:a9eb:defd:f199  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:0b:a4:45  txqueuelen 1000  (Ethernet)
        RX packets 80496  bytes 40615633 (38.7 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 125721  bytes 184142060 (175.6 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 56  bytes 4872 (4.7 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 56  bytes 4872 (4.7 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


```



##### 	1.2.4   读取配置文件.ini 配置文件的某一段，以ngnix为例



##### 	1.2.5  根据字段去重，去除uid=xxx重复的行

```shell
2019-1-13_12:00 _index? uid=123
2019-1-13_13:00 _index? uid=223
2019-1-13_14:00 _index? uid=123
2019-1-13_15:00 _index? uid=323
2019-1-13_16:00 _index? uid=123

---1.txt

awk '{arr[$3]++; if(arr[$3] == 1){print $3}}' 1.txt
```



##### 1.2.6  使用awk数组作次数统计

```shell
liuxiang
luyanli
liuxiang
luyanli
heguangzi
luyanli
liuxiang
luyanli
heguangzi
luyanli
luyanli
liuxiang
luyanli
heguangzi
luyanli
liuxiang
luyanli
heguangzi
liuxiang
luyanli
heguangzi
luyanli
liuxiang
luyanli
heguangzi
luyanli
luyanli
liuxiang
luyanli
heguangzi
luyanli
------1.txt

awk '{arr[$0]++}END{for(i in arr){print arr[i], i}}' 1.txt
```



##### 1.2.7 统计tcp连接状态数量

```shell
[root@localhost ~]# netstat -natp
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      994/sshd            
tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      1179/master         
tcp        0     36 192.168.36.131:22       192.168.36.1:50719      ESTABLISHED 10210/sshd: root@pt 
tcp6       0      0 :::22                   :::*                    LISTEN      994/sshd            
tcp6       0      0 :::8888                 :::*                    LISTEN      1505/java           
tcp6       0      0 ::1:25                  :::*                    LISTEN      1179/master         
tcp6       0      0 :::37353                :::*                    LISTEN      1505/java           
tcp6       0      0 192.168.36.131:37353    192.168.36.161:50744    ESTABLISHED 1505/java           
tcp6       0      0 192.168.36.131:37353    192.168.36.160:36830    ESTABLISHED 1505/java

netstat -tnap | awk '$1 ~/^tcp/ {arr[$6]++}END{for(i in arr){print i,"---", arr[i]}}'
```



##### 1.2.8 统计日志中状态码不是200的ip数量

```shell
172.16.8.11 - - [19/Sep/2018:12:35:21 +0800] "GET /console/stat/onlineVisitorRefresh HTTP/1.1" 200 7613
172.16.8.1 - - [19/Sep/2018:12:43:08 +0800] "GET /images/loading.gif HTTP/1.1" 200 404
172.16.8.1 - - [19/Sep/2018:12:43:08 +0800] "POST /init HTTP/1.1" 200 207
172.16.8.1 - - [19/Sep/2018:12:43:12 +0800] "POST /init HTTP/1.1" 200 207
172.16.8.1 - - [19/Sep/2018:12:43:16 +0800] "GET / HTTP/1.1" 200 7612
172.16.8.1 - - [19/Sep/2018:12:43:16 +0800] "GET /css/default-init.css?1537325099834 HTTP/1.1" 304 -
172.16.8.1 - - [19/Sep/2018:12:43:16 +0800] "GET /js/lib/jquery/jquery.min.js HTTP/1.1" 304 -
172.16.8.1 - - [19/Sep/2018:12:43:16 +0800] "GET /images/logo.png HTTP/1.1" 304 -
172.16.8.11 - - [19/Sep/2018:12:45:21 +0800] "GET /console/stat/onlineVisitorRefresh HTTP/1.1" 200 7612
172.16.8.11 - - [19/Sep/2018:12:55:21 +0800] "GET /console/stat/onlineVisitorRefresh HTTP/1.1" 200 7612
172.16.8.11 - - [19/Sep/2018:13:05:21 +0800] "GET /console/stat/onlineVisitorRefresh HTTP/1.1" 200 7612
172.16.8.11 - - [19/Sep/2018:13:15:21 +0800] "GET /console/stat/onlineVisitorRefresh HTTP/1.1" 200 7613
172.16.8.11 - - [19/Sep/2018:13:25:21 +0800] "GET /console/stat/onlineVisitorRefresh HTTP/1.1" 200 7613
172.16.8.11 - - [19/Sep/2018:13:35:21 +0800] "GET /console/stat/onlineVisitorRefresh HTTP/1.1" 200 7613
172.16.8.11 - - [19/Sep/2018:13:45:21 +0800] "GET /console/stat/onlineVisitorRefresh HTTP/1.1" 200 7613
172.16.8.11 - - [19/Sep/2018:13:55:21 +0800] "GET /console/stat/onlineVisitorRefresh HTTP/1.1" 200 7612
172.16.8.11 - - [19/Sep/2018:14:05:21 +0800] "GET /console/stat/onlineVisitorRefresh HTTP/1.1" 200 7612
172.16.8.11 - - [19/Sep/2018:14:15:21 +0800] "GET /console/stat/onlineVisitorRefresh HTTP/1.1" 200 7612
172.16.8.11 - - [19/Sep/2018:14:25:21 +0800] "GET /console/stat/onlineVisitorRefresh HTTP/1.1" 200 7612
172.16.8.11 - - [19/Sep/2018:14:35:21 +0800] "GET /console/stat/onlineVisitorRefresh HTTP/1.1" 200 7612
172.16.8.11 - - [19/Sep/2018:14:45:21 +0800] "GET /console/stat/onlineVisitorRefresh HTTP/1.1" 200 7613
----1.txt

awk '!($9 ~ /^200/) {arr[$1]++} END{for(i in arr){print arr[i],i}}' 1.txt

awk '$9 != 200 {arr[$1]++} END{for(i in arr){print arr[i],i}}' 1.txt

awk '$9 != 200 {arr[$1]++} END{for(i in arr){print arr[i],i}}' 1.txt | sort -k1nr | head -n 10
```



##### 1.2.9  根据多条件统计独立ip的次数并统计到文件中

统计每个URL的独立访问ip有多少个(去重)，并且为每一个URL保存一个对应的文件

```shell
a.com.cn|202.109.134.23|2015-11-20 20:34:43|guest
b.com.cn|202.109.134.23|2015-11-20 20:34:48|guest
c.com.cn|202.109.134.24|2015-11-20 20:34:48|guest
a.com.cn|202.109.134.23|2015-11-20 20:34:43|guest
a.com.cn|202.109.134.24|2015-11-20 20:34:43|guest
b.com.cn|202.109.134.26|2015-11-20 20:34:48|guest
------ 1.txt

awk中数组全是关联数组，他的索引全是字符串，arr[1] 等价于 arr["1"]  arr[arr],对于俩个字符串连接的情况 arr[str1""str2],awk提供了另外一种方式,可以使用,将俩个字符串隔开arr[str1,str2],在awk的语法当中，这个“,”，被当作\034，是一个SUBSEP.

1.awk
BEGIN{
	FS="|"
}
{
	if(!arr[$1,$2]++){
		arr1[$1]++
	}
}
END{
	for(i in arr1){
		print i,arr1[i] > (i".txt")  
	}
}

awk -f 1.awk 1.txt
```



##### 1.2.10  处理字段中缺失的数据

```txt
ID   name    gender    email            phone
1    Bob     male      abc@qq.com       17372941147
2    Limei   female                     17551938857
3    Han     male      han@126.com      15785417862
4    Tony              t123@huawei.com  17935848835

gawk	带的功能
关键字：FIELDWIDTHS	
FIELDWIDTH="2 3:5 4:15 2:11"
第一列 id显示的


```



##### 1.2.11  处理的字段中包含了字段分隔符的数据

```shell

```



##### 1.2.12  去字段中指定字符数量

##### 1.2.13  行列转换

##### 1.2.14  筛选指定时间范围内的日志

##### 1.2.15  去掉/**/中间的日志

##### 1.2.16  前后段落关系判断

##### 1.2.17  俩个文件的处理

### 二、grep的用法

### 三、sed的用法

### 四、 shell中的语法

#### 4.1 if判断中[[]]和[]的区别

1. [ -z "$pid" ] 单对中括号变量必须要加双引号，[[ -z $pid ]] 双对括号，变量不用加双引号

   ```shell
   [ -z "$pid" ]  ========  [[ -z $pid ]]
   ```

   

2. [[ ]] 条件判断 可以用 && 、|| 连接，是不能使用 -a 或者 -o的参数进行比较的

   ```shell
   #符合要求
   [[ 5 -lt 3 || 3 -gt 6 ]]   ==========   [[ 5 -lt 3 ]] || [[3 -gt 6 ]
   #不符合要求
   [[ 5 -lt 3]] -o [[ 3 -gt 6 ]] [[ 5 -lt 3 -o 3 -gt 6 ]]
   [[ 5 -lt 3 -a 3 -gt 6 ]] [[ 5 -lt 3 -a 3 -gt 6 ]]
   ```

   

3. [ ] 可以使用 -a -o的参数，但是必须在 [ ] 中括号内，如果想在中括号外判断两个条件，必须用&& 和 || 比较，相对的，|| 和 && 不能在中括号内使用，只能在中括号外使用

   ```shell
   #符合要求
   [ 5 -lt 3 -o 3 -gt 2 ]  ======  [5 -lt 3 ] || [ 3 -gt 2]
   #不符合要求
   [5 -lt 3 ] -o [ 3 -gt 2]      [5 -lt 3  ||  3 -gt 2]
   ```

   

4. 当判断某个变量的值是否满足正则表达式的时候，必须使用[[ ]] 双对中括号

   ```shell
   [[ $param=~[0-9]{11} ]]
   ```

   

