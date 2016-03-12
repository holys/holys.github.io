title: 让你的 Github Pages 用上 Let‘s Encrypt
date: 2016-03-12 12:00:33
tags:
- letsencrypt
- github
- Kloudsec
---

## TL;DR
通过 https://kloudsec.com/github-pages 可以让你的 github pages 博客用上 [Let's Encrypt](https://letsencrypt.org/) 的免费 HTTPS 证书，而且支持自定义域名！

## 缘起

有位新加坡朋友发邮件邀请我试用他最近写的一个小工具，这个小工具可以让你的 github pages 博客用上 Let's Encrypt 的免费证书，同时这个工具也是免费提供的，而且还让你的博客带上 CDN 功能，加速访问速度（也是免费的哦！）。

注：github pages 很早(2014年)就[支持 https 访问](https://konklone.com/post/github-pages-now-sorta-supports-https-so-use-it
)，但是不支持自定义域名。如果您不需要自定义域名方式的 HTTPS访问，为了节省您的时间，建议您不用继续往下看了。（Ctrl + W || CMD + W）

## 如何配置
整个配置过程非常简单。我简单描述下：

1. 打开 https://kloudsec.com/github-pages
2. 按提示注册 Kloudsec 账户（因为是Kloudsec免费提供的，需要登录到其管理控制台来配置）
3. 输入你的 github pages 的地址 以及 希望用的自定义域名（我假设你本来就用上了 CNAME）。
4. 配置你的自定义域名的 DNS 记录（例如在 dnspod 管理）。A 记录用于 网页访问。TXT 记录用于证明你对该域名的所有权。注意，如果你之前是使用 CNAME 方式来配置自定义域名，请暂停掉 该记录，不然会与 A 记录冲突。整个过程可能需要点时间来生效。
5. 登录 https://kloudsec.com/#/dashboard 。 找到 Protection -> SSL Encryption -> And click options button （ 有 三个点 ... ），选择你的域名，开启开关，让 HTTP 流量自动跳转到 HTTPS
6. 试试 http://holys.im 😄，是不是自动跳转到 https://holys.im

![click](/images/click.png)


![options](/images/options.png)


我认为其原理相当于自动同步你的博客内容到其网站，平时写博客的时候依旧提交到 github 上，其他的都交给 kloudsec.com 来管理。

## 总结

总结下来，有几个优点：
1. 免费的 HTTPS 证书(你不用关心 let's encrypt 是如何使用的)
2. 免费的 CDN（你不用关心如何配置 CDN）

如果有疑问，可以发邮件给那位新加坡朋友询问(please use English) steven#nubela.co






