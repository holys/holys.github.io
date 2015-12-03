title: Charles Work Around
date: 2015-11-29 09:43:18
tags:
- charles
- chrome
- tool
---

我之前一直用 [Charles](https://www.charlesproxy.com/) 这个抓包软件来分析 HTTP 请求。而对于浏览器（这里特指Chrome）的抓包， 我通常使用 [Proxy-SwitchySharp](https://chrome.google.com/webstore/detail/proxy-switchysharp/dpplabbmogkhghncfbfdeeokoefdjegm) 这款插件来辅助。

突然有一天，上面这个搭配没法工作了（提供 HTTPS 的网站才会这样）！浏览器提示：

Server has a weak ephemeral Diffie-Hellman public key

![](/images/chrome.png)

看样子是服务端的 HTTPS 安全级别不够高，被浏览器禁止访问了。

于是我按图索骥， Google 了一下，发现很多人也遇到[类似问题](http://stackoverflow.com/questions/30942288/server-has-a-weak-ephemeral-diffie-hellman-public-key-how-to-by-pass-it)。别人的出发点也跟我一样， 就是 bypass it。 毕竟花时间研究代码比折腾这种东西有意义多了。

很显然，最简单暴力的方式就是通过给浏览器添加启动参数来绕过检查。

Mac 下面是这样处理：

```
open /Applications/Google\ Chrome.app --args --cipher-suite-blacklist=0x0088,0x0087,0x0039,0x0038,0x0044,0x0045,0x0066,0x0032,0x0033,0x0016,0x0013
```

其他平台的解决方案请参考 SO 上面的[回答](http://stackoverflow.com/questions/30942288/server-has-a-weak-ephemeral-diffie-hellman-public-key-how-to-by-pass-it/)。

但是每次这么启动浏览器， 不太方便吧。 我找到 Chrome的安装目录。修改下启动 App的方式，让其自动带上参数。

Chrome 的安装目录通常是： 

```
/Applications/Google\ Chrome.app
```

而我的是通过 brew cask install google-chrome 来安装的。 

通过 brew cask info google-chrome 得知我的 Chrome 目录是： /opt/homebrew-cask/Caskroom/google-chrome/latest。 真正的二进制文件在 /opt/homebrew-cask/Caskroom/google-chrome/latest/Google Chrome.app/Contents/MacOS/Google\ Chrome。

我将其重命名为 Google\ Chrome.real （随意起个名字），然后用一个 shell 脚本来代替之前的二进制， 并赋予执行权限。

```
$ cat Google\ Chrome
#!/bin/bash
/opt/homebrew-cask/Caskroom/google-chrome/latest/Google\ Chrome.app/Contents/MacOS/Google\ Chrome.real -a -D --args --cipher-suite-blacklist=0x0088,0x0087,0x0039,0x0038,0x0044,0x0045,0x0066,0x0032,0x0033,0x0016,0x0013

$ chmod +x Google\ Chrome
```

不过， 还是不够完美，因为会弹窗：

![](/images/confirm.png)

先这样吧。


