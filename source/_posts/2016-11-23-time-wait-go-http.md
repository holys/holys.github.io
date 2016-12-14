title: net/http 与 TIME_WAIT
date: 2016-11-23 22:16:49
tags:
- http
- time_wait
- tcp
- wrk
- performance
---

最近在对我们的网关服务（gateway）进行压力测试时，发现网关服务产生大量的 TIME_WAIT. Gateway 是用 go 实现的，通过 HTTP 方式与后端服务进行通信，也就是说使用了 net/http 包。 在我的理解中，net/http 是默认保持长连接的，按理说不会有这么多 TIME_WAIT 状态的。除非是使用了短连接，每次都是三次握手，然后客户端（gateway）主动关闭连接，进入 TIME_WAIT 状态。有 TIME_WAIT 不奇怪，数量多了就奇怪了。


![](/images/14799159319678.jpg)


我看了下 gateway 的代码，里面实现并没有使用 http.Client, 而是用了比较 low-level 的 Transport, 而且是 DefaultTransport， 并且对 DefaultTransport 的 MaxIdleConnsPerHost 做了调整。

	  http.DefaultTransport.(*http.Transport).MaxIdleConnsPerHost = 200
	
当我用 wrk 压测时，

     wrk -s post.lua  http://ip:port/path -c 1000 -t 20 -d 30
 
会产生大量的 TIME_WAIT，大概 6000 ~ 7000 左右吧， 机器是一台 2 核的 docker 容器，在好一点的机器能达到 28000多。 而当我在不断调整 wrk 的 连接数时， 发现有时候TIME_WAIT 的数量少，少到那些 TIME_WAIT 都不是 gateway 程序产生的。突然想起，这应该跟连接池有关。然后我看了下 transport.go 的代码， 发现我们用错了。
 
我们只是设置了 MaxIdleConnsPerHost = 200， 但是 还有一个值 MaxIdleConns 没有设置，而这个的默认值是 100. MaxIdleConns 与 MaxIdleConnsPerHost 的关系是： 

    MaxIdleConnsPerHost <= MaxIdleConns
    
net/http 包没有对二者关系作强制检查，但是会影响实际的长连接数量。也就是说，gateway 虽然配置了 MaxIdleConnsPerHost = 200，实际上只有 100个长连接。

关于MaxIdleConnsPerHost 与 MaxIdleConns 关系的相关代码如下：

```go
func (t *Transport) tryPutIdleConn(pconn *persistConn) error {
	if t.DisableKeepAlives || t.MaxIdleConnsPerHost < 0 {
		return errKeepAlivesDisabled
	}
	if pconn.isBroken() {
		return errConnBroken
	}
	if pconn.alt != nil {
		return errNotCachingH2Conn
	}
	pconn.markReused()
	key := pconn.cacheKey

	t.idleMu.Lock()
	defer t.idleMu.Unlock()

	waitingDialer := t.idleConnCh[key]
	select {
	case waitingDialer <- pconn:
		// We're done with this pconn and somebody else is
		// currently waiting for a conn of this type (they're
		// actively dialing, but this conn is ready
		// first). Chrome calls this socket late binding. See
		// https://insouciant.org/tech/connection-management-in-chromium/
		return nil
	default:
		if waitingDialer != nil {
			// They had populated this, but their dial won
			// first, so we can clean up this map entry.
			delete(t.idleConnCh, key)
		}
	}
	if t.wantIdle {
		return errWantIdle
	}
	if t.idleConn == nil {
		t.idleConn = make(map[connectMethodKey][]*persistConn)
	}
	idles := t.idleConn[key]
	// MaxIdleConnsPerHost 作为第一层检查，如果当前 idle 数量 >= MaxIdleConnsPerHost，
	// 则返回错误。当然这个错误不会一直往外抛，有些地方处理了，有些地方没处理。
	if len(idles) >= t.maxIdleConnsPerHost() {
		return errTooManyIdleHost
	}
	for _, exist := range idles {
		if exist == pconn {
			log.Fatalf("dup idle pconn %p in freelist", pconn)
		}
	}
	t.idleConn[key] = append(idles, pconn)
	t.idleLRU.add(pconn)

	// MaxIdleConns 作为第二层检查，如果 idleLRU 数量大于 MaxIdleConns，则清除最老的连接 （LRU）， 保证长连接数量不超过 MaxIdleConns 
	if t.MaxIdleConns != 0 && t.idleLRU.len() > t.MaxIdleConns {
		oldest := t.idleLRU.removeOldest()
		oldest.close(errTooManyIdle)
		t.removeIdleConnLocked(oldest)
	}
	if t.IdleConnTimeout > 0 {
		if pconn.idleTimer != nil {
			pconn.idleTimer.Reset(t.IdleConnTimeout)
		} else {
			pconn.idleTimer = time.AfterFunc(t.IdleConnTimeout, pconn.closeConnIfStillIdle)
		}
	}
	pconn.idleAt = time.Now()
	return nil
}
```

当然我在本机用 wrk 压 1000个长连接时， 就出现了大量  connect: cannot assign requested address。 因为只有 gateway 只维持了 100个长连接，剩下900 个连接会不断创建、销毁（这里都是指 gateway 对后端服务）。大量的三次握手，并 gateway 作为客户端 主动关闭连接（对 后端服务的连接），连接会进入 TIME_WAIT 状态，
等待回收。 这个回收时间虽然可以通过设置系统内核参数来临时解决，但是治标不治本，也不知道会有什么不良影响。

$ sudo sysctl -w net.ipv4.tcp_timestamps=1
$ sudo sysctl -w net.ipv4.tcp_tw_recycle=1

当我设置
http.DefaultTransport.(*http.Transport).MaxIdleConnsPerHost = 1000
http.DefaultTransport.(*http.Transport).MaxIdleConns = 1000

然后再用 wrk 1000个 长连接去压测时， 
    
    netstat -natpl |grep TIME_WAIT | wc -l  

发现 TIME_WAIT 数量很小，跟程序 gateway 未启动 保持一致，也就是没有产生额外的 TIME_WAIT.
没有大量 TIME_WAIT ，也就是全部都是长连接， 其效果就是， wrk => gateway => 后端服务 的 QPS 直接上来了，达到 11934. 而直接压后端服务， 其 QPS 是 13462， 性能只是损耗了 11.3%。  之前是损耗了 33%.  可见，短连接对性能的影响还是蛮大的（并不是说短连接相比长连接的性能下降是20%）。
    
小结：在本文环境中， TIME_WAIT 是在客户端产生的，原因是客户端的连接池太小，导致新连接不断创建，然后又主动关闭连接，产生大量 TIME_WAIT。解决办法是调大连接池的数量。

参考：
1. http://www.firefoxbug.com/index.php/archives/2795/  （对 TIME_WAIT 讲解很透彻，推荐阅读）
2. http://www.cs.northwestern.edu/~agupta/cs340/project2/TCPIP_State_Transition_Diagram.pdf     


更新： 最近（2016.12.14） 发现老外写了一篇和我的很相似的文章，给大家参考:
https://tleyden.github.io/blog/2016/11/21/tuning-the-go-http-client-library-for-load-testing




