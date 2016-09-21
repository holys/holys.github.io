title: 工具与资源
date: 2016-09-20 15:18:07
tags:
- tool
- golang

---

前阵子在小组内部分享过我平时使用的工具和资源，这里权当记录一下，也充当一篇 😜

## 工具篇

### 开发工具

- Alfred / Spotlight 快速检索文件, 二者互补
- Sublime Text 3 / Atom / VS Code(看好)
- [Gas Mask](http://clockwise.ee/) （管理 hosts, Mac）
  同类: [SwitchHosts](https://oldj.github.io/SwitchHosts) 支持 Windows/Mac
- 抓包软件 Wireshark / Charles 。  tcpdump + wireshark
- Markdown:  MacDown/Mweb (收费)
* Git:  GitHub 客户端（推荐） / SourceTree（功能强大）
* [SequelPro](https://www.sequelpro.com/)  MySQL 客户端
* [Postico](https://eggerapps.at/postico/) Postgres 客户端
* 推荐推荐一款轻量级磁盘清理工具 [OmniDiskSweeper](https://www.omnigroup.com/more)，帮我找到了隐藏 N 久的虚拟机镜像文件（可怜我只有128GB 的闪存空间）
* 如果用 HHKB, [Karabiner](https://pqrs.org/osx/karabiner/) 基本是必备的，改键盘映射。

更多的，见图， 不一一介绍了。

![tools](/images/tools-1.png)


Sublime Text 目前依然是我的主力编辑器。年少无知时，我是个 IDE 黑，现在越来觉得有必要搞一款 IDE 来作为我的主力开发工具，但是一直没有物色到。

#### Sublime 插件：

- SideBarEnhancements
- Pretty JSON
- Git
- GoSublime （gopath 坑）
- Godef （gopath 坑）

Sublime: 常用快捷键
cmd + p   goto anything
cmd + r    goto symbol
cmd + shift + r  goto symbol in project
cmd + g  goto line

ctrl + b  jump back
ctrl + f   jump forward

多处编辑：
cmd + d ,  cmd + k

batch editing:
cmd + shift + l


#### Chrome 插件

- [Sourcegraph](https://chrome.google.com/webstore/detail/sourcegraph-for-github/dgjhfomjieaadpoljlnidmbgkdffpack) （github. Browse and search code on GitHub like an IDE, with jump-to-definition, doc tooltips, and semantic search.）
- [Octotree](https://chrome.google.com/webstore/detail/octotree/bkhaagjahfmjljalopjnoealnfndnagc) （Code tree for GitHub and GitLab ,  我们用的 gitlab 版本不兼容 ）
- Save to pocket. Pocket 用户推荐。
- Proxy SwitchyOmega（你懂的）
- JSON View (跟 JSON API打交道，需要一个格式化工具)
- HTTP 调试工具  Postman / DHC
- [HTTPS Everywhere](https://www.eff.org/https-everywhere)
- ...

终端操作：
0. zsh/oh-my-zsh
1. readline (readline 是一个行编辑库，常见的 shell 如 bash, zsh 支持 readline)
https://cnswww.cns.cwru.edu/php/chet/readline/rluserman.html
2. autojump ( a faster way to navigate your filesystem)     / z?
https://github.com/wting/autojump

https://github.com/rupa/z   跟 autojump 很像

tmux ?

1.2 知识管理：

1.2.1 Evernote / 有道笔记 / 为知笔记
1.2.1 Pocket （read it later => read it never， 收藏文章）

爬墙工具：
1. lantern + Proxy SwitchyOmega
2. 靠谱的 VPN ?

硬件：
1.Macbook Pro/Air  / Mac Mini （官网购买 + appletuan.com 港）
插入： IBM  大规模采购苹果电脑 http://www.solidot.org/story?threshold=0&mode=flat&sid=44981
2. 一款舒适的键盘 机械式 / 静电电容式

2. 资源篇

- weibo 关注的人  /  @湾区日报BayArea
- github 首页 （关注的人）
- reddit.com/r/golang （自己感兴趣的 topic）
- toutiao.io   关注自己感兴趣的
- twitter （偶尔看，第一手资料）
- hacker news(YC， 极少看)
- v2ex(? 越来越水， 用来招聘还行)
- …

查资料：
     0. 具体项目 首选官网
     1. google  + 英文 keyword   =>  stackoverflow  + github + google groups +  wikipedia + 个人博客 。 候选 bing
     2. slides 搜索。 www.slideshare.net  / https://speakerdeck.com/
     3. 如果是某个github项目, 直接搜索其 issue
     4. 如果是想找某个项目  github 直接搜：  keyword + language: xxx
     5. 找书上豆瓣, 找电子书  问 google    site:pan.baidu.com  + 书名 + pdf/mobi/epub
     6. 知乎也是可以的
     7. 找视频 youtube.com / vimeo.com

Go 语言相关资源：
推荐：
0. 所有精华的东西都在官网！！！
1. 语言规范：https://golang.org/ref/spec
2. effective go  https://golang.org/doc/effective_go.html
3. godoc 看文档 https://godoc.org/
4. faq  https://golang.org/doc/faq
5. style guide: https://github.com/golang/go/wiki/CodeReviewComments  以及上面的 effective go
6. 官方博客: https://blog.golang.org/
7. Dave Cheney 博客 http://dave.cheney.net/category/golang

如果想了解更多：
1. https://github.com/golang/go/wiki
2. http://stackoverflow.com/tags/go/info

图书：
1.  入门：The Go Programming Language https://book.douban.com/subject/26337545/
2.  进阶：Go 语言学习笔记 https://book.douban.com/subject/26832468/

代码：
1. go 标准库代码 /usr/local/go/src/
2. siddontang https://github.com/siddontang
3. thrift/go
4. 其他  tidb/etcd/fasthttp
5. language:go stars:>5000

工具：
http://dominik.honnef.co/posts/2014/12/go-tools/

