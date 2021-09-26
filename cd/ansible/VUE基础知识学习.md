# Vue基础知识学习

### 一、基础大框架

Soc：

​	HTML+CSS+JS: 视图 ： 给用户看，刷新后台的数据



网络通信：axios

页面跳转: vue-router

状态管理：vuex

Vue-UI: Ant-Design、ElementUI、 iview、ice、 Bootstrap、 AmazeUI

webpack: 模块打包器



三端统一开发(PC、安卓、ios)：

后端技术：NPM相当于maven



### 二、 第一个Vue程序

idea安装vue插件

### 三、Vue常用的7个属性

### 四、Vue的基础语法

##### 4.3 Vue的双向绑定

​	Vue.js是一个 MVVM框架，即数据双向绑定，即当数据发生变化时，视图就会发生变化，当视图发生变化时，数据也会同步变化。数据的双向绑定是对于UI控件来说的，非UI控件不会涉及到数据的双向绑定。单向数据绑定是使用状态管理器的前提。因此，如果使用vuex，那么数据流就是单向的，这时就会和双向数据绑定有冲突。

​	

##### 4.4 Vue组件

定义一个vue组件

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<!--view层-->
<div id="app">
    {{message}}
    <span v-bind:title="message">鼠标悬停几秒查看此处动态绑定的提示信息！！</span>
</div>
<!--导入vue.js-->
<script src="https://cdn.jsdelivr.net/npm/vue@2.5.21/dist/vue.min.js"></script>
<script>
    var vm = new Vue({
        el: "#app",
        <!--model层：数据-->
        data: {
            message: "hello vue!!!"
        }
    });

</script>
<body>

</body>
</html>
```



##### 4.5 Vue的网络通信--Axios异步通信

前提：js要用ES6，不能用ES5

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <!--解决clock闪烁问题-->
    <style>
        [v-clock]{
            display: none;
        }
    </style>
</head>
<body>
<div id="vue" v-clock>
    <div>{{info.name}}</div>
    <div>{{info.address.city}}</div>
    <a v-bind:href="info.url">跳转</a>
</div>

<!--引入js文件-->
<script src="https://cdn.jsdelivr.net/npm/vue@2.5.21/dist/vue.min.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script type=text/javascript>
    var vm = new Vue({
        el: '#vue',
        data(){
            return{
                info: {
                    //请求的返回参数，必须和Json字符串一样
                    name: null,
                    address: {
                        street: null,
                        city: null,
                        country: null
                    },
                    url: null
                }
            }
        },
        mounted(){//钩子函数 ES6的新特性
            //链式编程
            axios.get('data.json').then(response=>(this.info=response.data))
        }
    });
</script>
</body>

</html>
```



```json
{
  "name": "狂神说java",
  "url": "http://baidu.com",
  "page": "1",
  "isNonProfit": "true",
  "address": {
    "street": "含光门",
    "city": "陕西西安",
    "country": "中国"
  },
  "links": [
    {
      "name": "B站",
      "url": "https://www.bilibili.com/"
    },
    {
    "name": "4399",
    "url": "https://www.4399.com/"
    },
    {
      "name": "百度",
      "url": "https://www.baidu.com/"
    }
  ]
}
```



##### 4.6 Vue对象的生命周期



##### 4.7 计算属性

​	Vue能够将计算属性，并将结果结果缓存起来，他是在内存中运行:虚拟DOMN

​	作用：将不经常变化的计算结果缓存起来，以节约系统的开销

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<!--view层-->
<div id="app">
    <!--调用方法必须加上（）-->
    <p>currentTime----{{currentTime1()}}</p>
    <!--调用计算属性中的方法-->
    <p>currentTime_计算属性{{currentTime2}}</p>
</div>
<!--导入vue.js-->
<script src="https://cdn.jsdelivr.net/npm/vue@2.5.21/dist/vue.min.js"></script>
<script>
    var vm = new Vue({
        el: "#app",
        //计算属性
        data: {
            messages: "hello Vue"
        },
        methods: {
            currentTime1: function (){
                return Date.now();
            }
        },
        //计算属性,不要和Methods中的方法重名，重名后优先适应methods中的方法
        computed: {
            currentTime2: function (){
                return Date.now();
            }
        }
    });

</script>
<body>

</body>
</html>
```



##### 4.8 slot元素

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<!--view层-->
<div id="app">
    <todo>
        <todo-title slot="todo-title" :title="title"></todo-title>
        <todo-items slot="todo-title" v-for="item in todoItems" :item="item"></todo-items>
    </todo>
</div>
<!--导入vue.js-->
<script src="https://cdn.jsdelivr.net/npm/vue@2.5.21/dist/vue.min.js"></script>
<script>
    //组件中定义插槽
    Vue.component("todo",{
        template:   '<div>\
                        <slot name="todo-title"></slot>\
                        <ul>\
                            <slot name="todo-items"></slot>\
                        </ul>\
                    </div>'
    });

    Vue.component("todo-title",{
        props: ['title'],
        template: '<div>{{title}}</div>'
    });

    Vue.component("todo-items",{
        props: ['item'],
        template: '<li>{{item}}</li>'
    });

    var vm = new Vue({
        el: "#app",
        //计算属性
        data: {
            title: "devops之路",
            todoItems: ["java", "C++", "python", "shell"]
        },
        methods: {
            currentTime1: function (){
                return Date.now();
            }
        },
        //计算属性,不要和Methods中的方法重名，重名后优先适应methods中的方法
        computed: {
            currentTime2: function (){
                return Date.now();
            }
        }
    });

</script>
<body>

</body>
</html>
```



##### 4.9 自定义事件内容分发

this.$emit('自定义事件名'，参数)



### 五、 Vue的使用——Vue的第一个项目

### 六、 Webpack学习

​	定义：Webpack是一个现代的js应用程序的静态模块打包器。当webpack处理程序时，它会递归地的构建一个依赖关系图，其中包含程序需要的每一个模块，然后将所有这些模块打包成一个或多个bundle。

### 七、 Vue-router路由

