# jelly的基础

jelly官网：http://commons.apache.org/proper/commons-jelly/



##### 零、 Jelly概述

​	Jelly是一个将XML转换为可执行代码的工具。所以Jelly是一个基于Java和XML的脚本和处理引擎。Jelly可以作为Ant的一个更加灵活和强大的前端，比如在Maven项目中，作为测试框架（比如jellunit），在集成或工作流系统（比如werkflow）中，或者作为Cocoon等引擎中的页面模板系统。

​	Jelly借鉴了JSP自定义标记、Velocity、Cocoon和Ant的许多好主意。Jelly可以从命令行、Ant和Maven内部使用，也可以在Servlet、Web服务、JMS MessageListener内部使用，或者直接嵌入到软件中。

​	Jelly本机支持类似于Velocity的表达式语言Jexl，Jexl是JSP、JSTL和JSF表达式语言的超集，还支持其他可插入的表达式语言，如通过Jaxen、JavaScript、beanshell和Jython实现的XPath。

​	Jelly完全可以通过自定义标记进行扩展，其方式与JSP自定义标记或Ant任务类似。尽管Jelly非常简单，既没有servlet也没有JSP依赖关系。因此，您可以将Jelly视为类似于XML的，其中指令是XML标记。或者，您可以将Jelly看作是一个更灵活的引擎，用于处理具有更好的表达式、逻辑和循环支持的Ant任务。

​	jelly还基于XML管道体系结构，如Cocoon，因此它非常适合处理XML、编写web服务脚本、生成动态web内容或作为Cocoon等内容生成系统的一部分。



```xml
<j:jelly xmlns:j="jelly:core" xmlns:st="jelly:stapler" xmlns:d="jelly:define" xmlns:l="/lib/layout" xmlns:t="/lib/hudson" xmlns:f="/lib/form">
    ${it.myString}
</j:jelly>
```



##### 一、 jelly的国际化

​	properties文件默认编码为ISO-8859-1，静态资源文件编码为UTF-8，因此这之前涉及编码的转换

​	书写properties的中文时，需要用unicode码

​	Messages类

​	Jenkins使用Localizer（https://java.net/projects/localizer/）生成Messages类，能够以类型安全的方式访问Message资源。src/main/resources/**/Messages.properties匹配的所以文件都会生成一个对应的Messages类。如过IDE找不到这些类，需要手动将target/generated-sources/localizer目录加入源码的根目录。返回用于显示的字符串的代码（如Descriptor.getDisplayName()）可以使用Messages类获取本地化的消息。在运行时，适当的locale会被自动选择。

　　典型的工作流如下：

1. 确定需要本地化的messages
2. 将消息写入MEssages.properties文件。即可以为每个package编写一个，也可以整个module/plugin只用一个。
3. 运行 mvn compile，生成Messages.java
4. 更新代码，使用最新生成的消息格式方法。

