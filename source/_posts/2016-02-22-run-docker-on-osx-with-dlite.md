title: Simplifying Docker on OS X With Dlite
date: 2016-02-22 22:58:21
tags:
- docker
- dlite
---


*前方高能提醒*：如果你的系统小于 OS X Yosemite (10.10.3)，且不准备升级到符合条件的版本，就不用往下看了。

## Dlite 是什么？

早在2013年底，笔者实习的时候就开始玩 docker，只是那时 docker 还是 dotCloud(现已卖掉，改名为 Docker.Inc)员工的业余项目，还很不成熟。转眼间到了2016年，又准备重新捡起来。

使用 Mac OSX 系统的同学应该都知道，docker 是没有原生支持 OS X 系统的，要么通过 [boot2docker](https://github.com/boot2docker/boot2docker), 要么通过 [docker-machine](https://docs.docker.com/machine/)， 二者有个共同点：依赖 VM（如 virtualbox）来运行一个 linux 虚拟机， 然后虚拟机跑着 docker daemon。然而 virtualbox 并不是个轻量级的虚拟化方案，对于我这种使用乞丐版 MBP的人来说，不太方便。用着15寸高配 Macbook Pro 的土豪请随意 :)

今天我们要介绍的主角是：[Dlite](https://github.com/nlf/dlite)。Dlite 是什么呢? 这里直接引用 Dlite 项目文档的介绍：

> DLite leverages xhyve through the libxhyve Go bindings for virtualization.

大意是： 得益于 [xhyve](https://github.com/mist64/xhyve) 和基于go封装后的 [libxhyve](https://github.com/TheNewNormal/libxhyve) 两个项目才有了 Dlite 的诞生（妹子帮我译的 😄）。

xhyve, 是 OSX 下一种轻量级的虚拟化解决方案，建立在 OSX 10.10 Yosemite 的 Hypervisor.framework 之上，完全运行在用户空间内，没有其他任何依赖。它可以运行 FreeBSD 系统和 使用 Linux 内核的发行版。其实 xhyve 是 bhyve 的 OS X 移植版本。而bhyve ，即 BSD hypervisor，是在 FreeBSD 上开发的虚拟机管理器（hypervisor/virtual machine manager）。

那么 Dlite 是什么呢？ 聪明的读者应该想到：既然有了xhyve 这个虚拟化解决方案，肯定还得需要一个 linux 虚拟机来运行 docker。这个 linux 发行版是 DhyveOS, 是 Dlite 作者为了此项目创建的一个超轻量级 Linux OS：[DhyveOS](https://github.com/nlf/dhyve-os)。 

即 `Dlite = xhyve + DhyveOS`

Dlite 通过 libxhyve 来调用xhyve，然后xhyve运行着 DhyveOS， DhyveOS 运行着 docker。 对于 Mac 用户来说，只需要安装 Dlite，就可以拥有 docker。

 
## 如何安装 Dlite

有三种方式安装Dlite：
1. 在 Dlite 的 Release 页面直接下载可执行文件；
2. 通过 Homebrew 安装：brew install dlite3. 
3. 因为 Dlite 是 Go 写的，可以直接 go get github.com/nlf/dlite， 然后 make dlite 

其作者推荐使用 homebrew 方式安装 Dlite。

## 如何使用 Dlite

只需要运行 sudo dlite install， dlite 会自动帮你创建需要的文件，然后启动一个 agent 来管理这个进程。

你可以通过 sudo dlite install --help 来查看其它选项，如指定CPU 的个数，磁盘大小，内存等等。

其实 install 这个过程做了四件事情：

1. 创建一个固定大小的空文件 `disk.img`（默认是20GB）来作为DhyveOS虚拟机的磁盘空间；
2. 下载构建DhyveOS 所需的两个文件， `bzImage` 和 `rootfs.cpio.xz`（DhyveOS 的 release 页面提供了这两个文件）
3. 创建配置文件，如没有指定则使用默认配置，
样例：

    ```
    {"uuid":"d93a1a37-d47c-11e5-92af-60f81da97a72","cpu_count":1,"memory":2,"hostname":"local.docker","share":"/Users"}%
    ```

4. 创建 launchd agent

上述操作创建的文件都可以在 `~/.dlite`目录找到。


启动/关闭 DhyveOS（当然也包括启动/关闭了 docker 服务）只分别需要执行：

    dlite start 
    dlite stop

即可。

启动 DhyveOS 后就可以使用 Docker 服务啦。如果需要 SSH 登录到虚拟机里面，可以 `ssh docker@local.docker` 。 Dlite 会自动添加 `local.docker` 到 OS X 的 hosts 文件内。如果没有找到该记录，应该通过 IP 方式来登录， 运行 dlite ip 可以获取虚拟机的 IP。

关于DhyveOS 你需要知道的是：

1. /Users 目录会自动挂载到虚拟机上
2. root 用户的缺省密码是： dhyve
3. docker 用户的缺省密码是： docker
4. dlite 会默认将 $HOME/.ssh/id_rsa.pub 复制到DhyveOS，SSH 登录免密码。

如果需要更新 VM, 只需要执行下述命令（不会重新构建系统）：

    dlite stop
    dlite update
    dlite start
    
    
由于docker 是个 C/S 模型的应用，可以直接在 OS X 这一层来使用 docker 客户端，就不用登录到 DhyveOS 里面再使用 docker 这么麻烦啦，前提是你已经在 OS X 系统安装了 docker 客户端（注: docker 的 client 和 server 都在同一个二进制文件内）。

## Dlite 的不足

由于 Dlite 是建立在 xhyve 之上，其不足也会与 dlite 相随。
即 OS X系统版本需要在 `10.10.3` 以上，还需要比较新的配置（需要是近几年的 Mac 硬件，黑苹果估计不行吧）。可以通过 `sysctl kern.hv_support` 来确认是否满足要求。如果看到 `kern.hv_support: 1` 返回，那就是满足咯。

## 其他

如果你需要给 docker 配置加速器（赵国的网络你懂的），你需要知道 dlite 下的docker 服务是如何启动的。docker 启动参数位于 DhyveOS 虚拟机系统的 `/etc/default/docker`

```
docker@dlite:~$ cat /etc/default/docker
DOCKER_ARGS="-H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 -s btrfs --registry-mirror=http://yours.m.daocloud.io"
```


## 总结
刚接触 dlite 不久，暂时还没遇到什么大坑，用起来还是蛮方便的，值得推荐！如果读者在使用过程遇到问题，欢迎留言探讨，共同学习提高 😄


references:
1. [Simplifying Docker on OS X](https://blog.andyet.com/2016/01/25/easy-docker-on-osx/)











