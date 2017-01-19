title: Web 版 redis-cli 折腾记
date: 2017-01-09 22:35:58
tags:
- redis
- gotty
- xterm
- hterm
---

## 缘起

最近整了个 Go 版 [redis-cli](http://holys.im/2017/01/02/a-pure-go-implementation-of-redis-cli/)， 完了之后给同事分享了下。TL 问能否整个 web 版的 redis-cli， 即在网页上命令行式地操作 redis。 回想起有个工具叫 [gotty](https://github.com/yudai/gotty), 能让命令行工具运行在网页上。 网页和后端通过 websocket 的方式实时通信，效果能媲美原生终端操作，非常赞。 至于 gotty 的实现原理，有时间我会单写一篇，这里不展开了。

## 折腾过程

如果是用 Gotty 来实现这个方案的话，那么只需要一条命令即可。

    $ gotty -w redis-cli 
    
`-w` 参数表示允许写操作。

但是仅仅这样是不够的。

当你打开浏览器，输入 `http://localhost:8080` (默认是8080端口)， 然后不断刷新当前页面。每次刷新页面，gotty 都会产生一个子进程来执行 redis-cli。而之前的 redis-cli 子进程没有机会再访问到了，但是一直在占用资源。

```
$ pstree 20722
-+= 20722 holys gotty -w redis-cli
 |--= 20773 holys redis-cli
 |--= 20808 holys redis-cli
 |--= 20810 holys redis-cli
 |--= 20811 holys redis-cli
 |--= 20822 holys redis-cli
 \--= 20828 holys redis-cli
```
 
如果没有限制，理论上会产生 N 多子进程，直至耗尽系统资源。基于这点考虑，我们需要限制客户端连接数，即 max-connections。 除此之外，我们还需要让每个客户端超时断开并结束子进程， 避免子进程一直“占坑不拉屎”，得到释放系统资源的目的。

但是！在我写此文的前几天， gotty 还不支持 timeout 功能，只支持了 max-connections 功能。于是我浏览了一遍它的 issues 和 pull requests ，发现别人也有[这个需求](https://github.com/yudai/gotty/issues/78), 而且还提交了 [pull request](https://github.com/yudai/gotty/pull/115)， 但是作者好像很忙，一直没有空处理。 这都是大半年的 PR 了。于是我按图索骥，用了那人的  [fork 版本](https://github.com/zyfdegh/gotty)。
 
有了这两个功能还不够。web 版 redis-cli 是作为一个守护进程一直运行在后台的，基本不会重启的。一般复杂点的业务都有不同的 redis 实例，也就是可能需要来回切换不同的 redis 实例。而且 web版 redis-cli 是作为一个公共工具存在的，连任何的 redis 实例都有可能。 原生的 redis-cli 没有提供在 [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop) 内切换 redis 实例的功能，于是我给我的轮子加了个 `CONNECT` 命令。

     CONNECT host port [auth]
     
`auth` 参数可选。 

效果如下：

```
$ ./redis-cli
127.0.0.1:6379> connect 127.0.0.1 6380
connected 127.0.0.1:6380 successfully
127.0.0.1:6380>
```

这样就满足切换 redis 实例的需求了。 其实我很早就渴望这个功能了。

我还锦上添花加了个 `MODE` 命令。 有时候用户可能需要默认的输出，也可能想换为 `raw` 输出。前面也提到了， web 版 redis-cli 是没有机会退出重来换参数的，所以得在 REPL 里面完成 mode 的切换。

这个命令使用方式如下：

    MODE [std|raw]

即 MODE std 或者 MODE raw. 

效果展示：

```
$ ./redis-cli
127.0.0.1:6379> set json '{"name": "chendahui"}'
OK
127.0.0.1:6379> get json
"{\"name\": \"chendahui\"}"
127.0.0.1:6379> mode raw
switch output mode successfully
127.0.0.1:6379> get json
{"name": "chendahui"}
127.0.0.1:6379>
```

是不是很方便呢？

搞完后，发现gotty 这玩意儿不支持中文输入，换点专业的说法就是，不支持 [CJK](https://www.google.co.jp/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&cad=rja&uact=8&ved=0ahUKEwiQgsjrt7XRAhUHa7wKHcIrALYQFggiMAE&url=https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FCJK_characters&usg=AFQjCNGNY4t4CuknACIiA7I1avIM6DMA1A) 和 [IME](https://en.wikipedia.org/wiki/Input_method) 。 Google 一番，原来 gotty 用了 [hterm.js](https://chromium.googlesource.com/apps/libapps/+/master/hterm)，这货是不支持 CJK 和 IME的。 查资料的过程中，我还顺带发现有人用 C 重写了 gotty（嵌入式设备的需求），即 [ttyd](https://github.com/tsl0922/ttyd)。 让人欣喜的是，ttyd 是支持 CJK 和 IME 的，我发现它用的不是 hterm.js, 而是 [xterm.js](https://github.com/sourcelair/xterm.js). Xterm.js 应该是个和 hterm.js 功能类似的库，但是作者挺勤快的，持续更新，而且我最近的新宠 Visual Studio Code 也用了 xterm.js， 看起来挺有前景的。

既然 ttyd 是个 C 版的 gotty, 想必前端那一块都是差不多的，于是费了点力气搬运过来了，像我这种不懂前端的后端码农，居然搞成功了。

![](/images/14839785801360.jpg)


最后总结下可以放到生产环境的 gotty 的参数（起码满足了我的需求）：


    $ gotty -c your_username:your_pwd --max-connection 100 --timeout 3600  -w ./redis-cli —raw --show 

`--show` 也是我加的，纯问候语，用户体验好些（效果见下图）。

备注： 
1. gotty 用的是我 fork 的 那份. https://github.com/holys/gotty
2. redis-cli 是我的轮子，不是官方那份。 https://github.com/holys/redis-cli
3. `./redis-cli` 建议用绝对路径吧 或者加入了 PATH 的命令

![](/images/14839787857878.jpg)


## 后记

在写此文的这一天，gotty 的作者居然合并了那个 timeout 功能的 [PR](https://github.com/yudai/gotty/pull/115). 不过目前的 gotty 依然不支持 CJK 和 IME， 如果需要这个功能的，可以考虑用我那个 fork version. 

还有一些涉及安全的功能没有加进去，如只允许 read-only 的命令。如果有人不小心手抖，敲了个 flushdb 进去咋办？











