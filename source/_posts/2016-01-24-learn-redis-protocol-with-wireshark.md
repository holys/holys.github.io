title: 使用 wireshark 分析 redis 协议
date: 2016-01-24 17:14:27
tags:
- redis
- wireshark
---

如果想要和 redis 打交道， 譬如实现某种语言的 redis 的客户端， 实现 redis 的 proxy，都得懂 redis 的数据序列化协议 [REdis Serialization Protocol(RESP)][1](MySQL 同理). Redis使用 TCP 作为其数据传输协议，而分析 TCP 包就不得不祭出 wireshark 这个神器了。 虽然wireshark 可以分析 TCP 包， 但是直接看 TCP 包不是那么直观的看出与 redis 的关系的。此时，我们将借助 [Redis-wireshark](https://github.com/jzwinck/redis-wireshark) 这个wireshark 插件来分析协议。

## 备注
1. 我当前所用的 redis 版本是 2.8。
2. 本文只是分析 C-S 模型的 redis server 的协议。redis cluster 是另一套二进制协议。

## Tips

如果redis-server 和 redis-cli 都是运行在本机, wireshark 应该使用 `loopback`这个虚拟接口来查看数据。至于原因， wireshark 的文档是这么解释的：
> If you are trying to capture traffic from a machine to itself, that traffic will not be sent over a real network interface, even if it's being sent to an address on one of the machine's network adapters. This means that you will not see it if you are trying to capture on, for example, the interface device for the adapter to which the destination address is assigned. You will only see it if you capture on the "loopback interface", if there is such an interface and it is possible to capture on it; 

> https://wiki.wireshark.org/CaptureSetup/Loopback

![wireshark](/images/wireshark.png)

## 分析过程
redis 使用第一个字符来区分不同的数据类型
1. `+` 表示simple string
2. `-` 表示错误 error
3. `:` 表示冒号表示整数
4. `$` 表示bulk string
5. `*` 表示arrays

使用`\r\n` CRLF 字符来表示结尾

举例：

1、 Simple string

```
+OK\r\n
+PONG\r\n
```
![C745546B-D7AD-42E1-863A-43A8141B460B](/images/C745546B-D7AD-42E1-863A-43A8141B460B.png)


2、 error

```
-ERR unknown command ‘ada’\r\n
```
![F145FAE4-FBB8-4E05-869D-42A379B47420](/images/F145FAE4-FBB8-4E05-869D-42A379B47420.png)

3、 integer
删除一个不存在的key, 返回了下面的内容

```
:0\r\n
```
![229DCAA5-60D7-4EBD-9842-4E601818D1F4](/images/229DCAA5-60D7-4EBD-9842-4E601818D1F4.png)

4、 bulk srting
bulk string 用来表示一个`二进制安全`的字符。
其编码结构是：
1. `$` 开头，后面紧跟字符的字节长度，然后是 `\r\n` 结尾;
2. 实际的字符内容;
3. `\r\n` 结尾。

如 `foobar`  可表示为 `$6\r\nfoobar\r\n`，空串可表示为 `$0\r\n\r\n`。

bulk string 好像没有单独的用途, 抓包图片见 arrays。

5、 arrays
也叫 multi bulk。
arrays 的编码结构：
1. `*` 星号开头， 然后是元素的个数（十进制表示）， `\r\n` 结尾
2. 多个用 bulk string 表示元素

客户端发送的内容 都是用 array 表示
如：发送 ping 命令

```
*1\r\n$4\r\nping\r\n
```

![2CCA3B72-CD20-4B8F-BA83-E9BF4E925986](/images/2CCA3B72-CD20-4B8F-BA83-E9BF4E925986.png)

[1]:http://redis.io/topics/protocol


## 小结
明白了 redis 的协议之后，我们就可以尝试编写一个 redis client 了。下篇我会尝试去讲述如何写一个简单的 redis client。其实写 client 只需要关心如何encode， decode 是服务端需要做的事情。当然 client 还需要关心连接池等问题。敬请期待！

