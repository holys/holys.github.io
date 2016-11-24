title: Go 的三种不同 md5 计算方式性能比较
date: 2016-11-24 20:42:50
tags:
- md5
- performance
- bufio
- golang
---

今天介绍的三种不同的 md5 计算方式，其实区别是读文件的不同，也就是磁盘 I/O, 所以也可以举一反三用在网络 I/O 上。

## ReadFile 

先看第一种， 简单粗暴：

```go

func md5sum1(file string) string {
    data, err := ioutil.ReadFile(file)
    if err != nil {
        return ""
    }

    return fmt.Sprintf("%x", md5.Sum(data))
}
```

之所以说其粗暴，是因为 ReadFile 里面其实调用了一个 readall， 分配内存是最多的。
Benchmark 来一发：

```go
var test_path = "/path/to/file"
func BenchmarkMd5Sum1(b *testing.B) {
	for i := 0; i < b.N; i++ {
		md5sum1(test_path)
	}
}
```

```shell
 go test -test.run=none  -test.bench="^BenchmarkMd5Sum1$"  -benchtime=10s  -benchmem

BenchmarkMd5Sum1-4   	   300 43704982 ns/op     19408224 B/op    14 allocs/op
PASS
ok  	tmp	17.446s
```

先说明下，这个文件大小是 19405028 字节，和上面的 `19408224 B/op` 非常接近, 因为 readall 确实是分配了文件大小的内存，代码为证：

ReadFile 源码
```
// ReadFile reads the file named by filename and returns the contents.
// A successful call returns err == nil, not err == EOF. Because ReadFile
// reads the whole file, it does not treat an EOF from Read as an error
// to be reported.
func ReadFile(filename string) ([]byte, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	// It's a good but not certain bet that FileInfo will tell us exactly how much to
	// read, so let's try it but be prepared for the answer to be wrong.
	var n int64

	if fi, err := f.Stat(); err == nil {
		// Don't preallocate a huge buffer, just in case.
		if size := fi.Size(); size < 1e9 {
			n = size
		}
	}
	// As initial capacity for readAll, use n + a little extra in case Size is zero,
	// and to avoid another allocation after Read has filled the buffer. The readAll
	// call will read into its allocated internal buffer cheaply. If the size was
	// wrong, we'll either waste some space off the end or reallocate as needed, but
	// in the overwhelmingly common case we'll get it just right.
	
	// readAll 第二个参数是即将创建的 buffer 大小
	return readAll(f, n+bytes.MinRead)
}

func readAll(r io.Reader, capacity int64) (b []byte, err error) {
  // 这个 buffer 的大小就是 file size + bytes.MinRead 

	buf := bytes.NewBuffer(make([]byte, 0, capacity))
	// If the buffer overflows, we will get bytes.ErrTooLarge.
	// Return that as an error. Any other panic remains.
	defer func() {
		e := recover()
		if e == nil {
			return
		}
		if panicErr, ok := e.(error); ok && panicErr == bytes.ErrTooLarge {
			err = panicErr
		} else {
			panic(e)
		}
	}()
	_, err = buf.ReadFrom(r)
	return buf.Bytes(), err
}
```

## io.Copy

再看第二种，

```go
func md5sum2(file string) string {
    f, err := os.Open(file)
    if err != nil {
        return ""
    }
    defer f.Close()

    h := md5.New()

    _, err = io.Copy(h, f)
    if err != nil {
        return ""
    }

    return fmt.Sprintf("%x", h.Sum(nil))
}
```

第二种的特点是：使用了 io.Copy。 在一般情况下（特殊情况在下面会提到），io.Copy 每次会分配 32 *1024 字节的内存，即32 KB, 然后咱看下 Benchmark 的情况：

```go
func BenchmarkMd5Sum2(b *testing.B) {

	for i := 0; i < b.N; i++ {
		md5sum2(test_path)
	}
}
```

```shell
$ go test -test.run=none  -test.bench="^BenchmarkMd5Sum2$"  -benchtime=10s  -benchmem

BenchmarkMd5Sum2-4 500	  37538305 ns/op     33093 B/op    8 allocs/op
PASS
ok  	tmp	22.657s
```

32 * 1024 = 32768, 和 上面的 `33093 B/op` 很接近。


## io.Copy + bufio.Reader

然后再看看第三种情况。这次不仅用了 `io.Copy`，还用了 bufio.Reader。 bufio 顾名思义， 即 buffered I/O， 性能相对要好些。bufio.Reader 默认会创建 4096 字节的 buffer。

