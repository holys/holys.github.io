title: 如何结束 etcd watcher
date: 2016-10-19 16:58:51
tags:
- etcd
- go
- context
---

一般而言，我们用 etcd 的 watcher 时，都是像下面这样用，永不休止。

```go

import (
	"time"
	"context"
	"github.com/coreos/etcd/client"
)

func main() {

	c, _ := client.New(client.Config{
		Endpoints:               []string{"http://host:port/"},
		Transport:               client.DefaultTransport,
		HeaderTimeoutPerRequest: time.Second,
	})
	kapi := client.NewKeysAPI(c)

	watcher := kapi.Watcher("/node", nil)

	for {
		resp, err := watcher.Next(context.Background())
		if err != nil {
			// handle error
		}

		// do something with resp
	}

}
	```

但是有时候，我们希望达到某种条件时，终止 watcher。翻看 etcd/client 的文档，没找到类似 watcher.Close() 、 watcher.Stop() 之类的方法，后来才知道，原来这些控制权都交给了 context了。

context 原先只是一个备胎库 `golang.org/x/net/context`， go 1.7 以后被纳入标准库 `context`了，转正成功。 一句话概括，它是一个管理协程树生命周期的解决方案。就是父协程能通过 context 来控制其子协程什么时候退出。

如果读者想了解更多关于 context 资料，可阅读下面的链接内容：
1. https://godoc.org/golang.org/x/net/context
2. https://blog.golang.org/context
3. http://blog.golang.org/pipelines
4. http://lanlingzi.cn/post/technical/2016/0802_go_context/ (中文)

回到正题 “如何结束 etcd watcher” 上来。

由于 context.Background  ` return a non-nil, empty Context. It is never canceled, has no values, and has no deadline.`, 所以不指望他能干啥了。但是 WithCancel 可以帮助我们。

```
func WithCancel(parent Context) (ctx Context, cancel CancelFunc)
```

WithCancel 返回的 cancel 函数，能让我们结束其 child context， 也就是包含了其 child context 的 goroutine 也会退出，当然这是由开发者自己正确实现才起作用的。

子协程实现的套路是这样的：

```
select {
    case <-cxt.Done():
        // do some clean...
}
```

很显然（看代码得知，😝），etcd client 是实现了这种方法。

但是，什么时候去调用 cancel() 方法呢？ 这当然取决于自己的业务需求。

举个例子：


```go
func watch(kapi *client.KeysAPI, node string, stopChan chan struct{}) error {
	watcher := kapi.Watcher(node, nil)
	ctx, cancel := context.WithCancel(context.Background())
	cancelRoutine := make(chan struct{})
	defer close(cancelRoutine)

	go func() {
		for {
			select {
			// 当外部传来 stopChan 时， cancel watcher 的 context
			case <-stopChan:
				cancel()
				return
			case <-cancelRoutine:
				return
			}
		}
	}()

Loop:
	for {
	// Next 方法会一直阻塞，直到有事件触发。
		resp, err := watcher.Next(ctx)
		if err != nil {
		// 当 cancel() 被调用，会返回 context.Canceled 错误。
			if err == context.Canceled {
				log.Println("context canceled")
				break Loop
			}
			return err
		}

		// handle resp here
	}
	log.Println("watch ended")
	return nil
}
```

我也看过[别的写法](https://github.com/kelseyhightower/confd/blob/master/backends/etcd/client.go#L133)，总而言之都是取决于业务的需要。

题外话，go 1.7 的 net/http 已经大力推广 context 包了，推荐使用。