　　如果消息中包含单引号(')，需要再用一个单引号昨晚转义('')。如果想使用英文撇号(’)，可以用unicode字符 U+2019，在properties文件中写成\u2019。

##### 三、 jenkins在linux上安装的目录

- [ ]  jenkins安装目录：/usr/lib/jenkins/

- [ ] jenkins的配置文件目录： /etc/sysconfig/jenkins

- [ ] jenkins_home目录：/var/lib/jenkins/

- [ ] jenkins日志文件目录：/var/log/jenkins/jenkins.log

- [ ] 一般使用端口：8080-8081 8880 8888 8848 、

- [ ] ```tex
  docker run -p 8880:8080 -p 50000:50000 jenkins
  
  docker run -p 8080:8080 -p 50000:50000 -v /your/home:/var/jenkins_home jenkins
  ```



##### 四、jenkis插件开发

​	业务逻辑代码一般放在perform方法中,

```java
package com.common.people;

import edu.umd.cs.findbugs.annotations.NonNull;
import hudson.*;
import hudson.model.AbstractProject;
import hudson.model.Run;
import hudson.model.TaskListener;
import hudson.tasks.BuildStepDescriptor;
import hudson.tasks.Builder;
import hudson.util.FormValidation;
import jenkins.tasks.SimpleBuildStep;
import org.kohsuke.stapler.DataBoundConstructor;
import org.kohsuke.stapler.QueryParameter;

import java.io.IOException;
import java.nio.charset.Charset;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CheckSnapShotBuilder extends Builder implements SimpleBuildStep {
    
    private final String pomXmlPath;
    private final String buildType;
    private final boolean createDependencyTree;
	
    //从jelly获取对应的属性值
    @DataBoundConstructor
    public CheckSnapShotBuilder(String pomXmlPath, String buildType, boolean createDependencyTree) {
        this.pomXmlPath = pomXmlPath;
        this.buildType = buildType;
        this.createDependencyTree = createDependencyTree;
    }

    @Override
    public void perform(@NonNull Run<?, ?> run, @NonNull FilePath workspace, @NonNull EnvVars env, @NonNull Launcher launcher, @NonNull TaskListener listener) throws InterruptedException, IOException {
        listener.getLogger().println("打印某某日志");
        listener._error("pom-error","erroradadwdadsa");
        //listener.annotate(new Co);
        listener.error("aaaaaaa");
        Charset charset = listener.getCharset();
        System.out.println(charset);
        listener.hyperlink("https://www.baidu.com/","aaaa");
    }
	
    
    @Extension
    public static final class DescriptorImpl extends BuildStepDescriptor<Builder> {

        public FormValidation doCheckPomXmlPath(@QueryParameter String value){
            if(value.length() == 0){
                return FormValidation.error("the path can not be empty!");
            }
            return FormValidation.ok();
        }

        public FormValidation doCheckBuildType(@QueryParameter String value){
            if(value.length() == 0){
                return FormValidation.error("the type can be maven or gradle!");
            }
            return FormValidation.ok();
        }

        public FormValidation doCheckCreateDependencyTree(@QueryParameter String value){
            if(value.equals(null)){
                return FormValidation.error("if you do not choose, default choose not create!");
            }
            return FormValidation.ok();
        }

        @Override
        public boolean isApplicable(Class<? extends AbstractProject> aClass) {
            return true;
        }

        @Override
        public String getDisplayName() {
            return "CheckSnapshot";
        }
    }
}

```

jenkin的日志是在perform的方法中的TaskListener listener中实现，使用listener.getLogger().println("日志")、listener.error()、











##### 五、包含Descriptor的对象中Jelly的使用

1.在类中增加一个构造函数，将所有需要的配置作为构造函数的参数。并且在构造函数上增加`@DataBoundConstructor`注解，来告诉Jenkins进行实例化。

```java
public class MyRecorder extends Recorder {
    private final String url;
    private final String info;
 
    // Fields in config.jelly must names in "DataBoundConstructor"
    @DataBoundConstructor
    public HelloWorldBuilder(String url,String info) {
        this.url = url;
        this.info = info;
    }
}
```

2.在类中增加getter方法，或者将变量设置为`public final`。这样可以让Jelly脚本将数值显示到配置信息页面。

```java

//We'll use this from the <tt>config.jelly</tt>.
public String getUrl() {
    return url;
}
public String getInfo() {
    return info;

```

3.在config.jelly中增加Jelly代码来显示配置选项。

```html
<j:jelly xmlns:j="jelly:core" xmlns:st="jelly:stapler" xmlns:d="jelly:define" xmlns:l="/lib/layout" xmlns:t="/lib/hudson" xmlns:f="/lib/form">
 
   <f:entry title="请求地址" field="url">
        <f:textbox />
   </f:entry>
   <f:entry title="项目所需变量" field="info">
        <f:textbox />
  </f:entry>
</j:jelly
```

4.帮助文件

对控件需要增加帮助信息，可以在文件中包含名称为`help-FIELD.html`或者`help-FIELD.jelly`的帮助文档。你也可以增加顶级的帮助文档`help.html`。增加了帮助文档，会在控件的右边显示一个问号，点击能够显示提示信息。

```html
  <f:section title="My Plugin">
    <f:entry title="${%Port}" help="help-port.html">
      <f:textbox name="port" value="${it.port}"/>
    </f:entry>
  </f:section> 
```

5.配置信息检查
在内部实现的DescriptorImpl类中，增加doCheckFIELD()函数，来进行配置信息的检查。在参数上可以增加@QueryParameter注解来传入附近位置的数据。

```java
public FormValidation doCheckUrl(@QueryParameter("url") String value)
            throws IOException, ServletException {
        if (value.length() == 0)
            return FormValidation.error("Please set the url");
 
        return FormValidation.ok();
    }
```

6.Jelly页面的默认值 如果希望配置页面上增加初始化值，可以使用@default注解：第一个default使用了固定值，第二个default使用了计算出来的数值作为初始化参数。

```html
<j:jelly xmlns:j="jelly:core" xmlns:f="/lib/form">
  <f:entry title="${%Port}" field="port">
    <f:textbox default="80" />
  </f:entry>
  <f:entry title="${%Host}" field="host">
    <f:textbox default="${descriptor.defaultHost()}/>
  </f:entry>
</j:jelly>
```

7. get 方法决定这你配置的参数会不会保存
8.  jenkins的版本，要和你安装的目的的jenkins的版本一致

##### 六、 无Descriptor的对象（如ComputerListener）

参考插件：https://github.com/jenkinsci/sidebar-link-plugin

如果插件用了无Descriptor的对象，如ComputerListener。可以按下面的步骤，在配置页面中增加一个插件类（Plugin的子类）可读取的文本框。

1. 重写 plugin类的configure(StaplerRequest req, JSONObject formData)方法。这个方法会在用户点击配置页面的保存按钮是被调用。

2. 在configure方法里，调用formData的提取数据方法获取配置值，如optInt("port",3141)，将获取的数据保存在Plugin类的成员字段中。

3. 在configure方法里，调用save()方法，将plugin类的可序列化字段持久化存储。

4. 在plugin类的start方法中，调用load()，插件启动时重新加载持久化存储的数据。

5. 在与plugin类对应的位置(src/main/resources/path/to/plugin/className/config.jelly)创建config.jelly文件，编写配置页面视图。在插件类的config.jelly中，**用变量it代替变量instance**，it.port可以引用当前使用的port参数值。help属性使用创建插件时pom.xml中指定的artifactId引用插件的资源。

   ```html
   <j:jelly xmlns:j="jelly:core" xmlns:st="jelly:stapler" xmlns:d="jelly:define" xmlns:l="/lib/layout"
            xmlns:t="/lib/hudson" xmlns:f="/lib/form">
     <f:section title="My Plugin">
       <f:entry title="${%Port}" help="/plugin/ARTIFACT_ID_GOES_HERE/help-projectConfig.html">
         <f:textbox name="port" value="${it.port}"/>
       </f:entry>
     </f:section>
   </j:jelly>
   ```

6. 在src/main/webapp中创建help文件help-projectConfig.html。

7. 正常启动Jenkins(mvn hpi:run)，查看效果。

   ##### 七、 

   