```go
func md5sum3(file string) string {
	f, err := os.Open(file)
	if err != nil {
		return ""
	}
	defer f.Close()
	r := bufio.NewReader(f)

	h := md5.New()

	_, err = io.Copy(h, r)
	if err != nil {
		return ""
	}

	return fmt.Sprintf("%x", h.Sum(nil))

}
```

看下 Benchmark 的情况：

```go
func BenchmarkMd5Sum3(b *testing.B) {
	for i := 0; i < b.N; i++ {
		md5sum3(test_path)
		}
}
```

```shell
$ go test -test.run=none  -test.bench="^BenchmarkMd5Sum3$"  -benchtime=10s  -benchmem
BenchmarkMd5Sum3-4   300   42589812 ns/op   4507 B/op    9 allocs/op
PASS
ok  	tmp	16.817s
```

上面的 `4507 B/op` 是不是和 4096 很接近？ 那为什么 `io.Copy` + `bufio.Reader` 的方式所用内存会比单纯的 `io.Copy` 占用内存要少一些呢？ 上文也提到， 一般情况下 io.Copy 每次会分配 32 *1024 字节的内存，那特殊情况是？ 答案在源码中。

一起看看 io.Copy 相关源码：

```go
func Copy(dst Writer, src Reader) (written int64, err error) {
	return copyBuffer(dst, src, nil)
}

// copyBuffer is the actual implementation of Copy and CopyBuffer.
// if buf is nil, one is allocated.
func copyBuffer(dst Writer, src Reader, buf []byte) (written int64, err error) {
	// If the reader has a WriteTo method, use it to do the copy.
	// Avoids an allocation and a copy.

	// hash.Hash 这个 Writer 并没有实现 WriteTo 方法，所以不会走这里
	if wt, ok := src.(WriterTo); ok {
		return wt.WriteTo(dst)
	}
	// Similarly, if the writer has a ReadFrom method, use it to do the copy.
	// 而 bufio.Reader 实现了 ReadFrom 方法，所以，会走这里
	if rt, ok := dst.(ReaderFrom); ok {
		return rt.ReadFrom(src)
	}
	
	if buf == nil {
		buf = make([]byte, 32*1024)
	}
	for {
		nr, er := src.Read(buf)
		if nr > 0 {
			nw, ew := dst.Write(buf[0:nr])
			if nw > 0 {
				written += int64(nw)
			}
			if ew != nil {
				err = ew
				break
			}
			if nr != nw {
				err = ErrShortWrite
				break
			}
		}
		if er == EOF {
			break
		}
		if er != nil {
			err = er
			break
		}
	}
	return written, err
}
```

从上面的源码来看， 用 bufio.Reader 实现的 io.Reader 并不会走默认的 buffer创建路径，而是提前返回了，使用了 bufio.Reader 创建的 buffer, 这也是使用了 bufio.Reader 分配的内存会小一些。

当然如果你希望 io.Copy 也分配小一点的内存，也是可以做到的，不过是用 io.CopyBuffer, buf 就创建一个 4096 的 []byte 即可, 就跟 bufio.Reader 区别不大了。

看看是不是这样：

```
// Md5Sum2 用 CopyBufer 重新实现，buf := make([]byte, 4096)
BenchmarkMd5Sum2-4           500      38484425 ns/op        4409 B/op          8 allocs/op
BenchmarkMd5Sum3-4           500      38671090 ns/op        4505 B/op          9 allocs/op
```

从结果来看， 分配的内存相差不大，毕竟实现不一样，不可能一致。

那下次如果你要写一个下载大文件的程序，你还会用 ioutil.ReadAll(resp.Body) 吗？


最后整体对比下 Benchmark 的情况：

```
$ go test -test.run=none  -test.bench="."  -benchtime=10s  -benchmem
testing: warning: no tests to run
BenchmarkMd5Sum1-4           300      42551920 ns/op    19408230 B/op         14 allocs/op
BenchmarkMd5Sum2-4           500      38445352 ns/op       33089 B/op          8 allocs/op
BenchmarkMd5Sum3-4           500      38809429 ns/op        4505 B/op          9 allocs/op
PASS
ok      tmp 63.821s
```


## 小结
	
 1. 这三种不同的 md5 计算方式在执行时间上都差不多，区别最大的是内存的分配上；
 2. bufio 在处理 I/O 还是很有优势的，优先选择；
 3. 尽量避免 ReadAll 这种用法。
  


