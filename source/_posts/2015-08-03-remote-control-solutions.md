---
layout: post
title: 远程连接解决方案
date: 2015-08-03 12:00:00
tags:
- tool
---



如果需要远程连接， 目的地无外乎两种：

1. 字符终端
2. 图形终端


如果是字符终端，一般使用 SSH；如果是图形终端，一般是 [VNC][1]。二者有个共同点， 即连接方与被连接方需处于同一网络内（比如局域网？），或者被连接方具有公网IP。


问题来了， 如果上述连接条件都达不到呢？比如你在家里希望连接上公司的网络，远程控制你的 Linux Server 或者 Windows 桌面，而你又没有公司 VPN（你不知道有些公司的VPN申请是困难重重的，而且据说还不好用）。办法总是有的。最近冒出来的 [Ngrok][2] 就是个不错的解决办法。 原理就不介绍了（其实是笔者还没花时间去弄懂:P）。

简单的说， 通过 ngrok，你可以在家里连接上公司的网络， 既然连上了公司的网络，那么上文提到的一些远程连接手段又可以工作了。


具体的细节看 ngrok [官网][3]（如果打不开，不关我的事呀） 或者随便 [google][4] 一下。

简要介绍使用 ngrok 的步骤：

1. 你需要有一台公网的服务器，当然得有公网IP（废话）；
2. 在公网服务器上配置好 ngrok 服务端，开放 tcp 连接端口；
3. 被连接方（比如你的公司内网机器）配置 ngrok 客户端，指向 ngrok 服务端；
4. 连接方（比如你家里的 Macbook）直接 ssh 到 `root@yourngrok.com -p yourserverport`

一般而言，上面的步骤满足了 ssh 到公司内网服务器的需求。

如果你希望在家里访问公司内网才能访问的网站， 比如 OA 系统，GitLab 等，
可以通过 SSH 端口转发的方式。e.g. 

    ssh root@yourngrok.com -p yourserverport -D yourlocalport
    
通过 yourlocalport, 可以将本地流量转发到该端口，然后通过 ssh 加密传输到 ngrok 服务器， 再从 ngrok 服务器到公司内网，就达到了浏览公司内网网站的目的。 具体的浏览方式可以是 Chrome + [Proxy SwitchySharp][5]。代理的方式是 SOCKS V5，V4 好像也可以。

如果你希望 biger 更高一些，譬如 希望在家里提交代码啊，还可以搞个全局代理。全局代理可以借助软件 [Proxifier][6] 来实现。Mac 和 Windows 的客户端都提供。

当然还有其他手段可以达到类似的目的。

1. QQ 远程控制，缺点是只支持PC QQ。
2. [TeamViewer][7] 或者 [Anydesk][8]

不一一列举。

Have fun :)

（若有不当之处，还望读者指出，谢谢）

[1]: https://en.wikipedia.org/wiki/Virtual_Network_Computing
[2]: https://github.com/inconshreveable/ngrok
[3]: http://ngrok.com
[4]: https://www.google.com.hk/search?q=ngrok&newwindow=1&safe=strict&es_sm=91&source=lnt&tbs=lr:lang_1zh-CN%7Clang_1zh-TW&lr=lang_zh-CN%7Clang_zh-TW&sa=X&ved=0CBQQpwVqFQoTCMe91bmXjccCFQullAodzLcMwg&biw=1280&bih=678
[5]: https://chrome.google.com/webstore/detail/proxy-switchysharp/dpplabbmogkhghncfbfdeeokoefdjegm
[6]: https://www.proxifier.com
[7]: https://www.teamviewer.com/zhcn/download/windows.aspx
[8]: http://anydesk.com/remote-desktop

