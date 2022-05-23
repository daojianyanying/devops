# python中使用过的第三方库

## 一、APScheduler

### 1.1、功能

python的定时执行和循环执行的功能。核心模块可以分为：

- 触发器

- 作业存储

- 调度器

- 执行器

  

### 1.2、调度器-schedule

调度器是将触发器、执行器、作业存储集合在一起，通过调度器完成任务的存储、触发、执行

主要是俩个调度器:

- BlockingScheduler: 会阻塞进程，只有当业务只是为了做定时调用是才用。
- BackgroundScheduler：后台执行，不会阻塞主进程的执行。

```python
from apscheduler.schedulers.blocking import BlockingScheduler
sched = BlockingScheduler()


from apscheduler.schedulers.background import BackgroundScheduler
sched = BackgroundScheduler()

```

其余的调度器可以在使用的时候做具体的了解

AsyncIOScheduler：适合于使用asyncio框架的情况

GeventScheduler: 适合于使用gevent框架的情况

TornadoScheduler: 适合于使用Tornado框架的应用

TwistedScheduler: 适合使用Twisted框架的应用

QtScheduler: 适合使用QT的情况



### 1.3 调度器（Trigger）

APScheduler的调度器总共3类，date、interval、cron

#### 1.3.1 、定时调度

定时调度只会执行1次，也是默认的执行器

```python
sched.add(job_def_name, 'date')
sched.add(job_def_name)
+++++++++++++++

dateTrigger = DateTrigger(datetime.now() + datetime.timedelta(seconds=120))
sched.add(job_def_name, 'date', dateTrigger, args=['text'])

+++++++++++++++++++++++++
sched.add(job_def_name, 'date', date(2022,11,9), args=['text'])
sched.add(job_def_name, 'date', datetime(2022,11,9,16,5,1), args=['text'])
```



# 二、Django

2.1、功能

2.2、