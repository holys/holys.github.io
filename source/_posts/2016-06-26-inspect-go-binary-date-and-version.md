title: 自动生成 Go 程序版本号
date: 2016-06-26 17:22:27
tags:
- go
- ldflags
---


## 问题：如何得知某个二进制的文件的 Git SHA1 值 和编译时间？ 

总的思路都是编译时候通过某种方式将所需信息保存下来。 
有好几种实现方式： 

## 1. 将这些信息作为文件名的一部分 
如 `XXX_$Version_$Date`

```
#!/bin/bash 

Version=`git rev-parse -- short HEAD` 
Date=`date "+%Y%m%d%H%M%S"` 
Target =“XXX_$Version_$Date}" 
go build -o $Target /path/to/main 
``` 

不过这种方式有个缺点： 文件名是不规则的，可能对运维同学不是那么的友好。 

## 2. 将这些信息作为源代码的一部分 

生成代码也有两种方式： 

### 2.1 通过 shell 脚本方式生成代码 

```bash
#!/bin/bash 

version=`git log --date=iso --pretty=format:"%cd @%h" -1` 
if [ $? -ne 0 ]; then 
    version="not a git repo" 
fi 

compile=`date +"%F %T %z"`" by "`go version` 

cat << EOF | gofmt > version.go 
package version 

const ( 
    Version = "$version" 
    Compile = "$compile" 
) 
EOF% 
``` 

生成的代码效果为： 

```go
$ cat version.go 
package version 

const ( 
    Version = "2016-03-23 17:06:31 +0800 @c0d144f" 
    Compile = "2016-06-05 23:29:45 +0800 by go version go1.6.2 darwin/amd64" 
) 
``` 

### 2.2.  通过 go build 的 -ldflags 参数在编译时候传入 

其原理是： go tool link 提供了个 `-X` 参数，允许我们在编译构建Go程序的时候，传入自定义的值，覆盖对应的import path下的指定变量

```bash
-X importpath.name=value
	Set the value of the string variable in importpath named name to value.
	Note that before Go 1.5 this option took two separate arguments.
	Now it takes one argument split on the first = sign.
```


```
#!/bin/bash

COMMIT_HASH=`git rev-parse HEAD 2>/dev/null` 
BUILD_DATE=`date` 
TARGET=./bin/xxx 
SOURCE=./src/main.go 

go build -ldflags "-X \”main.BuildVersion=${COMMIT_HASH}\" -X \”main.BuildDate=${BUILD_DATE}\"" -o ${TARGET} ${SOURCE} 
``` 

对应的 version.go(文件名随意，注意package name 要跟上面的一致就好) 应该是编译前就创建好的，而赋值是编译期间直接生成在二进制文件里面，不体现在源码里面赋值。 

``` 
$ cat version.go 

package main 

var ( 
    BuildDate    string 
    BuildVersion string
) 
``` 

生成代码后，就可以通过变量的方式来获取了。既可以通过命令行 类似 --version 参数的形式来获取版本号和编译时间等，还可以通过 HTTP 请求的方式提供给相应的运维管理平台。当然还有更多的展示形式吧，留给读者自己思考。有更好方式的，也不妨留言指出，先感谢。


参考：
1. http://stackoverflow.com/questions/11354518/golang-application-auto-build-versioning
2. https://golang.org/cmd/link/
3. https://www.atatus.com/blog/golang-auto-build-versioning/
4. http://www.xiaozhou.net/go-makefile-and-auto-version-2016-06-13.html

