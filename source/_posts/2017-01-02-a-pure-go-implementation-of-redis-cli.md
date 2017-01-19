title: Go 语言实现的 redis-cli 
date: 2017-01-02 17:28:52
tags:
- redis 
- go 
---

## 为何造新轮子？

有时候，我想查下线上的 redis 数据，但是我不能直接在内网访问生产环境的机器，我只能通过跳板机登录上我拥有权限的机器，而我拥有权限（开发权限）的机器上并没有安装 redis-cli。这时候我只能请求运维同学帮我装一个，虽然对他们来说只是敲一条命令的事情， 但是每次都麻烦别人，不是很好，而且当你找别人的时候，别人不一定有空。为什么装完了，下次还得装呢？这涉及到我们的运维体系设计问题。开发可以申请自己负责的项目的机器权限，可以是永久权限，也可以是临时的权限，过期失效。因为微服务的原因，我手上的有权限的机器不少，但是我不记得哪台机器上有 redis-cli， 也许当初安装 redis-cli 的那台机器我只有临时权限，而且过期了，谁记得这么多呢！ 我只期望一点： 当我需要一个 redis-cli， 我能在很短时间内，自助快速安装一个。

装过 redis 的同学应该都知道，redis 是通过动态链接的方式引用了外部库的，也就是你一般是不可能直接拷贝一个编译好的 linux 二进制文件到另一台 linux 机器上直接执行的（这方面我不是特别了解，如果有误，请指出！）

```
$ ldd redis-cli
    linux-vdso.so.1 =>  (0x00007fffe93fe000)
    libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f17ff5f9000)
    libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f17ff3db000)
    libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f17ff015000)
    /lib64/ld-linux-x86-64.so.2 (0x00007f17ff919000)
```

上面提到需求， 我想自己安装一个 redis-cli，不需要运维的介入。 读者也许会问，为什么不直接去 github clone 一份，然后自己编译一个 redis-cli？ 
我也想这样啊，可是网速实在感人：

```
git clone https://github.com/antirez/redis.git
Initialized empty Git repository in /home/work/app/redis/.git/
remote: Counting objects: 45784, done.
remote: Compressing objects: 100% (92/92), done.
Receiving objects:   0% (62/45784), 20.01 KiB | 5 KiB/s

Receiving objects:   0% (291/45784), 84.01 KiB | 1 KiB/s

Receiving objects:   2% (1242/45784), 300.01 KiB | 7 KiB/s
```

所以，我只能自救了。

## 功能介绍

先甩个地址: https://github.com/holys/redis-cli 有兴趣的同学可以下载试试。

这个 `redis-cli` 是基于 `ledis-cli` 的，这是我的前同事 [@siddongtang](https://github.com/siddontang) 的 [ledisdb](https://github.com/siddontang/ledisdb) 的附属工具，我当时也贡献了几行代码。但是 ledis-cli 当时是为了适配 ledisdb 而作，只有很基础的 REPL 功能，连直接执行命令都不支持，当然也没有我非常喜欢的 raw output format 功能 和 monitor 功能。于是我自己改了下，使之表现尽量和官方的 redis-cli 一致。

目前的功能如下：

- 基本的 hostname, port, auth, db 选项支持，当然也支持 socket 的方式连接
- 支持 RESP (REdis Serialization Protocol) 协议，毕竟 ledisdb 是支持 RESP，所以这部分应该没啥问题。   
- REPL，即交互式执行命令
- 直接执行命令，非交互式
- monitor 命令支持，这个的原理就是你向 redis-server 发一个 monitor 命令，然后你可以不断地从 redis-server 读取命令输出
- raw 输出，对于 JSON 格式的数据比较友好。
- 最大亮点应该就是编译一次，随处运行（因为go编译程序的时候把 runtime 也编译进去了）

## 功能演示

```
$ ./redis-cli --help
Usage of ./redis-cli:
  -a string
        Password to use when connecting to the server
  -h string
        Server hostname (default "127.0.0.1")
  -n int
        Database number(default 0)
  -p int
        Server server port (default 6379)
  -raw
        Use raw formatting for replies
  -s string
        Server socket. (overwrites hostname and port)

Almost the same as the official redis-cli.

$ ./redis-cli
127.0.0.1:6379> get info
"{\"age\":1,\"name\":\"cdh\"}"

$ ./redis-cli --raw
127.0.0.1:6379> get info
{"age":1,"name":"cdh"}

$ ./redis-cli get info
"{\"age\":1,\"name\":\"cdh\"}"

$ ./redis-cli --raw get info
{"age":1,"name":"cdh"}

$ ./redis-cli monitor
OK
1483327130.764598 [0 127.0.0.1:61344] "PING"
1483327133.769646 [0 127.0.0.1:61344] "PING"
1483327136.768431 [0 127.0.0.1:61344] "PING"
1483327139.767084 [0 127.0.0.1:61344] "PING"
 ...

```


## 安装

可通过 `go-get` 的方式安装：

```
go get -u -v github.com/holys/redis-cli 
```

如果非 Go 用户又想体验下，可以在 [release](https://github.com/holys/redis-cli/releases) 页面下载事先编译好的可执行文件来玩玩。目前提供了
64位机器的 darwin, linux 和 windows 环境可执行文件。

## Contribution 

欢迎提 issue。 


感谢阅读。


