

# PowerShell的学习

### 一些基础的命令(cmdlet)

- get-childitem
- set-location  c:\
- clear-host: c
- get-alias=gal



帮助系统的使用

### 一、power的基础变量

##### 定义方式： $name=“变量值”

案例：${"i am a" var()}="hahaha"

​			$n=7*9-4

​			$number1=$number2=34

##### 变量交换：

​			$num1=11

​			$num2=12

​			$num1,$num2=$num2,num1

##### 查看当前变量：

​			ls variable:

​			del variable:变量名      --删除一个变量

​			clear-variable

​			test-path variable:变量名

##### 自动化变量(内置变量)：

​			powershell窗口一打开就会自动加载的变量

​			$home    --当前目录

​			$pid

​			$$  ----上一个命令

​			$?  ---上一个命令的运行结果

##### powersell的环境变量(双冒号的用法)

​			ls env：

​			$env:变量名

​			del env:变量名

​			ls erv:变量名

​			$env:变量名=变量值    --更该环境变量值，只是临时生效

​			[environment] :: setenvironmentvariable("PATH" ,"D:\", "User") ： 修改环境变量，只对当前用户生效

​			



二、 powershell的脚本

2.1 脚本运行策略

​	获取powershell的运行策略： get-executionpolicy

​	设置powershell的运行策略： set-executionpolicy  策略方式

​		set-ExecutionPolicy RemoteSigned  -------可以让powershell调用powershell脚本

​	策略方式：

​		

2.2 powershell和其他脚本的互相调用

​	powershell调用bat、vbs、powershell脚本:  进入目录 ./运行，直接把脚本拖进powershell的窗口内

  bat中执行powershell脚本：

​	powershell  "&‘ powershell脚本的路径’ "

​	

2.3 powershell的条件操作符

​	

### 附、其它杂学

##### f.1 设置powershell脚本的失败停止和命令的失败停止

​	**$ErrorActionPreference**和**$ErrorAction**都具有相同的功能，并且都通过将“**非**终止错误”转换**为“终止**错误”来处理**终止**错误。但是，当同时使用两个变量时，我们需要知道哪个优先。

​	**$ErrorActionPreference**变量在脚本开始时使用，而**$erroraction**变量是公共参数并与cmdlet一起使用。在某些情况下，我们可能需要在发生错误后立即终止脚本，但是在脚本内部，我们有一些cmdlet，如果发生错误，则需要忽略或继续执行这些cmdlet。在这种情况下，我们**-ErrorAction**很重要，并且它具有优先权。

​	在下面的示例中，脚本终止，因为**ABC**服务名称不存在，并且由于该原因，由于**$ErrorActionPreference**值设置为**Stop**，因此下**一条**命令无法执行。一旦在**Get-Service**命令中添加**-ErrorAction**，它将具有优先权。

```powershell
$ErrorActionPreference = "Stop"
try{
   Get-Service -Name ABC
   Get-Process powershell
   Get-Process chromesds
   Get-Service Spooler
}
catch{
   $_.Exception.Message
}

Cannot find any service with service name 'ABC'.
```

```powershell
$ErrorActionPreference = "Stop"
try{
   Get-Service -Name ABC -ErrorAction Continue
   Get-Process powershell
   Get-Process chromesds
   Get-Service Spooler
}
catch{
   $_.Exception.Message
}

结果：
Line |
   4 |       Get-Service -Name ABC -ErrorAction Continue
     |       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | Cannot find any service with service name 'ABC'.
NPM(K)    PM(M)    WS(M)    CPU(s)    Id    SI    ProcessName
------    -----    -----    ------    --    --    -----------
43       234.39    11.33    49.17    7668    1    powershell
Cannot find a process with the name "chromesds". Verify the process name and call
the cmdlet again.
```

