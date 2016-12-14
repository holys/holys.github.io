title: 当我们在压测 Go 程序时，我们要观察什么？
date: 2016-12-13 21:59:55
tags:
- benchmark
- go


---

This is a quick post.


### 1. 观察 QPS
![26764633-806F-443E-95E8-8719E87BFC](/images/26764633-806F-443E-95E8-8719E87BFCC6.png)

### 2. 观察请求响应时间
![06DEF2A1-CFCE-4FEB-AE1C-367E1EA64C0B](/images/06DEF2A1-CFCE-4FEB-AE1C-367E1EA64C0B.png)

### 3. 观察程序占用 CPU 情况
![33AB8635-AE6F-4FC6-9570-06DF33CCE1FD](/images/33AB8635-AE6F-4FC6-9570-06DF33CCE1FD.png)

### 4.  观察内存占用情况，甚至 heapalloc, heapinuse, heapidle,等
![14081EB6-8E38-480C-94B3-F2D8D3458754](/images/14081EB6-8E38-480C-94B3-F2D8D3458754.png)

### 5. 观察协程的使用情况

![F86E45FA-777A-4D6E-9291-2989786374](/images/F86E45FA-777A-4D6E-9291-2989786374C4-1.png)

### 6. 还可以看看 GC 的情况
![CE68422A-D92D-4FF5-8ED7-FE77593FAAF5](/images/CE68422A-D92D-4FF5-8ED7-FE77593FAAF5-1.png)

### 7. GC 也可以这么观测

$ gcvis /path/to/bin
2016/12/13 21:13:51 opening browser window, if this fails, navigate to http://127.0.0.1:63383/
![E97AF6FA-8442-443F-98DD-766548F3E35A](/images/E97AF6FA-8442-443F-98DD-766548F3E35A.png)

### 8.  还可以应该做下 profile (cpu, heap, heap 的话重点看 alloc_objects)
![A0CE91D8-334D-4711-88FA-A6FFFD905D36](/images/A0CE91D8-334D-4711-88FA-A6FFFD905D36.png)

### 9. 还可以通过火焰图的方式看 程序哪里占用 CPU比较厉害

![1FF8C7A7-C19E-4995-B422-FC75B8518ABA](/images/1FF8C7A7-C19E-4995-B422-FC75B8518ABA.png)


大概以上这些。


