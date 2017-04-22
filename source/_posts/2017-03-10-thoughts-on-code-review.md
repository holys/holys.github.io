title: 我设想中的 code review
date: 2017-03-16 09:38:25
tags:
- gitlab
- code-review
---

## 为什么要有 code review

code review  有很多好处：

- 促进个人进步。如果有技术水平强的人帮你 review 代码，那简直是前世修来的福分。如果组内没有高手，组员之间互相 review，共同进步。
- 找出隐藏的 bug。 当局者迷，旁观者清。自己没意识到的错误，别人可能一下子就看出来了。也算是白盒测试吧。
- 增进对业务的了解。
- 意识到别人会 review 自己的代码，自己写代码的时候也会格外认真（怕出丑嘛）

code review 的好处就不一一列举了。


## 我设想的 code review

在提交代码之前，先自己 review 一遍。我平时习惯用 [GitHub 客户端](https://desktop.github.com)看提交的 diff，这客户端简单易用，体验非常好（当年在WPS 的时候 [@siddontang](https://github.com/siddontang) 推（qiang）荐（zhi）我们使用的）。

我非常喜欢 GitHub 上一些开源项目的做法，如：[pingcap/tidb](https://github.com/pingcap/tidb), [coreos/etcd](https://github.com/coreos/etcd)。以 tidb 的[某个 pull request](https://github.com/pingcap/tidb/pull/2806) 为例子。 

提交 PR 的人说明改动来由，然后指定 reviewer， 一般而言，有 两人以上评论 LGTM(looks good to me) ，就可以合并这个PR了。

![6E20CD72-EF3A-4087-8B94-17B92CA550A2](/images/6E20CD72-EF3A-4087-8B94-17B92CA550A2.png)


如果对提交的代码有疑问，可直接在diff 里面评论，非常方便。

但是很少有公司像 pingcap， coreos 专门做开源的项目，代码几乎都在 github 上托管。大部分的公司都是在公司内网托管代码，如使用 gitlab。由于我们部门使用的是 gitlab，我将基于 gitlab 说下我的想法。

其实 github 支持的功能，gitlab 基本都有。不过 gilab 没有 pull request， 只有 merge request。 我们现在是以 [feature branch workflow](https://docs.gitlab.com/ee/workflow/workflow.html) 为主，即基于 master 创建 feature branch，增加功能或者 bug fix，然后提交 merge request，合并到 master。

我设想的 code review 跟上面提到的差不多，也是 LGTM 式，但是我希望这个步骤能自动化，即达到 N个(一般是 2 个 ) LGTM 后，自动合并到 目标分支（一般是 master）。

其实github 上有人[开源了lgtm 的工具](https://github.com/lgtmco/lgtm) ，只不过是基于 github 的，[并不适用 gitlab](https://github.com/lgtmco/lgtm/issues/48)。

## 如何实现？

由于 gitlab 提供 [webhooks](https://docs.gitlab.com/ce/user/project/integrations/webhooks.html#webhooks)，我们可以基于 webhook 开发一个自动合并 merge request 的 bot。 
从 webhook 的文档来看， 我们只需要关心 [Comment events](https://docs.gitlab.com/ce/user/project/integrations/webhooks.html#comment-events)， 准确地说， 是关于merge request 的 comment。当收到comments 时，检查其内容是否为 LGTM， 如果是，则 +1， 超过设置的 N 值 则合并 merge  request。

逻辑非常简单。实现起来也很容易。不过初期为了验证想法，我只把状态记录在内存，且统计LGTM 的时候，并没有区分这LGTM 是不是同一个人回复的（理应是要区分的）。

如果对这个比较粗糙的实现有兴趣的话，可以看下[代码](https://github.com/holys/lgtm-gitlab)

![](/images/14896292287686.jpg)


##  本文未讨论的

由于本人经验有限，本文并未涉足 code review 的内容细节（即关于好代码的标准）。

有兴趣的读者可延伸阅读下列文章:

- [关于Code Review，你「必须」了解的一些关键点](http://mp.weixin.qq.com/s?__biz=MjM5MDE0Mjc4MA==&mid=2650994555&idx=1&sn=b196e2dfb293ec7829523011316a7e06&scene=0#wechat_redirect)
- [Code Review最佳实践](http://mp.weixin.qq.com/s?__biz=MzIwMTQwNTA3Nw==&mid=400946871&idx=1&sn=5a125337833768d705f9d87ba8cd9fff&scene=0#wechat_redirect)
- [陈老师｜我的“code review”成长之路](http://mp.weixin.qq.com/s?__biz=MjM5ODIzNDQ3Mw==&mid=2649966104&idx=1&sn=2e9a184beb676cb8687c0bed024fdd62&scene=0#wechat_redirect)

