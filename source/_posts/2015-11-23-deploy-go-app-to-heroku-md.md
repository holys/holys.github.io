---
layout: post
title: 部署 Go 应用到 Heroku
date: 2015-11-23 17:00:50
tags:
- go
- heroku
---

记录下如何部署应用到 [Heroku](https://www.heroku.com)。

**注意**: 本文只关注如何部署自己的 GitHub 代码到 Heroku。


先参考 Heroku 提供的 [Demo](https://github.com/heroku/go-getting-started) 了解大概情况。

1. 依赖 [godep](https://github.com/tools/godep);
2. 生成 godep 依赖。 godep save ./… 。不要用 -r 参数;
3. 包括那些依赖包， 一并提交到github;
4. 需要Procfile，  web:   app_name  （二进制名称）;
5. 安装[heroku cli](https://toolbelt.heroku.com/)，  可以看log。



调整代码， 主要是调整启动服务的端口。

```
port := os.Getenv("PORT")
if port == "" {
		log.Fatal("$PORT must be set")
}
```

先在本地试试能不能启动。如果本地都不能正常运行， 在 Heroku上也是会失败的。

```
heroku local
```

正常启动会看到类似下面的信息）：

```
forego | starting web.1 on port 5000
web.1  | starting at :5000 ...

```

Heroku 默认使用 `5000` 端口。 `heroku` 命令行工具会自动提供 `$PORT` 环境变量，不用手动设置。


上述操作都是调整程序本身， 下面去 heroku 的 dashboard 创建应用。

1. create new app;
2. 填写app name （可选）;
3. 选择 `Deploy` =>  `GitHub`;
4. GitHub 授权后，选择需要部署的 repo;
5. 选择要部署的Branch， 然后点击 `Deploy Branch`;
6. 看 Build 的日志;
7. 如果一切正常就可以访问了。

上述操作都是很简单的， 打开Dashboard 一目了然，这里不再提供截图操作。


### Trouble Shooting

如果访问遇到 ` application error`,  则 

```
heroku logs --tail  --app you_app_name 
```

>TIPS: 看日志往往能解决 99% 的问题。

如果发现是 

```
at=error code=H14 desc="No web processes running" method=GET path="/favicon.ico" host=initials.herokuapp.com request_id=4eea4848-47e9-4c78-baf2-1c90c1c98980 fwd="120.31.68.166" dyno= connect= service= status=503 bytes=
```

查询[文档](
https://devcenter.heroku.com/articles/error-codes#h14-no-web-dynos-running
)， 发现是 

> ### H14 - No web dynos running
This is most likely the result of scaling your web dynos down to 0 dynos. To fix it, scale your web dynos to 1 or more dynos:

>```
$ heroku ps:scale web=1
```

执行上面的命令修复即可。    

参考：

1. http://blog.anthonyringoet.be/heroku-no-web-processes-running/
2. https://devcenter.heroku.com/articles/log-runtime-metrics#enabl

