title: 让 go-sql-driver/mysql 兼容 cobar 的事务
date: 2017-01-16 23:10:57
tags:
- mysql
- cobar
- go
---

## 背景介绍

由于历史原因，我们部门的 MySQL 中间件既有 [Mycat](http://mycat.io), 也有 [Cobar](https://github.com/alibaba/cobar)。 Cobar 号称支持事务， 但是居然不支持 `START TRANSACTION` 和 `BEGIN` 显式地开启事务。

> 单库事务完全支持，分布式事务不能保持强一致性。
  分布式事务采用两阶段执行，即分为执行阶段和提交阶段
  执行阶段：把前端连接上当前事务所使用到的后端连接绑定下来，并执行SQL语句
  提交阶段：将commit命令分发到这些绑定的后端连接中。
  在整个事务过程中，执行阶段出错，可以回滚。提交阶段出错不可以回滚。可以说只要是commit之前，执行出现不一致，cobar会自动回滚。



## 如何兼容

可以通过 `SET AUTOCOMMIT=0` 来开启事务， 但是事务结束后，马上又开启了新的事务，如果后面的语句不希望起事务，那么一定要在这次事务中提交 `SET AUTOCOMMIT=1`，使改动立即生效。

我们用的 mysql 驱动是 [go-sql-driver/mysql](https://github.com/go-sql-driver/mysql)，为了适配 Cobar，只能改代码了。

connection.go

```diff
-	err := mc.exec("START TRANSACTION")
+	err := mc.exec("SET AUTOCOMMIT=0")
```

transaction.go

```diff
 	err = tx.mc.exec("COMMIT")
+	err = tx.mc.exec("SET AUTOCOMMIT=1")

  err = tx.mc.exec("ROLLBACK")
+	err = tx.mc.exec("SET AUTOCOMMIT=1")
```

详细改动[见此](https://github.com/yiyulantian/mysql/commit/deb085abeb1a53643d094a11ce3bb33f00ba7287)

改完是能用的。但是后来这个项目迁移到我们的 SOA 框架去了，那个框架的基础库也有一份 go-sql-driver/mysql （没改过的），而且因为框架的设计原因，这个库一定会被引入的

    _  "github.com/go-sql-driver/mysql"
    
    
问题是，我还得用改过的那份代码呢，并且二者是不能同时引入的。这就蛋疼了。

为何不能同时引入 `github.com/go-sql-driver/mysql` 和 `github.com/yiyulantian/mysql`(就是上面提到改动的那份fork)  呢？ 其实它俩对于 database/sql 而言，是同一个数据库驱动。

`go-sql-driver/mysql` 是这样注册进去的

```
func init() {
	sql.Register("mysql", &MySQLDriver{})
}
```

而 `sql.Register` 做了名称的唯一性检查：

```
// Register makes a database driver available by the provided name.
// If Register is called twice with the same name or if driver is nil,
// it panics.
func Register(name string, driver driver.Driver) {
	driversMu.Lock()
	defer driversMu.Unlock()
	if driver == nil {
		panic("sql: Register driver is nil")
	}
	// 看到没，重复了会 panic 的
	if _, dup := drivers[name]; dup {
		panic("sql: Register called twice for driver " + name)
	}
	drivers[name] = driver
}
```

对于这种 panic, 总不能为了绕过去而做一次 recover 吧。

于是我决定曲线救国， 改个名字。

```diff
func init() {
- sql.Register("mysql", &MySQLDriver{})
+ sql.Register("mysql_cobar", &MySQLDriver{})
}
```

在使用上，创建一个 DB 对象就是这样啦：

```go
db, err = sql.Open("mysql_cobar", "YOUR_DSN")
```

希望 DBA 快点废掉 cobar ！


## Cobar 和 Mycat 对 BEGIN 和 START TrANSACTION 的代码实现

先看下 Cobar（不贴代码了，自己点链接去看）

- [Begin](https://github.com/alibaba/cobar/blob/850fb8b0ead8dffe3f7c6903d9471f12d53c2cc4/server/src/main/server/com/alibaba/cobar/server/handler/BeginHandler.java)
- [Start](https://github.com/alibaba/cobar/blob/850fb8b0ead8dffe3f7c6903d9471f12d53c2cc4/server/src/main/server/com/alibaba/cobar/server/handler/StartHandler.java)

再看下 Mycat 

- [Begin](https://github.com/MyCATApache/Mycat-Server/blob/5e4007af2cfe160b94f98174dd349afc3da99a21/src/main/java/io/mycat/server/handler/BeginHandler.java)
- [Start](https://github.com/MyCATApache/Mycat-Server/blob/5e4007af2cfe160b94f98174dd349afc3da99a21/src/main/java/io/mycat/server/handler/StartHandler.java)

代码链接都是截止至 2017.01.19 最新的commit。

## 参考资料
1. [Cobar 常见问答](https://github.com/alibaba/cobar/wiki/%E5%B8%B8%E8%A7%81%E9%97%AE%E7%AD%94)
2. [ Cobar的使用与心得（持续更新）](http://blog.csdn.net/jiao_fuyou/article/details/14181541)
3. [cobar中是怎么支持事务的](https://groups.google.com/forum/#!topic/ali-cobar/Z8394BLSpfw
)
4. [MYSQL--事务处理](http://www.cnblogs.com/in-loading/archive/2012/02/21/2361702.html)
5. [mysql 中间件研究](http://ximeng1234.iteye.com/blog/2208059)










