title: 工具与资源
date: 2016-09-20 15:18:07
tags:
- tool
- go

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

![tools](/images/tools.png)

Sublime Text 目前依然是我的主力编辑器。年少无知时，我是个 IDE 黑，现在越来觉得有必要搞一款 IDE 来作为我的主力开发工具，但是一直没有物色到。

#### Sublime 插件

- SideBarEnhancements
- Pretty JSON
- Git
- GoSublime（随着 GOPATH 下面代码量的增加，有些功能就变得很慢了）
- Godef （有些项目本身就占一个 GOPATH,所以每次新增项目都得配置 GOPATH，烦）

快捷键那些就不介绍啦~

#### Chrome 插件

- [Sourcegraph](https://chrome.google.com/webstore/detail/sourcegraph-for-github/dgjhfomjieaadpoljlnidmbgkdffpack) （github. Browse and search code on GitHub like an IDE, with jump-to-definition, doc tooltips, and semantic search.）
- [Octotree](https://chrome.google.com/webstore/detail/octotree/bkhaagjahfmjljalopjnoealnfndnagc) （Code tree for GitHub and GitLab ,  我们用的 gitlab 版本不兼容 ）
- Save to pocket. Pocket 用户推荐（[又有人说](https://zhuanlan.zhihu.com/p/22545574?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io)不要依赖 pocket,力争一次看完，要么就不看）。
- Proxy SwitchyOmega（你懂的）
- JSON View (跟 JSON API打交道，需要一个格式化工具)
- HTTP 调试工具  Postman / DHC
- [HTTPS Everywhere](https://www.eff.org/https-everywhere)
- ...

#### 终端
0. zsh/oh-my-zsh
1. readline (readline 是一个行编辑库，常见的 shell 如 bash, zsh 支持 readline)
https://cnswww.cns.cwru.edu/php/chet/readline/rluserman.html
2. autojump ( a faster way to navigate your filesystem)     / z?
https://github.com/wting/autojump
https://github.com/rupa/z   跟 autojump 很像


### 知识管理工具

- Evernote / 有道笔记 / 为知笔记
- Pocket （read it later => read it never， 收藏文章）

### 爬墙工具
- lantern + Proxy SwitchyOmega
- 靠谱的 VPN ？

### 硬件
1. Macbook Pro/Air  / Mac Mini （官网购买 + appletuan.com 港）
插入： IBM  大规模采购苹果电脑 http://www.solidot.org/story?threshold=0&mode=flat&sid=44981
2. 一款舒适的键盘 机械式 / 静电电容式（HHKB）

## 资源篇

### 资讯来源
（加粗的表示我重度使用的）
- **weibo** 关注的人 / @湾区日报BayArea
- **github** 首页 （关注的人，像刷微博一样刷动态）
- reddit.com/r/golang （reddit 太多 topic, 挑自己感兴趣的）
- **toutiao.io**  关注自己感兴趣的
- twitter （偶尔看，第一手资料）
- hacker news(其实很少看)
- v2ex(? 越来越水， 用来招聘/找工作还行)
- 逛博客，从一个链接跳到另一个链接
- 纸质书

### 如何查资料
     
     0. 具体项目 首选官网
     1. google  + 英文 keyword   =>  stackoverflow  + github + google groups +  wikipedia + 个人博客 。 候选 bing
     2. slides 搜索。 www.slideshare.net  / https://speakerdeck.com/
     3. 如果是某个github项目, 直接搜索其 issue
     4. 如果是想找某个项目  github 直接搜：  keyword + language: xxx
     5. 找书上豆瓣, 找电子书  问 google    site:pan.baidu.com  + 书名 + pdf/mobi/epub
     6. 知乎也是可以的
     7. 找视频 youtube.com / vimeo.com

## Go 语言相关资源

### 推荐
0. 所有精华的东西都在官网！！！
1. 语言规范：https://golang.org/ref/spec
2. effective go  https://golang.org/doc/effective_go.html
3. godoc 看文档 https://godoc.org/
4. faq  https://golang.org/doc/faq
5. style guide: https://github.com/golang/go/wiki/CodeReviewComments  以及上面的 effective go
6. 官方博客: https://blog.golang.org/
7. Dave Cheney 博客 http://dave.cheney.net/category/golang （推荐）

如果想了解更多：
1. https://github.com/golang/go/wiki
2. http://stackoverflow.com/tags/go/info

### 图书
1.  入门：The Go Programming Language https://book.douban.com/subject/26337545/
2.  进阶：Go 语言学习笔记 https://book.douban.com/subject/26832468/

### 代码
1. go 标准库代码 /usr/local/go/src/
2. siddontang https://github.com/siddontang （前同事代码，非常值得一看）
3. thrift/go
4. tidb/etcd/fasthttp
5. language:go stars:>5000

### 工具
http://dominik.honnef.co/posts/2014/12/go-tools/


以上，仅代表个人习惯。而且也会随着时间变化而变化。


