---
layout: post
title: HTTP Method
date: 2015-06-28 12:00:00
tags:
- http
---


最近业余时间用 Go 写一个 API 测试工具时， 遇到一个很奇怪的问题。处理请求返回内容的时候， 遇到error `malformed HTTP response "<html>"`.
搜了下 Go 的标准库代码，发现是 `net/http` `ReadResponse`函数里面返回的错误。里面涉及到的代码是这样的：

```
// Parse the first line of the response.
line, err := tp.ReadLine()
if err != nil {
	if err == io.EOF {
		err = io.ErrUnexpectedEOF
	}
	return nil, err
}
f := strings.SplitN(line, " ", 3)
if len(f) < 2 {
	return nil, &badStringError{"malformed HTTP response", line}
}
```


其意思大概是，解析response的第一行，如果不合法，就返回 `malformed HTTP response xxx`。 按理说，正常的response 第一行，应该是这样的

```
HTTP/1.1 200 OK
```

而且返回的内容是提到了 `<html>`。 这是不是意味着没有返回header， 返回内容才被判定为畸形（malformed）的response。
抓包试试， 果然没有HTTP Header， 且返回的正文是 Nginx 返回的。

```
<html>
<head><title>400 Bad Request</title></head>
<body bgcolor="white">
<center><h1>400 Bad Request</h1></center>
<hr><center>Nginx</center>
</body>
</html>
```

因为我访问的服务是从Nginx proxy pass过去的，所以请求并没有转发到后台服务去，而是在 Nginx 这层就被拦截了。为何拦截，我百思不得其解。
不过有一点是明白的， 我发的请求不合法，被Nginx拦截了，不然也不会 400 bad request了。 一开始我以为是Header不合法， 就逐一删掉Header（如何修改请求？请继续阅读），发现并不是Header的问题。 后来请教了同事，他说会不会是请求的Method有问题呢？ 我看了下， 好着呢！

```
get /get HTTP/1.1
```

其实不然， 这里就是HTTP Method 出了问题。赶紧查阅[RFC][1]， 发现真是我搞错了。
相关文档如下：


```
   The Method  token indicates the method to be performed on the
   resource identified by the Request-URI. The method is case-sensitive.

       Method         = "OPTIONS"                ; Section 9.2
                      | "GET"                    ; Section 9.3
                      | "HEAD"                   ; Section 9.4
                      | "POST"                   ; Section 9.5
                      | "PUT"                    ; Section 9.6
                      | "DELETE"                 ; Section 9.7
                      | "TRACE"                  ; Section 9.8
                      | "CONNECT"                ; Section 9.9
                      | extension-method
       extension-method = token
```

坑爹啊！ **The method is case-sensitive.**. 这就是不熟读文档的后果！有时候确实看到有些工具的请求Method是小写的，但是不代表实际上就是这样，也许程序里面做了转换。

Tips：

抓包工具用了 [Charles][2]。我记得 Charles 并不会自动自动捕获HTTP报文，需要自己设置代理。由于 Go 的 `net/http`包支持代理，所以实现起码并不难。

```
tr := &http.Transport{
		Proxy: http.ProxyFromEnvironment, // 起作用的是这行
		Dial: (&net.Dialer{
			Timeout:   10 * time.Second,
			KeepAlive: 10 * time.Second,
		}).Dial,
		TLSClientConfig:     &tls.Config{InsecureSkipVerify: true},
		TLSHandshakeTimeout: 10 * time.Second,
		MaxIdleConnsPerHost: 20,
	}
client := &http.Client{Transport: tr}
```

`http.ProxyFromEnvironment` 说明是使用系统环境变量里面的设定。

> ProxyFromEnvironment returns the URL of the proxy to use for a
> given request, as indicated by the environment variables
> HTTP_PROXY, HTTPS_PROXY and NO_PROXY (or the lowercase versions
> thereof). HTTPS_PROXY takes precedence over HTTP_PROXY for https
>requests.

由于我写的是命令行工具，所以直接在终端里面设定即可。譬如这样：

```
$ export HTTP_PROXY=127.0.0.1:8888  # 8888 是Charles的默认代理端口
```

然后启动我的程序，所发请求就自动被Charles捕获了。

最后：

![miao](/images/miao.png)
(还是个半成品！)

[1]: http://tools.ietf.org/html/rfc2616#section-5.1.1
[2]: http://www.charlesproxy.com


